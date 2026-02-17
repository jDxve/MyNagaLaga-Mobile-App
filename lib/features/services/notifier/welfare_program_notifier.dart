import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/welfare_program_model.dart';
import '../repository/welfare_program_repository_impl.dart';

// ─── Programs Notifier ──────────────────────────────────────

final welfareProgramsNotifierProvider = NotifierProvider<
    WelfareProgramsNotifier, DataState<List<WelfareProgramModel>>>(
  WelfareProgramsNotifier.new,
);

class WelfareProgramsNotifier
    extends Notifier<DataState<List<WelfareProgramModel>>> {
  @override
  DataState<List<WelfareProgramModel>> build() {
    ref.keepAlive();
    return const DataState.started();
  }

  Future<void> fetchPrograms({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasValidData()) return;
    state = const DataState.loading();
    state = await ref
        .read(welfareProgramRepositoryProvider)
        .getPrograms(isActive: true);
  }

  String? findProgramId(String programName) {
    return state.when(
      started: () => null,
      loading: () => null,
      error: (_) => null,
      success: (programs) {
        try {
          return programs
              .firstWhere((p) =>
                  p.name.toLowerCase().contains(programName.toLowerCase()))
              .id;
        } catch (_) {
          return null;
        }
      },
    );
  }

  bool _hasValidData() {
    return state.when(
      started: () => false,
      loading: () => false,
      success: (data) => data.isNotEmpty,
      error: (_) => false,
    );
  }

  void reset() => state = const DataState.started();
}

// ─── All Postings Notifier ──────────────────────────────────

final allPostingsNotifierProvider = NotifierProvider<AllPostingsNotifier,
    DataState<List<WelfarePostingModel>>>(
  AllPostingsNotifier.new,
);

class AllPostingsNotifier
    extends Notifier<DataState<List<WelfarePostingModel>>> {
  @override
  DataState<List<WelfarePostingModel>> build() {
    ref.keepAlive();
    return const DataState.started();
  }

  Future<void> fetchAllPostings({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasValidData()) return;
    state = const DataState.loading();
    state = await ref.read(welfareProgramRepositoryProvider).getPostings(
          status: 'Published',
          page: 1,
          limit: 100,
        );
  }

  bool _hasValidData() {
    return state.when(
      started: () => false,
      loading: () => false,
      success: (data) => data.isNotEmpty,
      error: (_) => false,
    );
  }

  void reset() => state = const DataState.started();
}

// ─── Postings Notifier ──────────────────────────────────────

final welfarePostingsNotifierProvider = NotifierProvider<
    WelfarePostingsNotifier, DataState<List<WelfarePostingModel>>>(
  WelfarePostingsNotifier.new,
);

class WelfarePostingsNotifier
    extends Notifier<DataState<List<WelfarePostingModel>>> {
  String? _cacheKey;

  @override
  DataState<List<WelfarePostingModel>> build() {
    ref.keepAlive();
    return const DataState.started();
  }

  /// Fetch postings directly by serviceId.
  /// Used by PostingsListPage after user picks a service.
  Future<void> fetchPostingsByServiceId(
    String serviceId, {
    bool forceRefresh = false,
  }) async {
    final key = 'service:$serviceId';
    if (!forceRefresh && key == _cacheKey && _hasValidData()) return;
    _cacheKey = key;
    state = const DataState.loading();
    state = await ref.read(welfareProgramRepositoryProvider).getPostings(
          serviceId: serviceId,
          status: 'Published',
          page: 1,
          limit: 50,
        );
  }

  /// Fetch postings by resolving programName → programId first.
  /// Used when navigating from program name rather than serviceId.
  Future<void> fetchPostingsByProgramName(
    String programName, {
    bool forceRefresh = false,
  }) async {
    await ref
        .read(welfareProgramsNotifierProvider.notifier)
        .fetchPrograms();

    final programId = ref
        .read(welfareProgramsNotifierProvider.notifier)
        .findProgramId(programName);

    if (programId == null) {
      state = const DataState.error(error: 'Program not found');
      return;
    }

    final key = 'program:$programId';
    if (!forceRefresh && key == _cacheKey && _hasValidData()) return;
    _cacheKey = key;
    state = const DataState.loading();
    state = await ref.read(welfareProgramRepositoryProvider).getPostings(
          programId: programId,
          status: 'Published',
          page: 1,
          limit: 50,
        );
  }

  bool _hasValidData() {
    return state.when(
      started: () => false,
      loading: () => false,
      success: (data) => data.isNotEmpty,
      error: (_) => false,
    );
  }

  void reset() {
    state = const DataState.started();
    _cacheKey = null;
  }
}

// ─── Posting Detail Notifier ────────────────────────────────
// Fetches a single posting by ID — includes badge requirements.

final postingDetailNotifierProvider = NotifierProvider<
    PostingDetailNotifier, DataState<WelfarePostingModel>>(
  PostingDetailNotifier.new,
);

class PostingDetailNotifier
    extends Notifier<DataState<WelfarePostingModel>> {
  @override
  DataState<WelfarePostingModel> build() => const DataState.started();

  Future<void> fetchPosting(String postingId) async {
    state = const DataState.loading();
    state = await ref
        .read(welfareProgramRepositoryProvider)
        .getPosting(postingId);
  }

  void reset() => state = const DataState.started();
}