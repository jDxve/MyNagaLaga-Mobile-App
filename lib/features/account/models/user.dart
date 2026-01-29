class User {
  final String id;
  final String email;
  final String? fullName;
  final String? sex;
  final String? address;
  final String? phoneNumber;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    this.fullName,
    this.sex,
    this.address,
    this.phoneNumber,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['auth_user_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'],
      sex: json['sex'],
      address: json['address'],
      phoneNumber: json['phone_number'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'sex': sex,
      'address': address,
      'phone_number': phoneNumber,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}