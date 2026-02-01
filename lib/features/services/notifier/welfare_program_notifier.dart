import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/welfare_program_model.dart';
import '../repository/welfare_program_repository_impl.dart';

final allPostingsNotifierProvider =
    NotifierProvider<AllPostingsNotifier, DataState<List<WelfarePostingModel>>>(
  AllPostingsNotifier.new,
);

final welfarePostingsNotifierProvider =
    NotifierProvider<WelfarePostingsNotifier, DataState<List<WelfarePostingModel>>>(
  WelfarePostingsNotifier.new,
);

class AllPostingsNotifier extends Notifier<DataState<List<WelfarePostingModel>>> {
  @override
  DataState<List<WelfarePostingModel>> build() {
    ref.keepAlive();
    return const DataState.started();
  }

  Future<void> fetchAllPostings({
    String? status = 'Published',
    int page = 1,
    int limit = 100,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _hasValidData()) {
      return;
    }

    state = const DataState.loading();

    final repository = ref.read(welfareProgramRepositoryProvider);
    final result = await repository.getPostings(
      programId: null,
      status: status,
      page: page,
      limit: limit,
    );

    state = result;
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
  }
}

class WelfarePostingsNotifier extends Notifier<DataState<List<WelfarePostingModel>>> {
  String? _cachedProgramId;

  @override
  DataState<List<WelfarePostingModel>> build() {
    ref.keepAlive();
    return const DataState.started();
  }

  Future<void> fetchPostings({
    String? programId,
    String? status = 'Published',
    int page = 1,
    int limit = 50,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && programId == _cachedProgramId && _hasValidData()) {
      return;
    }

    _cachedProgramId = programId;
    state = const DataState.loading();

    final repository = ref.read(welfareProgramRepositoryProvider);
    final result = await repository.getPostings(
      programId: programId,
      status: status,
      page: page,
      limit: limit,
    );

    state = result;
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
    _cachedProgramId = null;
  }
}