// lib/features/services/repository/complaint_repository_impl.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // Add this package
import '../../../common/models/dio/data_state.dart';
import '../models/complaint_model.dart';
import '../services/complaint_service.dart';
import 'complaint_repository.dart';

class ComplaintRepositoryImpl implements ComplaintRepository {
  final ComplaintService _service;

  ComplaintRepositoryImpl({required ComplaintService service})
      : _service = service;

  @override
  Future<DataState<List<ComplaintTypeModel>>> getComplaintTypes() async {
    try {
      debugPrint('📤 Fetching complaint types');
      final response = await _service.getComplaintTypes();
      final raw = response.data;
      debugPrint('📥 Response: $raw');

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['error'] ?? 'Failed to fetch complaint types',
        );
      }

      final List<dynamic> typesJson = raw['data'] as List<dynamic>;
      final types = typesJson
          .map((json) =>
              ComplaintTypeModel.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('✅ Loaded ${types.length} complaint types');
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
                'Failed to fetch complaint types';
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
  Future<DataState<ComplaintResponseModel>> submitComplaint(
    ComplaintModel complaint,
  ) async {
    try {
      debugPrint('📤 Submitting complaint');
      debugPrint('   Type ID: ${complaint.complaintTypeId}');
      debugPrint('   Description: ${complaint.description}');
      debugPrint('   Files: ${complaint.filePaths?.length ?? 0}');

      final formData = FormData();

      formData.fields.add(
        MapEntry('complaint_type_id', complaint.complaintTypeId.toString()),
      );

      final subject = complaint.description.length > 100
          ? complaint.description.substring(0, 100)
          : complaint.description;

      formData.fields.add(MapEntry('subject', subject));
      formData.fields.add(MapEntry('description', complaint.description));

      formData.fields.add(
        MapEntry('is_anonymous', complaint.isAnonymous.toString()),
      );

      formData.fields.add(
        MapEntry('is_sensitive', complaint.isSensitive.toString()),
      );

      if (complaint.complainantMobileUserId != null) {
        formData.fields.add(
          MapEntry(
            'complainant_mobile_user_id',
            complaint.complainantMobileUserId.toString(),
          ),
        );
      }

      if (complaint.barangayId != null) {
        formData.fields.add(
          MapEntry('barangay_id', complaint.barangayId.toString()),
        );
      }

      if (complaint.latitude != null) {
        formData.fields.add(
          MapEntry('latitude', complaint.latitude.toString()),
        );
      }

      if (complaint.longitude != null) {
        formData.fields.add(
          MapEntry('longitude', complaint.longitude.toString()),
        );
      }

      // ✅ OPTIMIZED: Compress and add files
      if (complaint.filePaths != null && complaint.filePaths!.isNotEmpty) {
        for (int i = 0; i < complaint.filePaths!.length; i++) {
          final filePath = complaint.filePaths![i];
          
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
              'attachments',
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
      final response = await _service.submitComplaint(formData);
      final raw = response.data;
      debugPrint('📥 Response received: $raw');

      if (raw['success'] != true) {
        debugPrint('❌ Server returned success=false');
        debugPrint('   Error: ${raw['error']}');
        return DataState.error(
          error: raw['error'] ?? 'Failed to submit complaint',
        );
      }

      final responseData = ComplaintResponseModel.fromJson(
        raw['data'] as Map<String, dynamic>,
      );

      debugPrint('✅ Complaint submitted successfully');
      debugPrint('   Complaint Code: ${responseData.complaintCode}');
      return DataState.success(data: responseData);
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.response?.statusCode} - ${e.message}');
      debugPrint('❌ Response data: ${e.response?.data}');

      if (e.response?.statusCode == 404) {
        return const DataState.error(error: 'Complaint endpoint not found.');
      }

      if (e.response?.data != null) {
        try {
          final errorData = e.response!.data;
          debugPrint('❌ Error response type: ${errorData.runtimeType}');
          debugPrint('❌ Error response content: $errorData');

          if (errorData is Map<String, dynamic>) {
            final errorMessage = errorData['error'] ??
                errorData['message'] ??
                'Failed to submit complaint';
            return DataState.error(error: errorMessage);
          } else if (errorData is String) {
            return DataState.error(error: errorData);
          }
        } catch (parseError) {
          debugPrint('❌ Error parsing error response: $parseError');
        }
      }

      return DataState.error(error: e.message ?? 'Network error occurred');
    } catch (e) {
      debugPrint('❌ Unexpected Error: $e');
      return DataState.error(error: 'Unexpected error: $e');
    }
  }
}