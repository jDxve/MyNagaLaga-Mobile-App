// lib/features/services/models/service_request_model.dart

class ServiceRequestModel {
  final int caseTypeId;
  final String description;
  final int? barangayId;
  final bool isAnonymous;
  final bool isSensitive;
  final List<int>? badgeIds;
  final List<String>? filePaths;

  ServiceRequestModel({
    required this.caseTypeId,
    required this.description,
    this.barangayId,
    this.isAnonymous = false,
    this.isSensitive = false,
    this.badgeIds,
    this.filePaths,
  });

  Map<String, dynamic> toJson() {
    return {
      'case_type_id': caseTypeId,
      'description': description,
      if (barangayId != null) 'barangay_id': barangayId,
      'is_anonymous': isAnonymous,
      'is_sensitive': isSensitive,
      if (badgeIds != null && badgeIds!.isNotEmpty) 'badge_ids': badgeIds,
    };
  }
}

class ServiceRequestResponseModel {
  final int id;
  final String caseCode;
  final String status;
  final DateTime submittedAt;

  ServiceRequestResponseModel({
    required this.id,
    required this.caseCode,
    required this.status,
    required this.submittedAt,
  });

  factory ServiceRequestResponseModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestResponseModel(
      // ✅ FIXED: Safe type conversion
      id: json['id'] is int 
          ? json['id'] as int 
          : int.parse(json['id'].toString()),
      // ✅ FIXED: Use correct JSON field name
      caseCode: json['case_code'] as String,
      status: json['status'] as String,
      // ✅ FIXED: Safe DateTime parsing
      submittedAt: json['submitted_at'] is String
          ? DateTime.parse(json['submitted_at'] as String)
          : json['submitted_at'] as DateTime,
    );
  }
}// lib/features/services/models/service_request_model.dart

class CaseTypeModel {
  final int id;
  final String name;
  final bool requiresPickup;
  final int slaDays;

  CaseTypeModel({
    required this.id,
    required this.name,
    required this.requiresPickup,
    required this.slaDays,
  });

  factory CaseTypeModel.fromJson(Map<String, dynamic> json) {
    return CaseTypeModel(
      // ✅ FIXED: Safe conversion - handles both int and String
      id: json['id'] is int 
          ? json['id'] as int 
          : int.parse(json['id'].toString()),
      name: json['name'] as String,
      requiresPickup: json['requires_pickup'] as bool,
      // ✅ FIXED: Safe conversion - handles both int and String
      slaDays: json['sla_days'] is int 
          ? json['sla_days'] as int 
          : int.parse(json['sla_days'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'requires_pickup': requiresPickup,
      'sla_days': slaDays,
    };
  }
}