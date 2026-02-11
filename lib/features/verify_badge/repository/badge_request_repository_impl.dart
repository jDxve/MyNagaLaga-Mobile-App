import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import '../models/badge_request_model.dart';
import '../services/badge_request_service.dart';
import 'badge_request_repository.dart';
import '../../auth/notifier/auth_session_notifier.dart';

final badgeRequestRepositoryProvider = Provider<BadgeRequestRepository>((ref) {
  final service = ref.read(badgeRequestServiceProvider);
  return BadgeRequestRepositoryImpl(service, ref);
});

class BadgeRequestRepositoryImpl implements BadgeRequestRepository {
  final BadgeRequestService _service;
  final Ref _ref;

  BadgeRequestRepositoryImpl(this._service, this._ref);

  @override
  Future<BadgeRequestData?> submitBadgeRequest({
    required String badgeTypeId,
    required String fullName,
    required String birthdate,
    required String gender,
    required String homeAddress,
    required String contactNumber,
    required String typeOfId,
    String? existingSeniorCitizenId,
    String? typeOfDisability,
    int? numberOfDependents,
    String? estimatedMonthlyHouseholdIncome,
    String? schoolName,
    String? educationLevel,
    String? yearOrGradeLevel,
    String? schoolIdNumber,
    required Map<String, List<File>> uploadedFiles,
  }) async {
    try {
      final authState = _ref.read(authSessionProvider);
      final mobileUserId = authState.userId;
      
      if (mobileUserId == null || mobileUserId.isEmpty) {
        throw Exception('User not authenticated. Please log in again.');
      }

      final formData = FormData();

      formData.fields.addAll([
        MapEntry('mobileUserId', mobileUserId),
        MapEntry('badgeTypeId', badgeTypeId),
        MapEntry('fullName', fullName),
        MapEntry('birthdate', birthdate),
        MapEntry('gender', gender),
        MapEntry('homeAddress', homeAddress),
        MapEntry('contactNumber', contactNumber),
        MapEntry('typeOfId', typeOfId),
      ]);

      if (existingSeniorCitizenId != null && existingSeniorCitizenId.isNotEmpty) {
        formData.fields.add(MapEntry('existingSeniorCitizenId', existingSeniorCitizenId));
      }
      if (typeOfDisability != null && typeOfDisability.isNotEmpty) {
        formData.fields.add(MapEntry('typeOfDisability', typeOfDisability));
      }
      if (numberOfDependents != null) {
        formData.fields.add(MapEntry('numberOfDependents', numberOfDependents.toString()));
      }
      if (estimatedMonthlyHouseholdIncome != null && estimatedMonthlyHouseholdIncome.isNotEmpty) {
        formData.fields.add(MapEntry('estimatedMonthlyHouseholdIncome', estimatedMonthlyHouseholdIncome));
      }
      if (schoolName != null && schoolName.isNotEmpty) {
        formData.fields.add(MapEntry('schoolName', schoolName));
      }
      if (educationLevel != null && educationLevel.isNotEmpty) {
        formData.fields.add(MapEntry('educationLevel', educationLevel));
      }
      if (yearOrGradeLevel != null && yearOrGradeLevel.isNotEmpty) {
        formData.fields.add(MapEntry('yearOrGradeLevel', yearOrGradeLevel));
      }
      if (schoolIdNumber != null && schoolIdNumber.isNotEmpty) {
        formData.fields.add(MapEntry('schoolIdNumber', schoolIdNumber));
      }

      for (var entry in uploadedFiles.entries) {
        final requirementKey = entry.key;
        final files = entry.value;

        for (var file in files) {
          final fileName = file.path.split('/').last;
          final mimeType = _getMimeType(fileName);

          formData.files.add(MapEntry(
            requirementKey,
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
              contentType: MediaType.parse(mimeType),
            ),
          ));
        }
      }

      print('🚀 Submitting badge request...');
      print('📝 Badge Type ID: $badgeTypeId');
      print('👤 Full Name: $fullName');
      print('📸 Files count: ${uploadedFiles.length}');
      
      final response = await _service.submitBadgeRequest(formData);

      print('✅ Response Status: ${response.response.statusCode}');

      if (response.response.statusCode == 201) {
        final Map<String, dynamic> rawData = response.data;
        final badgeResponse = BadgeRequestResponse.fromJson(rawData);
        
        return badgeResponse.data;
      } else {
        throw Exception('Server returned status ${response.response.statusCode}');
      }
    } on DioException catch (e) {

      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required. Please log in again.');
      } else if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data['error'] ?? 'Invalid request data';
        throw Exception(errorMsg);
      } else if (e.response?.statusCode == 409) {
        throw Exception('You already have a pending badge request.');
      }
      
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to submit: $e');
    }
  }

  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      default:
        return 'application/octet-stream';
    }
  }
}