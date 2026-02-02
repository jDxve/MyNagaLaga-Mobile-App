class HouseholdMemberModel {
  final String id;
  final String? residentId;
  final String? mobileUserId;
  final String firstName;
  final String middleName;
  final String lastName;
  final String suffix;
  final String fullName;
  final String sex;
  final String? birthdate;
  final String relationshipToHead;
  final bool isHead;
  final String status;

  HouseholdMemberModel({
    required this.id,
    this.residentId,
    this.mobileUserId,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.suffix,
    required this.fullName,
    required this.sex,
    this.birthdate,
    required this.relationshipToHead,
    required this.isHead,
    required this.status,
  });

  factory HouseholdMemberModel.fromJson(Map<String, dynamic> json) {
    // Check if member is linked via residents or mobile_users
    final resident = json['residents'] as Map<String, dynamic>?;
    final mobileUser = json['mobile_users'] as Map<String, dynamic>?;

    String firstName = '';
    String middleName = '';
    String lastName = '';
    String suffix = '';
    String sex = '';
    String? birthdate;

    if (resident != null) {
      // Use resident data
      firstName = resident['first_name'] ?? '';
      middleName = resident['middle_name'] ?? '';
      lastName = resident['last_name'] ?? '';
      suffix = resident['suffix'] ?? '';
      sex = resident['sex'] ?? '';
      birthdate = resident['birthdate'];
    } else if (mobileUser != null) {
      // Use mobile_users data - parse full_name
      final fullName = mobileUser['full_name'] ?? '';
      final nameParts = fullName.split(' ');
      firstName = nameParts.isNotEmpty ? nameParts.first : '';
      lastName = nameParts.length > 1 ? nameParts.last : '';
      sex = ''; // mobile_users has 'sex' field too if needed
    }

    final fullName = '$firstName $middleName $lastName $suffix'.trim();

    return HouseholdMemberModel(
      id: json['id'].toString(),
      residentId: json['resident_id']?.toString(),
      mobileUserId: json['mobile_user_id']?.toString(),
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      suffix: suffix,
      fullName: fullName.isNotEmpty ? fullName : 'Unknown',
      sex: sex,
      birthdate: birthdate,
      relationshipToHead: json['relationship_to_head'] ?? 'Other',
      isHead: json['is_head'] ?? false,
      status: json['status'] ?? 'Pending',
    );
  }

  String get displayName => fullName;
  
  String get roleLabel => relationshipToHead;
  
  bool get isActive => status == 'Active';
  
  bool get isPending => status == 'Pending';
}