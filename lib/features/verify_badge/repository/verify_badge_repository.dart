import 'dart:io';
import '../../../common/models/dio/data_state.dart';

abstract class VerifyBadgeRepository {
  /// Submit a badge application
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
  });
}