import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/welfare_program_model.dart';
import '../repository/welfare_program_repository_impl.dart';

final welfareProgramsNotifierProvider = NotifierProvider<
    WelfareProgramsNotifier, DataState<List<WelfareProgramModel>>>(
  WelfareProgramsNotifier.new,
);

class WelfareProgramsNotifier
    extends Notifier<DataState<List<WelfareProgramModel>>> {
  List<WelfareProgramModel>? _cache;

  @override
  DataState<List<WelfareProgramModel>> build() {
    ref.keepAlive();
    return const DataState.started();
  }

  Future<void> fetchPrograms({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null && _cache!.isNotEmpty) {
      state = DataState.success(data: _cache!);
      return;
    }

    state = const DataState.loading();

    final result = await ref
        .read(welfareProgramRepositoryProvider)
        .getPrograms(isActive: true);

    result.whenOrNull(
      success: (data) {
        _cache = data;
      },
    );

    state = result;
  }

  String? findProgramId(String programName) {
    final programs = _cache;
    if (programs == null || programs.isEmpty) return null;

    try {
      return programs
          .firstWhere((p) =>
              p.name.toLowerCase().contains(programName.toLowerCase()))
          .id;
    } catch (_) {
      return null;
    }
  }

  void reset() {
    _cache = null;
    state = const DataState.started();
  }
}

final allPostingsNotifierProvider = NotifierProvider<AllPostingsNotifier,
    DataState<List<WelfarePostingModel>>>(
  AllPostingsNotifier.new,
);

class AllPostingsNotifier
    extends Notifier<DataState<List<WelfarePostingModel>>> {
  List<WelfarePostingModel>? _cache;

  @override
  DataState<List<WelfarePostingModel>> build() {
    ref.keepAlive();
    return const DataState.started();
  }

  Future<void> fetchAllPostings({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null && _cache!.isNotEmpty) {
      state = DataState.success(data: _cache!);
      return;
    }

    state = const DataState.loading();

    final result = await ref.read(welfareProgramRepositoryProvider).getPostings(
          status: 'Published',
          page: 1,
          limit: 100,
        );

    result.whenOrNull(
      success: (data) {
        _cache = data;
      },
    );

    state = result;
  }

  void reset() {
    _cache = null;
    state = const DataState.started();
  }
}

final welfarePostingsNotifierProvider = NotifierProvider<
    WelfarePostingsNotifier, DataState<List<WelfarePostingModel>>>(
  WelfarePostingsNotifier.new,
);

class WelfarePostingsNotifier
    extends Notifier<DataState<List<WelfarePostingModel>>> {
  final Map<String, List<WelfarePostingModel>> _cache = {};

  @override
  DataState<List<WelfarePostingModel>> build() {
    ref.keepAlive();
    return const DataState.started();
  }

  Future<void> fetchPostingsByServiceId(
    String serviceId, {
    bool forceRefresh = false,
  }) async {
    final key = 'service:$serviceId';

    if (!forceRefresh && _cache.containsKey(key)) {
      state = DataState.success(data: _cache[key]!);
      return;
    }

    state = const DataState.loading();

    final result = await ref
        .read(welfareProgramRepositoryProvider)
        .getPostings(
          serviceId: serviceId,
          status: 'Published',
          page: 1,
          limit: 50,
        );

    result.whenOrNull(
      success: (data) {
        _cache[key] = data;
      },
    );

    state = result;
  }

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

    if (!forceRefresh && _cache.containsKey(key)) {
      state = DataState.success(data: _cache[key]!);
      return;
    }

    state = const DataState.loading();

    final result = await ref
        .read(welfareProgramRepositoryProvider)
        .getPostings(
          programId: programId,
          status: 'Published',
          page: 1,
          limit: 50,
        );

    result.whenOrNull(
      success: (data) {
        _cache[key] = data;
      },
    );

    state = result;
  }

  void reset() {
    _cache.clear();
    state = const DataState.started();
  }
}

final postingDetailNotifierProvider = NotifierProvider<
    PostingDetailNotifier, DataState<WelfarePostingModel>>(
  PostingDetailNotifier.new,
);

class PostingDetailNotifier
    extends Notifier<DataState<WelfarePostingModel>> {
  final Map<String, WelfarePostingModel> _cache = {};

  @override
  DataState<WelfarePostingModel> build() {
    ref.keepAlive();
    return const DataState.started();
  }

  Future<void> fetchPosting(
    String postingId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache.containsKey(postingId)) {
      state = DataState.success(data: _cache[postingId]!);
      return;
    }

    state = const DataState.loading();

    final result = await ref
        .read(welfareProgramRepositoryProvider)
        .getPosting(postingId);

    result.whenOrNull(
      success: (data) {
        _cache[postingId] = data;
      },
    );

    state = result;
  }

  void reset() {
    _cache.clear();
    state = const DataState.started();
  }
}
