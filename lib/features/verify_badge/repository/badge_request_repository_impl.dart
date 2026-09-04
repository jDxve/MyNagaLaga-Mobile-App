import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mynagalaga_mobile_app/core/network/app_exception.dart';
import 'package:mynagalaga_mobile_app/core/network/repository_guard.dart';
import 'package:mynagalaga_mobile_app/features/verify_badge/models/badge_request_model.dart';
import 'package:mynagalaga_mobile_app/features/verify_badge/services/badge_request_service.dart';
import 'package:mynagalaga_mobile_app/features/verify_badge/repository/badge_request_repository.dart';
import 'package:mynagalaga_mobile_app/features/auth/notifier/auth_session_notifier.dart';

final badgeRequestRepositoryProvider = Provider<BadgeRequestRepository>((ref) {
  final service = ref.read(badgeRequestServiceProvider);
  return BadgeRequestRepositoryImpl(service, ref);
});

class BadgeRequestRepositoryImpl
    with RepositoryGuard
    implements BadgeRequestRepository {
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
  }) =>
      guardThrow(
        () async {
          final authState = _ref.read(authSessionProvider);
          final mobileUserId = authState.userId;

          if (mobileUserId == null || mobileUserId.isEmpty) {
            throw const AppException(message: 'User not authenticated. Please log in again.');
          }

          // Client-side validation before sending
          if (gender.isEmpty) {
            throw const AppException(message: 'Gender is required.');
          }
          if (typeOfId.isEmpty) {
            throw const AppException(message: 'ID type is required.');
          }
          if (birthdate.isEmpty) {
            throw const AppException(message: 'Birthdate is required.');
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
          if (estimatedMonthlyHouseholdIncome != null &&
              estimatedMonthlyHouseholdIncome.isNotEmpty) {
            formData.fields.add(
              MapEntry('estimatedMonthlyHouseholdIncome', estimatedMonthlyHouseholdIncome),
            );
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

          final response = await _service.submitBadgeRequest(formData);

          if (response.response.statusCode != 201) {
            throw AppException(message: 'Server returned status ${response.response.statusCode}');
          }

          final Map<String, dynamic> rawData = response.data;
          final badgeResponse = BadgeRequestResponse.fromJson(rawData);
          return badgeResponse.data;
        },
        mapError: (e) {
          if (e.response?.statusCode == 400) {
            final data = e.response?.data;
            if (data?['details'] != null) {
              final issues = (data['details'] as List).map((i) {
                final path = (i['path'] as List?)?.join('.') ?? 'unknown';
                final message = i['message'] ?? 'Invalid value';
                return '$path: $message';
              }).join('\n');
              return AppException(
                statusCode: 400,
                type: AppErrorType.validation,
                message: 'Please check your input:\n$issues',
              );
            }
            return AppException(statusCode: 400, message: data?['error'] ?? 'Invalid request data');
          }
          if (e.response?.statusCode == 401) {
            return const AppException(
              statusCode: 401,
              message: 'Authentication required. Please log in again.',
            );
          }
          if (e.response?.statusCode == 409) {
            return const AppException(
              statusCode: 409,
              message: 'You already have a pending badge request.',
            );
          }
          return AppException(message: 'Network error: ${e.message}');
        },
      );

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
