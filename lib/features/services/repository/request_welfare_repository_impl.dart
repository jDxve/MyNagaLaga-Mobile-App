import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/models/responses/error_response.dart';
import '../models/welfare_program_model.dart';
import '../models/welfare_request_model.dart';
import '../services/request_welfare_service.dart';
import 'request_welfare_repository.dart';

final welfareServiceRepositoryProvider =
    Provider<WelfareServiceRepository>((ref) {
  final service = ref.watch(requestWelfareServiceProvider);
  return WelfareServiceRepositoryImpl(service: service);
});

class WelfareServiceRepositoryImpl implements WelfareServiceRepository {
  final RequestWelfareService _service;
  final Map<String, WelfareRequestModel> _cache = {};

  WelfareServiceRepositoryImpl({required RequestWelfareService service})
      : _service = service;

  @override
  WelfareRequestModel? getCached(String postingId) => _cache[postingId];

  @override
  void clearCache(String postingId) {
    _cache.remove(postingId);
    debugPrint('🗑️ Cache cleared for posting $postingId');
  }

  @override
  Future<DataState<WelfareRequestModel>> submitServiceRequest({
    required String postingId,
    required String mobileUserId,
    required String description,
    required Map<String, String> textFields,
    required Map<String, File?> files,
    required WelfarePostingModel posting,
  }) async {
    final cached = _cache[postingId];
    if (cached != null) {
      debugPrint('💾 Returning cached result for posting $postingId');
      return DataState.success(data: cached);
    }

    try {
      debugPrint('📤 Submitting welfare application for posting $postingId');

      final formData = FormData();

      formData.fields.add(MapEntry('description', description));
      formData.fields.add(MapEntry('postingId', postingId));

      // Flatten all requirement items across groups
      final allItems = posting.requirements
          .expand((group) => group.items)
          .toList();

      // requirementIds — JSON array of DB ids e.g. '["12","13","14"]'
      final requirementIds =
          allItems.map((item) => item.requirementId).toList();
      formData.fields
          .add(MapEntry('requirementIds', jsonEncode(requirementIds)));
      debugPrint('📋 requirementIds: $requirementIds');

      // textValues — JSON object keyed by requirementId e.g. '{"12":"John"}'
      final textValueMap = <String, String>{};
      for (final item in allItems) {
        if (item.type == 'text') {
          final value = textFields[item.key] ?? '';
          if (value.isNotEmpty) {
            textValueMap[item.requirementId] = value;
          }
        }
      }
      if (textValueMap.isNotEmpty) {
        formData.fields
            .add(MapEntry('textValues', jsonEncode(textValueMap)));
        debugPrint('📝 textValues: $textValueMap');
      }

      // files + fileRequirementIds — aligned arrays
      final fileRequirementIds = <String>[];
      for (final item in allItems) {
        if (item.type != 'text') {
          final file = files[item.key];
          if (file != null) {
            final fileName = file.path.split('/').last;
            final mimeType = _getMimeType(fileName);
            fileRequirementIds.add(item.requirementId);
            formData.files.add(MapEntry(
              'files',
              await MultipartFile.fromFile(
                file.path,
                filename: fileName,
                contentType: MediaType.parse(mimeType),
              ),
            ));
          }
        }
      }
      if (fileRequirementIds.isNotEmpty) {
        formData.fields.add(
            MapEntry('fileRequirementIds', jsonEncode(fileRequirementIds)));
        debugPrint('📎 fileRequirementIds: $fileRequirementIds');
      }

      final response = await _service.submitApplication(
        postingId: postingId,
        data: formData,
      );

      final responseData = response.data as Map<String, dynamic>;
      final model = WelfareRequestModel.fromMap(
          responseData['data'] as Map<String, dynamic>);

      _cache[postingId] = model;
      debugPrint('✅ Application submitted. Count: ${model.submittedCount}');
      return DataState.success(data: model);
    } on DioException catch (e) {
      final body = e.response?.data;
      debugPrint('❌ Dio Error [${e.response?.statusCode}]: $body');
      if (body is Map<String, dynamic> && body['details'] != null) {
        debugPrint('❌ Validation details: ${jsonEncode(body['details'])}');
      }
      if (body is Map<String, dynamic>) {
        final error = ErrorResponse.fromMap(body);
        return DataState.error(
            error: error.message ?? 'Failed to submit application');
      }
      return DataState.error(error: e.message ?? 'Network error');
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return DataState.error(error: 'Unexpected error: $e');
    }
  }

  String _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}