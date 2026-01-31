import '../../../common/models/dio/data_state.dart';
import '../models/welfare_program_model.dart';

abstract class WelfareProgramRepository {
  Future<DataState<List<WelfarePostingModel>>> getPostings({
    String? programId,
    String? status,
    int page,
    int limit,
  });
}
