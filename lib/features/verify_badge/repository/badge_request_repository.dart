import 'dart:io';
import '../models/badge_request_model.dart';

abstract class BadgeRequestRepository {
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
  });
}