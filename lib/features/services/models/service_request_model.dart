class CaseTypeModel {
  final int id;
  final String name;
  final bool requiresPickup;
  final int? slaDays;

  CaseTypeModel({
    required this.id,
    required this.name,
    required this.requiresPickup,
    this.slaDays,
  });

  factory CaseTypeModel.fromJson(Map<String, dynamic> json) {
    return CaseTypeModel(
      id: _recursiveParseInt(json['id']),
      name: json['name'] as String,
      requiresPickup: json['requires_pickup'] as bool? ?? false,
      slaDays: json['sla_days'] == null
          ? null
          : _recursiveParseInt(json['sla_days']),
    );
  }

  static int _recursiveParseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    }
    return 0;
  }
}

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
}

class ServiceRequestResponseModel {
  final String id;
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
      id: json['id'].toString(), // always convert to String — safe for BigInt
      caseCode: json['case_code'] as String,
      status: json['status'] as String,
      submittedAt: json['submitted_at'] is String
          ? DateTime.parse(json['submitted_at'] as String)
          : json['submitted_at'] as DateTime,
    );
  }
}
