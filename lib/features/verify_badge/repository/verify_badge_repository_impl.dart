import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/models/responses/error_response.dart';
import '../services/verify_badge_service.dart';
import 'verify_badge_repository.dart';

final verifyBadgeRepositoryProvider =
    Provider.autoDispose<VerifyBadgeRepositoryImpl>((ref) {
  final service = ref.watch(verifyBadgeServiceProvider);
  return VerifyBadgeRepositoryImpl(service: service);
});

class VerifyBadgeRepositoryImpl implements VerifyBadgeRepository {
  final VerifyBadgeService _service;

  VerifyBadgeRepositoryImpl({
    required VerifyBadgeService service,
  }) : _service = service;

  @override
  Future<DataState<dynamic>> submitBadgeApplication({
    required String residentId,
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
    DataState<dynamic> data;
    
    try {
      final response = await _service.createBadgeApplication(
        residentId: residentId,
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
        frontId: frontId,
        backId: backId,
        supportingFile: supportingFile,
      );

      // Check if successful
      if (response.response.statusCode == 201) {
        data = DataState.success(data: response.data);
      } else {
        // Parse error response
        final errorResponse = ErrorResponse.fromMap(
          response.data as Map<String, dynamic>,
        );
        data = DataState.error(
          error: errorResponse.message ?? 'Failed to submit badge application',
        );
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      if (e.response != null) {
        final errorResponse = ErrorResponse.fromMap(
          e.response?.data as Map<String, dynamic>,
        );
        data = DataState.error(
          error: errorResponse.message ?? 'An error occurred',
        );
      } else {
        data = DataState.error(
          error: e.message ?? 'Network error occurred',
        );
      }
    } catch (e) {
      // Handle any other errors
      data = DataState.error(error: 'An unexpected error occurred: $e');
    }
    
    return data;
  }
}