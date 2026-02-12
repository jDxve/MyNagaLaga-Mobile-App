class HouseholdMember {
  final String id;
  final String householdId;
  final String? residentId;
  final String relationshipToHead;
  final bool isHead;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ResidentInfo? residents;

  HouseholdMember({
    required this.id,
    required this.householdId,
    this.residentId,
    required this.relationshipToHead,
    required this.isHead,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.residents,
  });

  factory HouseholdMember.fromJson(Map<String, dynamic> json) =>
      HouseholdMember(
        id: json['id']?.toString() ?? '',
        householdId: json['household_id']?.toString() ?? '',
        residentId: json['resident_id']?.toString(),
        relationshipToHead: json['relationship_to_head'] ?? '',
        isHead: json['is_head'] ?? false,
        status: json['status'] ?? '',
        createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
        residents: json['residents'] != null
            ? ResidentInfo.fromJson(json['residents'])
            : null,
      );

  String get fullName {
    if (residents == null) return 'Unknown';
    final middle = residents!.middleName != null ? ' ${residents!.middleName}' : '';
    final suffix = residents!.suffix != null ? ' ${residents!.suffix}' : '';
    return '${residents!.firstName}$middle ${residents!.lastName}$suffix'.trim();
  }
}

class ResidentInfo {
  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? suffix;
  final DateTime birthdate;
  final String? sex;
  final String barangayOfOriginId;

  ResidentInfo({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.suffix,
    required this.birthdate,
    this.sex,
    required this.barangayOfOriginId,
  });

  factory ResidentInfo.fromJson(Map<String, dynamic> json) => ResidentInfo(
        id: json['id']?.toString() ?? '',
        firstName: json['first_name'] ?? '',
        middleName: json['middle_name'],
        lastName: json['last_name'] ?? '',
        suffix: json['suffix'],
        birthdate: DateTime.parse(json['birthdate'] ?? DateTime.now().toIso8601String()),
        sex: json['sex'],
        barangayOfOriginId: json['barangay_of_origin_id']?.toString() ?? '',
      );
}

class Barangay {
  final String id;
  final String name;

  Barangay({
    required this.id,
    required this.name,
  });

  factory Barangay.fromJson(Map<String, dynamic> json) => Barangay(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
      );
}

class Household {
  final String id;
  final String barangayId;
  final String householdCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Barangay barangays;
  final List<HouseholdMember> householdMembers;
  final String myRelationship;
  final String myStatus;
  final bool isHouseholdHead;
  final String? myMemberId; 

  Household({
    required this.id,
    required this.barangayId,
    required this.householdCode,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.barangays,
    required this.householdMembers,
    required this.myRelationship,
    required this.myStatus,
    required this.isHouseholdHead,
    this.myMemberId, 
  });

  factory Household.fromJson(Map<String, dynamic> json) => Household(
        id: json['id']?.toString() ?? '',
        barangayId: json['barangay_id']?.toString() ?? '',
        householdCode: json['household_code'] ?? '',
        createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
        deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
        barangays: Barangay.fromJson(json['barangays'] ?? {}),
        householdMembers: (json['household_members'] as List<dynamic>?)
                ?.map((item) => HouseholdMember.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [],
        myRelationship: json['my_relationship'] ?? '',
        myStatus: json['my_status'] ?? '',
        isHouseholdHead: json['is_household_head'] ?? false,
        myMemberId: json['my_member_id']?.toString(), // ⭐ Add this
      );

  int get memberCount => householdMembers.length;

  HouseholdMember? get head => householdMembers.firstWhere(
        (member) => member.isHead,
        orElse: () => householdMembers.first,
      );
}

class HouseholdResponse {
  final bool success;
  final String message;
  final Household? data;

  HouseholdResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory HouseholdResponse.fromJson(Map<String, dynamic> json) =>
      HouseholdResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] != null ? Household.fromJson(json['data']) : null,
      );
}