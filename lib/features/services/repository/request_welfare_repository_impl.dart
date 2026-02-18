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
  final Map<String, WelfareRequestModel> _submitCache = {};

  WelfareServiceRepositoryImpl({required RequestWelfareService service})
      : _service = service;

  @override
  WelfareRequestModel? getCached(String postingId) => _submitCache[postingId];

  @override
  void clearCache(String postingId) {
    _submitCache.remove(postingId);
    debugPrint('🗑️ Cache cleared for posting $postingId');
  }

  /// First POST — allowMissing: true, no files/text
  /// Returns prefill.badges[] to pre-fill the form
  @override
  Future<DataState<WelfareRequestModel>> fetchPrefill({
    required String postingId,
    required List<String> attachedBadgeTypeIds,
    required WelfarePostingModel posting,
  }) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('postingId', postingId));
      formData.fields.add(const MapEntry('allowMissing', 'true'));
      formData.fields.add(const MapEntry('description', 'prefill'));

      if (attachedBadgeTypeIds.isNotEmpty) {
        formData.fields.add(MapEntry(
          'attachedBadgeTypeIds',
          jsonEncode(attachedBadgeTypeIds),
        ));
      }

      final allItems =
          posting.requirements.expand((g) => g.items).toList();
      formData.fields.add(MapEntry(
        'requirementIds',
        jsonEncode(allItems.map((i) => i.requirementId).toList()),
      ));

      final response = await _service.submitApplication(
        postingId: postingId,
        data: formData,
      );

      final body = response.data as Map<String, dynamic>;
      final model = WelfareRequestModel.fromMap(
          body['data'] as Map<String, dynamic>);
      return DataState.success(data: model);
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is Map<String, dynamic>) {
        final error = ErrorResponse.fromMap(body);
        return DataState.error(
            error: error.message ?? 'Failed to load badge data');
      }
      return DataState.error(error: e.message ?? 'Network error');
    } catch (e) {
      return DataState.error(error: 'Unexpected error: $e');
    }
  }

  /// Second POST — allowMissing: false, all filled data
  @override
  Future<DataState<WelfareRequestModel>> submitServiceRequest({
    required String postingId,
    required String mobileUserId,
    required String description,
    required Map<String, String> textFields,
    required Map<String, File?> files,
    required WelfarePostingModel posting,
    required List<String> attachedBadgeTypeIds,
  }) async {
    final cached = _submitCache[postingId];
    if (cached != null) return DataState.success(data: cached);

    try {
      debugPrint('📤 Submitting welfare application for posting $postingId');

      final formData = FormData();
      formData.fields.add(MapEntry('description', description));
      formData.fields.add(MapEntry('postingId', postingId));
      formData.fields.add(const MapEntry('allowMissing', 'false'));

      if (attachedBadgeTypeIds.isNotEmpty) {
        formData.fields.add(MapEntry(
          'attachedBadgeTypeIds',
          jsonEncode(attachedBadgeTypeIds),
        ));
      }

      final allItems =
          posting.requirements.expand((g) => g.items).toList();
      formData.fields.add(MapEntry(
        'requirementIds',
        jsonEncode(allItems.map((i) => i.requirementId).toList()),
      ));

      final textValueMap = <String, String>{};
      for (final item in allItems) {
        if (item.type == 'text') {
          final value = textFields[item.key] ?? '';
          if (value.isNotEmpty) textValueMap[item.requirementId] = value;
        }
      }
      if (textValueMap.isNotEmpty) {
        formData.fields
            .add(MapEntry('textValues', jsonEncode(textValueMap)));
        debugPrint('📝 textValues: $textValueMap');
      }

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

      final body = response.data as Map<String, dynamic>;
      final model = WelfareRequestModel.fromMap(
          body['data'] as Map<String, dynamic>);
      _submitCache[postingId] = model;
      debugPrint('✅ Submitted. Count: ${model.submittedCount}');
      return DataState.success(data: model);
    } on DioException catch (e) {
      final body = e.response?.data;
      debugPrint('❌ Dio Error [${e.response?.statusCode}]: $body');
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