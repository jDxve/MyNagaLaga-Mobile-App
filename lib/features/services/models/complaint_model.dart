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
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      complaintCode: json['complaint_code'] as String,
      status: json['status'] as String,
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
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}