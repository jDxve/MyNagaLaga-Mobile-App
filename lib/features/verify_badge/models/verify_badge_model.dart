
class VerifyBadgeRequest {
  final String residentId;
  final String badgeTypeId;
  final String? submittedByUserProfileId;
  
  // Personal Info
  final String fullName;
  final String birthdate; // Format: YYYY-MM-DD
  final String gender; // "Male" or "Female"
  final String homeAddress;
  final String contactNumber;
  
  // ID Info
  final String? existingSeniorCitizenId;
  final String typeOfId;
  
  // Badge-specific fields (optional, depends on badge type)
  final String? typeOfDisability;
  final int? numberOfDependents;
  final String? estimatedMonthlyHouseholdIncome;
  
  // Student fields (optional, for student badges)
  final String? schoolName;
  final String? educationLevel;
  final String? yearOrGradeLevel;
  final String? schoolIdNumber;

  VerifyBadgeRequest({
    required this.residentId,
    required this.badgeTypeId,
    this.submittedByUserProfileId,
    required this.fullName,
    required this.birthdate,
    required this.gender,
    required this.homeAddress,
    required this.contactNumber,
    this.existingSeniorCitizenId,
    required this.typeOfId,
    this.typeOfDisability,
    this.numberOfDependents,
    this.estimatedMonthlyHouseholdIncome,
    this.schoolName,
    this.educationLevel,
    this.yearOrGradeLevel,
    this.schoolIdNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'residentId': residentId,
      'badgeTypeId': badgeTypeId,
      'submittedByUserProfileId': submittedByUserProfileId,
      'fullName': fullName,
      'birthdate': birthdate,
      'gender': gender,
      'homeAddress': homeAddress,
      'contactNumber': contactNumber,
      'existingSeniorCitizenId': existingSeniorCitizenId,
      'typeOfId': typeOfId,
      'typeOfDisability': typeOfDisability,
      'numberOfDependents': numberOfDependents,
      'estimatedMonthlyHouseholdIncome': estimatedMonthlyHouseholdIncome,
      'schoolName': schoolName,
      'educationLevel': educationLevel,
      'yearOrGradeLevel': yearOrGradeLevel,
      'schoolIdNumber': schoolIdNumber,
    };
  }
}