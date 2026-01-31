class UserBadgeInfo {
  final String fullName;
  final String age;
  final DateTime birthdate;
  final String gender;
  final String homeAddress;
  final String contactNumber;
  final String? schoolName;
  final String? educationLevel;
  final String? yearOrGradeLevel;
  final String? schoolIdNumber;

  UserBadgeInfo({
    required this.fullName,
    required this.age,
    required this.birthdate,
    required this.gender,
    required this.homeAddress,
    required this.contactNumber,
    this.schoolName,
    this.educationLevel,
    this.yearOrGradeLevel,
    this.schoolIdNumber,
  });

  factory UserBadgeInfo.fromJson(Map<String, dynamic> json) {
    return UserBadgeInfo(
      fullName: json['fullName'] ?? '',
      age: json['age']?.toString() ?? '0',
      birthdate: DateTime.parse(json['birthdate']),
      gender: json['gender'] ?? '',
      homeAddress: json['homeAddress'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      schoolName: json['schoolName'],
      educationLevel: json['educationLevel'],
      yearOrGradeLevel: json['yearOrGradeLevel'],
      schoolIdNumber: json['schoolIdNumber'],
    );
  }
}