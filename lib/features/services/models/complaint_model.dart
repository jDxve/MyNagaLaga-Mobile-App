// lib/features/services/models/complaint_model.dart

class ComplaintModel {
  final int complaintTypeId;
  final int? complainantMobileUserId;
  final int? barangayId;
  final String description;
  final bool isAnonymous;
  final bool isSensitive;
  final double? latitude;
  final double? longitude;
  final List<String>? filePaths;

  ComplaintModel({
    required this.complaintTypeId,
    this.complainantMobileUserId,
    this.barangayId,
    required this.description,
    this.isAnonymous = false,
    this.isSensitive = false,
    this.latitude,
    this.longitude,
    this.filePaths,
  });

  Map<String, dynamic> toJson() {
    return {
      'complaint_type_id': complaintTypeId,
      if (complainantMobileUserId != null)
        'complainant_mobile_user_id': complainantMobileUserId,
      if (barangayId != null) 'barangay_id': barangayId,
      'description': description,
      'is_anonymous': isAnonymous,
      'is_sensitive': isSensitive,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}

class ComplaintResponseModel {
  final int id;
  final String complaintCode;
  final String status;
  final DateTime submittedAt;

  ComplaintResponseModel({
    required this.id,
    required this.complaintCode,
    required this.status,
    required this.submittedAt,
  });

  factory ComplaintResponseModel.fromJson(Map<String, dynamic> json) {
    return ComplaintResponseModel(
      // ✅ FIXED: Safe type conversion
      id: json['id'] is int 
          ? json['id'] as int 
          : int.parse(json['id'].toString()),
      // ✅ FIXED: Use correct JSON field name
      complaintCode: json['complaint_code'] as String,
      status: json['status'] as String,
      // ✅ FIXED: Safe DateTime parsing
      submittedAt: json['submitted_at'] is String
          ? DateTime.parse(json['submitted_at'] as String)
          : json['submitted_at'] as DateTime,
    );
  }
}

class ComplaintTypeModel {
  final int id;
  final String name;
  final String? description;

  ComplaintTypeModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory ComplaintTypeModel.fromJson(Map<String, dynamic> json) {
    return ComplaintTypeModel(
      id: json['id'] is int 
          ? json['id'] as int 
          : int.parse(json['id'].toString()),
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}