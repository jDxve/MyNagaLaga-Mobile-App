import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/welfare_program_model.dart';
import '../repository/welfare_program_repository_impl.dart';

final welfarePostingsNotifierProvider =
    NotifierProvider.autoDispose<WelfarePostingsNotifier,
        DataState<List<WelfarePostingModel>>>(
  WelfarePostingsNotifier.new,
);

class WelfarePostingsNotifier
    extends Notifier<DataState<List<WelfarePostingModel>>> {
  @override
  DataState<List<WelfarePostingModel>> build() {
    // ✅ Auto-fetch when notifier is created
    fetchPostings(status: 'Published');
    return const DataState.loading(); // Start with loading state
  }

  Future<void> fetchPostings({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    state = const DataState.loading();

    final repository = ref.read(welfareProgramRepositoryProvider);
    final result = await repository.getPostings(
      status: status,
      page: page,
      limit: limit,
    );

    state = result;
  }

  void reset() {
    state = const DataState.started();
  }
}