import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/complaint_model.dart';
import '../services/complaint_service.dart';
import 'complaint_repository.dart';

class ComplaintRepositoryImpl implements ComplaintRepository {
  final ComplaintService _service;

  ComplaintRepositoryImpl({required ComplaintService service}) : _service = service;

  @override
  Future<DataState<List<ComplaintTypeModel>>> getComplaintTypes() async {
    try {
      final response = await _service.getComplaintTypes();
      final raw = response.data;

      if (raw['success'] != true) {
        return DataState.error(error: raw['error'] ?? 'Failed to fetch complaint types');
      }

      final types = (raw['data'] as List<dynamic>)
          .map((json) => ComplaintTypeModel.fromJson(json as Map<String, dynamic>))
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

      final targetPath =
          '${filePath.replaceAll(RegExp(r'\.(jpg|jpeg|png|heic|heif)$'), '')}_compressed.jpg';

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
  Future<DataState<ComplaintResponseModel>> submitComplaint(ComplaintModel complaint) async {
    try {
      final formData = FormData();

      formData.fields.add(MapEntry('complaint_type_id', complaint.complaintTypeId.toString()));

      final subject = complaint.description.length > 100
          ? complaint.description.substring(0, 100)
          : complaint.description;

      formData.fields.add(MapEntry('subject', subject));
      formData.fields.add(MapEntry('description', complaint.description));
      formData.fields.add(MapEntry('is_anonymous', complaint.isAnonymous.toString()));
      formData.fields.add(MapEntry('is_sensitive', complaint.isSensitive.toString()));

      if (complaint.complainantMobileUserId != null) {
        formData.fields.add(MapEntry(
          'complainant_mobile_user_id',
          complaint.complainantMobileUserId.toString(),
        ));
      }

      if (complaint.barangayId != null) {
        formData.fields.add(MapEntry('barangay_id', complaint.barangayId.toString()));
      }

      if (complaint.latitude != null) {
        formData.fields.add(MapEntry('latitude', complaint.latitude.toString()));
      }

      if (complaint.longitude != null) {
        formData.fields.add(MapEntry('longitude', complaint.longitude.toString()));
      }

      if (complaint.filePaths != null && complaint.filePaths!.isNotEmpty) {
        for (final filePath in complaint.filePaths!) {
          final fileToUpload = await _compressImage(filePath);
          if (fileToUpload == null || !await fileToUpload.exists()) continue;

          final mimeType = lookupMimeType(fileToUpload.path) ?? 'image/jpeg';
          final mimeTypeParts = mimeType.split('/');

          formData.files.add(MapEntry(
            'attachments',
            await MultipartFile.fromFile(
              fileToUpload.path,
              filename: fileToUpload.path.split('/').last,
              contentType: MediaType(mimeTypeParts[0], mimeTypeParts[1]),
            ),
          ));
        }
      }

      final response = await _service.submitComplaint(formData);
      final raw = response.data;

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['error'] ?? raw['message'] ?? 'Failed to submit complaint',
        );
      }

      return DataState.success(
        data: ComplaintResponseModel.fromJson(raw['data'] as Map<String, dynamic>),
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