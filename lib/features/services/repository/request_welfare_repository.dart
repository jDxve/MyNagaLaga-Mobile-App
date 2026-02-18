import 'dart:io';
import '../../../common/models/dio/data_state.dart';
import '../models/welfare_program_model.dart';
import '../models/welfare_request_model.dart';

abstract class WelfareServiceRepository {
  Future<DataState<WelfareRequestModel>> submitServiceRequest({
    required String postingId,
    required String mobileUserId,
    required String description,
    required Map<String, String> textFields,
    required Map<String, File?> files,
    required WelfarePostingModel posting,
  });

  void clearCache(String postingId);
  WelfareRequestModel? getCached(String postingId);
}