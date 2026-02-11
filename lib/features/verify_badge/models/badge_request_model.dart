class BadgeRequestResponse {
  final bool success;
  final BadgeRequestData data;

  BadgeRequestResponse({
    required this.success,
    required this.data,
  });

  factory BadgeRequestResponse.fromJson(Map<String, dynamic> json) {
    return BadgeRequestResponse(
      success: json['success'] ?? false,
      data: BadgeRequestData.fromJson(json['data'] ?? {}),
    );
  }
}

class BadgeRequestData {
  final String id;
  final String badgeRequestCode;
  final String status;
  final String mobileUserId;
  final String badgeTypeId;
  final DateTime submittedAt;
  final BadgeTypeInfo? badgeType;
  final BadgeRequestInfo? info;

  BadgeRequestData({
    required this.id,
    required this.badgeRequestCode,
    required this.status,
    required this.mobileUserId,
    required this.badgeTypeId,
    required this.submittedAt,
    this.badgeType,
    this.info,
  });

  factory BadgeRequestData.fromJson(Map<String, dynamic> json) {
    return BadgeRequestData(
      id: json['id']?.toString() ?? '',
      badgeRequestCode: json['badgeRequestCode'] ?? json['badge_request_code'] ?? '',
      status: json['status'] ?? 'Pending',
      mobileUserId: json['mobile_user_id']?.toString() ?? '',
      badgeTypeId: json['badge_type_id']?.toString() ?? '',
      submittedAt: json['submitted_at'] != null 
          ? DateTime.parse(json['submitted_at'])
          : DateTime.now(),
      badgeType: json['badgeType'] != null 
          ? BadgeTypeInfo.fromJson(json['badgeType']) 
          : null,
      info: json['info'] != null 
          ? BadgeRequestInfo.fromJson(json['info']) 
          : null,
    );
  }
}

class BadgeTypeInfo {
  final String id;
  final String name;

  BadgeTypeInfo({
    required this.id,
    required this.name,
  });

  factory BadgeTypeInfo.fromJson(Map<String, dynamic> json) {
    return BadgeTypeInfo(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
    );
  }
}

class BadgeRequestInfo {
  final String fullName;
  final String birthdate;
  final String gender;
  final String homeAddress;
  final String contactNumber;

  BadgeRequestInfo({
    required this.fullName,
    required this.birthdate,
    required this.gender,
    required this.homeAddress,
    required this.contactNumber,
  });

  factory BadgeRequestInfo.fromJson(Map<String, dynamic> json) {
    return BadgeRequestInfo(
      fullName: json['full_name'] ?? '',
      birthdate: json['birthdate']?.toString() ?? '',
      gender: json['gender'] ?? '',
      homeAddress: json['home_address'] ?? '',
      contactNumber: json['contact_number'] ?? '',
    );
  }
}