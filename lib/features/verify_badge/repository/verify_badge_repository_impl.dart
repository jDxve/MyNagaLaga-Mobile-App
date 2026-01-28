import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../services/verify_badge_service.dart';
import 'verify_badge_repository.dart';

final verifyBadgeRepositoryProvider =
    Provider.autoDispose<VerifyBadgeRepositoryImpl>((ref) {
  final service = ref.watch(verifyBadgeServiceProvider);
  return VerifyBadgeRepositoryImpl(service: service);
});

class VerifyBadgeRepositoryImpl implements VerifyBadgeRepository {
  final VerifyBadgeService _service;

  VerifyBadgeRepositoryImpl({required VerifyBadgeService service})
      : _service = service;

  @override
  Future<DataState<dynamic>> submitBadgeApplication({
    required String mobileUserId,
    required String badgeTypeId,
    required String fullName,
    required String birthdate,
    required String gender,
    required String homeAddress,
    required String contactNumber,
    required String typeOfId,
    required File frontId,
    required File backId,
    File? supportingFile,
    String? submittedByUserProfileId,
    String? existingSeniorCitizenId,
    String? typeOfDisability,
    int? numberOfDependents,
    String? estimatedMonthlyHouseholdIncome,
    String? schoolName,
    String? educationLevel,
    String? yearOrGradeLevel,
    String? schoolIdNumber,
  }) async {
    try {
      print('🚀 Repository: Starting submission');
      print('📋 mobileUserId: $mobileUserId');
      print('📋 badgeTypeId: $badgeTypeId');
      print('📋 fullName: $fullName');
      print('📋 birthdate: $birthdate');
      print('📋 gender: $gender');
      
      final frontIdMultipart = await MultipartFile.fromFile(
        frontId.path,
        filename: frontId.path.split('/').last,
      );
      print('✅ Front ID: ${frontIdMultipart.filename}');

      final backIdMultipart = await MultipartFile.fromFile(
        backId.path,
        filename: backId.path.split('/').last,
      );
      print('✅ Back ID: ${backIdMultipart.filename}');

      MultipartFile? supportingFileMultipart;
      if (supportingFile != null) {
        supportingFileMultipart = await MultipartFile.fromFile(
          supportingFile.path,
          filename: supportingFile.path.split('/').last,
        );
        print('✅ Supporting: ${supportingFileMultipart.filename}');
      }

      print('🌐 Calling service...');
      final response = await _service.createBadgeApplication(
        mobileUserId: mobileUserId,
        badgeTypeId: badgeTypeId,
        submittedByUserProfileId: submittedByUserProfileId,
        fullName: fullName,
        birthdate: birthdate,
        gender: gender,
        homeAddress: homeAddress,
        contactNumber: contactNumber,
        existingSeniorCitizenId: existingSeniorCitizenId,
        typeOfId: typeOfId,
        typeOfDisability: typeOfDisability,
        numberOfDependents: numberOfDependents,
        estimatedMonthlyHouseholdIncome: estimatedMonthlyHouseholdIncome,
        schoolName: schoolName,
        educationLevel: educationLevel,
        yearOrGradeLevel: yearOrGradeLevel,
        schoolIdNumber: schoolIdNumber,
        frontId: frontIdMultipart,
        backId: backIdMultipart,
        supportingFile: supportingFileMultipart,
      );

      print('📡 Response Status: ${response.response.statusCode}');
      print('📦 Response Data: ${response.data}');
      print('📦 Response Headers: ${response.response.headers}');

      if (response.response.statusCode == 201 ||
          response.response.statusCode == 200) {
        print('✅ SUCCESS!');
        return DataState.success(data: response.data);
      }

      print('❌ Non-success status code');
      return DataState.error(error: 'Failed to submit badge application');
    } on DioException catch (e) {
      print('❌ DIO EXCEPTION');
      print('❌ Type: ${e.type}');
      print('❌ Message: ${e.message}');
      print('❌ Response Status: ${e.response?.statusCode}');
      print('❌ Response Data: ${e.response?.data}');
      
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic>) {
          final errorMsg = errorData['error'] ?? 'Server error occurred';
          return DataState.error(error: errorMsg);
        }
      }
      return DataState.error(error: e.message ?? 'Network error occurred');
    } catch (e, stack) {
      print('❌ UNEXPECTED ERROR: $e');
      print('❌ Stack: $stack');
      return DataState.error(error: 'An unexpected error occurred');
    }
  }
}