// request_welfare_repository_impl.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/welfare_request_model.dart';
import '../services/request_welfare_service.dart';
import 'request_welfare_repository.dart';

class RequestWelfareRepositoryImpl implements RequestWelfareRepository {
  final RequestWelfareService _service;

  RequestWelfareRepositoryImpl({required RequestWelfareService service})
      : _service = service;

  @override
  Future<DataState<WelfareRequestResponseModel>> submitServiceRequest(
    WelfareRequestModel request,
  ) async {
    try {
      debugPrint('📤 Submitting service request for posting: ${request.postingId}');
      debugPrint('   User ID: ${request.mobileUserId}');
      debugPrint('   Reason: ${request.reason}');
      debugPrint('   Requirement IDs: ${request.requirementIds}');
      debugPrint('   Badge ID: ${request.badgeId}');
      debugPrint('   File Paths: ${request.filePaths}');

      // Validate that we have files
      if (request.filePaths == null || request.filePaths!.isEmpty) {
        return const DataState.error(
          error: 'No files provided for upload',
        );
      }

      // Create FormData
      final formData = FormData();
      
      // Add text fields
      formData.fields.add(MapEntry('description', request.reason));
      formData.fields.add(MapEntry('requirementIds', jsonEncode(request.requirementIds)));
      
      if (request.badgeId != null) {
        formData.fields.add(MapEntry('badgeId', request.badgeId!));
      }

      // Add actual uploaded files
      for (int i = 0; i < request.filePaths!.length; i++) {
        final filePath = request.filePaths![i];
        final file = File(filePath);

        // Check if file exists
        if (!await file.exists()) {
          debugPrint('⚠️ File not found: $filePath');
          continue;
        }

        // Get MIME type from file extension
        final mimeType = lookupMimeType(filePath) ?? 'image/jpeg';
        final mimeTypeParts = mimeType.split('/');
        
        debugPrint('📎 Adding file: ${file.path}');
        debugPrint('   MIME type: $mimeType');

        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
              contentType: MediaType(mimeTypeParts[0], mimeTypeParts[1]),
            ),
          ),
        );
      }

      debugPrint('📦 Form data prepared with ${formData.files.length} files');

      final response = await _service.submitServiceRequest(
        request.postingId,
        formData,
      );

      final raw = response.data;

      debugPrint('📥 Response received: $raw');

      if (raw['success'] != true) {
        debugPrint('❌ Server returned success=false');
        debugPrint('   Error: ${raw['error']}');
        return DataState.error(
          error: raw['error'] ?? 'Failed to submit service request',
        );
      }

      final responseData = WelfareRequestResponseModel.fromJson(
        raw['data'] ?? {},
      );

      debugPrint('✅ Service request submitted successfully');

      return DataState.success(data: responseData);
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.response?.statusCode} - ${e.message}');
      debugPrint('❌ Response data: ${e.response?.data}');

      if (e.response?.statusCode == 404) {
        return const DataState.error(
          error: 'Service request endpoint not found.',
        );
      }

      if (e.response?.data != null) {
        try {
          final errorData = e.response!.data;
          debugPrint('❌ Error response type: ${errorData.runtimeType}');
          debugPrint('❌ Error response content: $errorData');
          
          if (errorData is Map<String, dynamic>) {
            final errorMessage = errorData['error'] ?? 
                               errorData['message'] ?? 
                               'Failed to submit service request';
            return DataState.error(error: errorMessage);
          } else if (errorData is String) {
            return DataState.error(error: errorData);
          }
        } catch (parseError) {
          debugPrint('❌ Error parsing error response: $parseError');
        }
      }

      return DataState.error(
        error: e.message ?? 'Network error occurred',
      );
    } catch (e) {
      debugPrint('❌ Unexpected Error: $e');
      return DataState.error(error: 'Unexpected error: $e');
    }
  }
}