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
    final json = <String, dynamic>{
      'mobileUserId': residentId, // Fixed: matches server expectation
      'badgeTypeId': badgeTypeId,
      'fullName': fullName,
      'birthdate': birthdate,
      'gender': gender,
      'homeAddress': homeAddress,
      'contactNumber': contactNumber,
      'typeOfId': typeOfId,
    };

    // Only include optional fields if they have values
    if (submittedByUserProfileId != null) {
      json['submittedByUserProfileId'] = submittedByUserProfileId;
    }
    if (existingSeniorCitizenId != null) {
      json['existingSeniorCitizenId'] = existingSeniorCitizenId;
    }
    if (typeOfDisability != null) {
      json['typeOfDisability'] = typeOfDisability;
    }
    if (numberOfDependents != null) {
      json['numberOfDependents'] = numberOfDependents;
    }
    if (estimatedMonthlyHouseholdIncome != null) {
      json['estimatedMonthlyHouseholdIncome'] = estimatedMonthlyHouseholdIncome;
    }
    if (schoolName != null) {
      json['schoolName'] = schoolName;
    }
    if (educationLevel != null) {
      json['educationLevel'] = educationLevel;
    }
    if (yearOrGradeLevel != null) {
      json['yearOrGradeLevel'] = yearOrGradeLevel;
    }
    if (schoolIdNumber != null) {
      json['schoolIdNumber'] = schoolIdNumber;
    }

    return json;
  }

  // Factory constructor for creating from JSON
  factory VerifyBadgeRequest.fromJson(Map<String, dynamic> json) {
    return VerifyBadgeRequest(
      residentId: json['residentId'] ?? json['mobileUserId'],
      badgeTypeId: json['badgeTypeId'],
      submittedByUserProfileId: json['submittedByUserProfileId'],
      fullName: json['fullName'],
      birthdate: json['birthdate'],
      gender: json['gender'],
      homeAddress: json['homeAddress'],
      contactNumber: json['contactNumber'],
      existingSeniorCitizenId: json['existingSeniorCitizenId'],
      typeOfId: json['typeOfId'],
      typeOfDisability: json['typeOfDisability'],
      numberOfDependents: json['numberOfDependents'],
      estimatedMonthlyHouseholdIncome: json['estimatedMonthlyHouseholdIncome'],
      schoolName: json['schoolName'],
      educationLevel: json['educationLevel'],
      yearOrGradeLevel: json['yearOrGradeLevel'],
      schoolIdNumber: json['schoolIdNumber'],
    );
  }

  // CopyWith method for easy updates
  VerifyBadgeRequest copyWith({
    String? residentId,
    String? badgeTypeId,
    String? submittedByUserProfileId,
    String? fullName,
    String? birthdate,
    String? gender,
    String? homeAddress,
    String? contactNumber,
    String? existingSeniorCitizenId,
    String? typeOfId,
    String? typeOfDisability,
    int? numberOfDependents,
    String? estimatedMonthlyHouseholdIncome,
    String? schoolName,
    String? educationLevel,
    String? yearOrGradeLevel,
    String? schoolIdNumber,
  }) {
    return VerifyBadgeRequest(
      residentId: residentId ?? this.residentId,
      badgeTypeId: badgeTypeId ?? this.badgeTypeId,
      submittedByUserProfileId:
          submittedByUserProfileId ?? this.submittedByUserProfileId,
      fullName: fullName ?? this.fullName,
      birthdate: birthdate ?? this.birthdate,
      gender: gender ?? this.gender,
      homeAddress: homeAddress ?? this.homeAddress,
      contactNumber: contactNumber ?? this.contactNumber,
      existingSeniorCitizenId:
          existingSeniorCitizenId ?? this.existingSeniorCitizenId,
      typeOfId: typeOfId ?? this.typeOfId,
      typeOfDisability: typeOfDisability ?? this.typeOfDisability,
      numberOfDependents: numberOfDependents ?? this.numberOfDependents,
      estimatedMonthlyHouseholdIncome: estimatedMonthlyHouseholdIncome ??
          this.estimatedMonthlyHouseholdIncome,
      schoolName: schoolName ?? this.schoolName,
      educationLevel: educationLevel ?? this.educationLevel,
      yearOrGradeLevel: yearOrGradeLevel ?? this.yearOrGradeLevel,
      schoolIdNumber: schoolIdNumber ?? this.schoolIdNumber,
    );
  }
}