import 'dart:io';
import 'package:dio/dio.dart';
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
      final response = await _service.getCaseTypes();
      final raw = response.data;

      List<dynamic> typesJson;

      if (raw is List) {
        typesJson = raw;
      } else if (raw is Map<String, dynamic> && raw.containsKey('data')) {
        typesJson = raw['data'] as List<dynamic>;
      } else {
        return const DataState.error(error: 'Invalid response format');
      }

      final types = typesJson
          .map((json) => CaseTypeModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return DataState.success(data: types);
    } on DioException catch (e) {
      return DataState.error(error: _parseDioError(e) ?? 'Network error occurred');
    } catch (e) {
      return DataState.error(error: 'Unexpected error: $e');
    }
  }

  Future<File?> _compressImage(String filePath) async {
    try {
      final file = File(filePath);
      final fileSize = await file.length();

      if (fileSize < 500 * 1024) return file;

      final targetPath = '${filePath.replaceAll(RegExp(r'\.(jpg|jpeg|png|heic|heif)$'), '')}_compressed.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        filePath,
        targetPath,
        quality: 70,
        minWidth: 1920,
        minHeight: 1920,
      );

      return compressedFile != null ? File(compressedFile.path) : file;
    } catch (_) {
      return File(filePath);
    }
  }

  @override
  Future<DataState<ServiceRequestResponseModel>> submitServiceRequest(
    ServiceRequestModel request,
  ) async {
    try {
      final formData = FormData();

      formData.fields.add(MapEntry('case_type_id', request.caseTypeId.toString()));
      formData.fields.add(MapEntry('description', request.description));
      formData.fields.add(MapEntry('is_anonymous', request.isAnonymous.toString()));
      formData.fields.add(MapEntry('is_sensitive', request.isSensitive.toString()));

      if (request.barangayId != null) {
        formData.fields.add(MapEntry('barangay_id', request.barangayId.toString()));
      }

      if (request.badgeIds != null && request.badgeIds!.isNotEmpty) {
        formData.fields.add(MapEntry('badge_ids', request.badgeIds.toString()));
      }

      if (request.filePaths != null && request.filePaths!.isNotEmpty) {
        for (final filePath in request.filePaths!) {
          final fileToUpload = await _compressImage(filePath);
          if (fileToUpload == null || !await fileToUpload.exists()) continue;

          final mimeType = lookupMimeType(fileToUpload.path) ?? 'image/jpeg';
          final mimeTypeParts = mimeType.split('/');

          formData.files.add(MapEntry(
            'documents',
            await MultipartFile.fromFile(
              fileToUpload.path,
              filename: fileToUpload.path.split('/').last,
              contentType: MediaType(mimeTypeParts[0], mimeTypeParts[1]),
            ),
          ));
        }
      }

      final response = await _service.submitServiceRequest(formData);
      final raw = response.data;

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['error'] ?? raw['message'] ?? 'Failed to submit service request',
        );
      }

      return DataState.success(
        data: ServiceRequestResponseModel.fromJson(raw['data'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return DataState.error(error: _parseDioError(e) ?? 'Network error occurred');
    } catch (e) {
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
      final response = await _service.getMyServiceRequests(status, search, page, limit);
      final raw = response.data;

      if (raw['success'] != true) {
        return DataState.error(error: raw['error'] ?? 'Failed to fetch service requests');
      }

      final requests = (raw['data'] as List<dynamic>)
          .map((json) => ServiceRequestResponseModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return DataState.success(data: requests);
    } on DioException catch (e) {
      return DataState.error(error: _parseDioError(e) ?? 'Network error occurred');
    } catch (e) {
      return DataState.error(error: 'Unexpected error: $e');
    }
  }

  @override
  Future<DataState<ServiceRequestResponseModel>> getServiceRequestById(String id) async {
    try {
      final response = await _service.getServiceRequestById(id);
      final raw = response.data;

      if (raw['success'] != true) {
        return DataState.error(error: raw['error'] ?? 'Failed to fetch service request');
      }

      return DataState.success(
        data: ServiceRequestResponseModel.fromJson(raw['data'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return DataState.error(error: _parseDioError(e) ?? 'Network error occurred');
    } catch (e) {
      return DataState.error(error: 'Unexpected error: $e');
    }
  }

  String? _parseDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['error'] as String? ?? data['message'] as String?;
    }
    if (data is String) return data;
    return e.message;
  }
}