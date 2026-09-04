import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/network/data_state.dart';
import '../../../core/network/repository_guard.dart';
import '../models/service_request_model.dart';
import '../services/service_request_service.dart';
import 'service_request_repository.dart';

class ServiceRequestRepositoryImpl
    with RepositoryGuard
    implements ServiceRequestRepository {
  final ServiceRequestService _service;

  ServiceRequestRepositoryImpl({required ServiceRequestService service})
      : _service = service;

  @override
  Future<DataState<List<CaseTypeModel>>> getCaseTypes() => guard(() async {
        final response = await _service.getCaseTypes();
        final raw = response.data;

        List<dynamic> typesJson;
        if (raw is List) {
          typesJson = raw;
        } else if (raw is Map<String, dynamic> && raw.containsKey('data')) {
          typesJson = raw['data'] as List<dynamic>;
        } else {
          throw const AppException(message: 'Invalid response format');
        }

        return typesJson
            .map((json) => CaseTypeModel.fromJson(json as Map<String, dynamic>))
            .toList();
      });

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
  ) =>
      guard(() async {
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
          throw AppException(message: raw['error'] ?? raw['message'] ?? 'Failed to submit service request');
        }

        return ServiceRequestResponseModel.fromJson(raw['data'] as Map<String, dynamic>);
      });

  @override
  Future<DataState<List<ServiceRequestResponseModel>>> getMyServiceRequests({
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) =>
      guard(() async {
        final response = await _service.getMyServiceRequests(status, search, page, limit);
        final raw = response.data;

        if (raw['success'] != true) {
          throw AppException(message: raw['error'] ?? 'Failed to fetch service requests');
        }

        return (raw['data'] as List<dynamic>)
            .map((json) => ServiceRequestResponseModel.fromJson(json as Map<String, dynamic>))
            .toList();
      });

  @override
  Future<DataState<ServiceRequestResponseModel>> getServiceRequestById(String id) => guard(() async {
        final response = await _service.getServiceRequestById(id);
        final raw = response.data;

        if (raw['success'] != true) {
          throw AppException(message: raw['error'] ?? 'Failed to fetch service request');
        }

        return ServiceRequestResponseModel.fromJson(raw['data'] as Map<String, dynamic>);
      });
}
