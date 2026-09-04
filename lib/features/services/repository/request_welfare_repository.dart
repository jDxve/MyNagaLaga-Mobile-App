import 'dart:io';
import 'package:mynagalaga_mobile_app/core/network/data_state.dart';
import 'package:mynagalaga_mobile_app/features/services/models/welfare_program_model.dart';
import 'package:mynagalaga_mobile_app/features/services/models/welfare_request_model.dart';

abstract class WelfareServiceRepository {
  Future<DataState<WelfareRequestModel>> fetchPrefill({
    required String postingId,
    required List<String> attachedBadgeTypeIds,
    required WelfarePostingModel posting,
  });

  Future<DataState<WelfareRequestModel>> submitServiceRequest({
    required String postingId,
    required String mobileUserId,
    required String description,
    required Map<String, String> textFields,
    required Map<String, File?> files,
    required WelfarePostingModel posting,
    required List<String> attachedBadgeTypeIds,
  });

  void clearCache(String postingId);
  WelfareRequestModel? getCached(String postingId);
}