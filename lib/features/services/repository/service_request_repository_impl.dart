// lib/features/services/repository/service_request_repository_impl.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/service_request_model.dart';
import '../services/service_request_service.dart';
import 'service_request_repository.dart';

class ServiceRequestRepositoryImpl implements ServiceRequestRepository {
  final ServiceRequestService _service;

  ServiceRequestRepositoryImpl({required ServiceRequestService service})
      : _service = service;

  @override
  Future<DataState<List<CaseTypeModel>>> getCaseTypes() async {
    try {
      debugPrint('📤 Fetching case types');
      final response = await _service.getCaseTypes();
      final raw = response.data;
      
      debugPrint('📥 Response: $raw');
      debugPrint('📥 Response type: ${raw.runtimeType}');

      // ✅ FIXED: Backend returns array directly, not wrapped
      List<dynamic> typesJson;
      
      if (raw is List) {
        // Response is directly an array
        typesJson = raw;
      } else if (raw is Map<String, dynamic>) {
        // Response might be wrapped in { success: true, data: [...] }
        if (raw.containsKey('data')) {
          typesJson = raw['data'] as List<dynamic>;
        } else {
          return const DataState.error(
            error: 'Invalid response format',
          );
        }
      } else {
        return const DataState.error(
          error: 'Unexpected response type',
        );
      }

      final types = typesJson
          .map((json) {
            debugPrint('Parsing: $json (${json.runtimeType})');
            return CaseTypeModel.fromJson(json as Map<String, dynamic>);
          })
          .toList();

      debugPrint('✅ Loaded ${types.length} case types');
      return DataState.success(data: types);
      
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.response?.statusCode} - ${e.message}');
      debugPrint('❌ Response data: ${e.response?.data}');
      
      if (e.response?.data != null) {
        try {
          final errorData = e.response!.data;
          if (errorData is Map<String, dynamic>) {
            final errorMessage = errorData['error'] ??
                errorData['message'] ??
                'Failed to fetch case types';
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
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected Error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      return DataState.error(error: 'Unexpected error: $e');
    }
  }

  // ✅ NEW: Compress image before upload
  Future<File?> _compressImage(String filePath) async {
    try {
      final file = File(filePath);
      final fileSize = await file.length();

      // Skip compression if file is already small (< 500KB)
      if (fileSize < 500 * 1024) {
        debugPrint('   File already small (${(fileSize / 1024).toStringAsFixed(2)}KB), skipping compression');
        return file;
      }

      debugPrint('   Compressing image (${(fileSize / 1024).toStringAsFixed(2)}KB)...');

      final targetPath = filePath.replaceAll('.jpg', '_compressed.jpg')
          .replaceAll('.jpeg', '_compressed.jpg')
          .replaceAll('.png', '_compressed.jpg');

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        filePath,
        targetPath,
        quality: 70, // Adjust quality (0-100, lower = smaller file)
        minWidth: 1920, // Max width
        minHeight: 1920, // Max height
      );

      if (compressedFile != null) {
        final compressedSize = await File(compressedFile.path).length();
        debugPrint('   ✅ Compressed: ${(fileSize / 1024).toStringAsFixed(2)}KB → ${(compressedSize / 1024).toStringAsFixed(2)}KB');
        return File(compressedFile.path);
      }

      return file;
    } catch (e) {
      debugPrint('   ⚠️ Compression failed: $e, using original');
      return File(filePath);
    }
  }

  @override
  Future<DataState<ServiceRequestResponseModel>> submitServiceRequest(
    ServiceRequestModel request,
  ) async {
    try {
      debugPrint('📤 Submitting service request');
      debugPrint('   Case Type ID: ${request.caseTypeId}');
      debugPrint('   Description: ${request.description}');
      debugPrint('   Files: ${request.filePaths?.length ?? 0}');

      final formData = FormData();

      // Add form fields
      formData.fields.add(
        MapEntry('case_type_id', request.caseTypeId.toString()),
      );
      formData.fields.add(
        MapEntry('description', request.description),
      );
      formData.fields.add(
        MapEntry('is_anonymous', request.isAnonymous.toString()),
      );
      formData.fields.add(
        MapEntry('is_sensitive', request.isSensitive.toString()),
      );

      if (request.barangayId != null) {
        formData.fields.add(
          MapEntry('barangay_id', request.barangayId.toString()),
        );
      }

      if (request.badgeIds != null && request.badgeIds!.isNotEmpty) {
        // Backend expects badge_ids as JSON array string
        formData.fields.add(
          MapEntry('badge_ids', request.badgeIds.toString()),
        );
      }

      // ✅ OPTIMIZED: Compress and add files
      if (request.filePaths != null && request.filePaths!.isNotEmpty) {
        for (int i = 0; i < request.filePaths!.length; i++) {
          final filePath = request.filePaths![i];

          // Compress image before upload
          final fileToUpload = await _compressImage(filePath);

          if (fileToUpload == null || !await fileToUpload.exists()) {
            debugPrint('⚠️ File not found: $filePath');
            continue;
          }

          final mimeType = lookupMimeType(fileToUpload.path) ?? 'image/jpeg';
          final mimeTypeParts = mimeType.split('/');

          debugPrint('📎 Adding file ${i + 1}: ${fileToUpload.path}');
          debugPrint('   MIME type: $mimeType');

          formData.files.add(
            MapEntry(
              'documents', // Backend expects 'documents' field name
              await MultipartFile.fromFile(
                fileToUpload.path,
                filename: fileToUpload.path.split('/').last,
                contentType: MediaType(mimeTypeParts[0], mimeTypeParts[1]),
              ),
            ),
          );
        }
      }

      debugPrint('📦 Form data prepared');

      final response = await _service.submitServiceRequest(formData);
      final raw = response.data;

      debugPrint('📥 Response received: $raw');

      if (raw['success'] != true) {
        debugPrint('❌ Server returned success=false');
        debugPrint('   Error: ${raw['error']}');
        return DataState.error(
          error: raw['error'] ?? raw['message'] ?? 'Failed to submit service request',
        );
      }

      final responseData = ServiceRequestResponseModel.fromJson(
        raw['data'] as Map<String, dynamic>,
      );

      debugPrint('✅ Service request submitted successfully');
      debugPrint('   Case Code: ${responseData.caseCode}');

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

  @override
  Future<DataState<List<ServiceRequestResponseModel>>> getMyServiceRequests({
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      debugPrint('📤 Fetching my service requests (page: $page)');

      final response = await _service.getMyServiceRequests(
        status,
        search,
        page,
        limit,
      );

      final raw = response.data;

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['error'] ?? 'Failed to fetch service requests',
        );
      }

      final List<dynamic> requestsJson = raw['data'] as List<dynamic>;
      final requests = requestsJson
          .map((json) => ServiceRequestResponseModel.fromJson(
                json as Map<String, dynamic>,
              ))
          .toList();

      debugPrint('✅ Loaded ${requests.length} service requests');

      return DataState.success(data: requests);
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.response?.statusCode} - ${e.message}');
      return DataState.error(
        error: e.message ?? 'Network error occurred',
      );
    } catch (e) {
      debugPrint('❌ Unexpected Error: $e');
      return DataState.error(error: 'Unexpected error: $e');
    }
  }

  @override
  Future<DataState<ServiceRequestResponseModel>> getServiceRequestById(
    String id,
  ) async {
    try {
      debugPrint('📤 Fetching service request: $id');

      final response = await _service.getServiceRequestById(id);
      final raw = response.data;

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['error'] ?? 'Failed to fetch service request',
        );
      }

      final requestData = ServiceRequestResponseModel.fromJson(
        raw['data'] as Map<String, dynamic>,
      );

      debugPrint('✅ Service request loaded');

      return DataState.success(data: requestData);
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.response?.statusCode} - ${e.message}');
      return DataState.error(
        error: e.message ?? 'Network error occurred',
      );
    } catch (e) {
      debugPrint('❌ Unexpected Error: $e');
      return DataState.error(error: 'Unexpected error: $e');
    }
  }
}