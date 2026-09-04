import 'package:mynagalaga_mobile_app/core/network/data_state.dart';
import 'package:mynagalaga_mobile_app/features/services/models/welfare_program_model.dart';

abstract class WelfareProgramRepository {
  Future<DataState<List<WelfareProgramModel>>> getPrograms({
    bool? isActive,
    int page,
    int limit,
  });

  Future<DataState<List<WelfarePostingModel>>> getPostings({
    String? programId,
    String? serviceId,
    String? status,
    int page,
    int limit,
  });

  Future<DataState<WelfarePostingModel>> getPosting(String postingId);
}