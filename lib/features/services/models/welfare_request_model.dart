// welfare_request_model.dart
class WelfareRequestModel {
  final String postingId;
  final String mobileUserId;
  final String reason;
  final List<int> requirementIds;
  final String? badgeId;
  final List<String>? filePaths; // Add this for uploaded files

  WelfareRequestModel({
    required this.postingId,
    required this.mobileUserId,
    required this.reason,
    required this.requirementIds,
    this.badgeId,
    this.filePaths, // Add this
  });

  Map<String, dynamic> toJson() {
    return {
      'postingId': postingId,
      'mobileUserId': mobileUserId,
      'description': reason,
      'requirementIds': requirementIds,
      if (badgeId != null) 'badgeId': badgeId,
      if (filePaths != null) 'filePaths': filePaths,
    };
  }

  factory WelfareRequestModel.fromJson(Map<String, dynamic> json) {
    return WelfareRequestModel(
      postingId: json['postingId'] ?? '',
      mobileUserId: json['mobileUserId'] ?? '',
      reason: json['description'] ?? json['reason'] ?? '',
      requirementIds: (json['requirementIds'] as List?)?.cast<int>() ?? [],
      badgeId: json['badgeId'],
      filePaths: (json['filePaths'] as List?)?.cast<String>(),
    );
  }
}

class WelfareRequestResponseModel {
  final String id;
  final String mobileUserId;
  final String postingId;
  final String status;
  final DateTime submittedAt;
  final String? remarks;

  WelfareRequestResponseModel({
    required this.id,
    required this.mobileUserId,
    required this.postingId,
    required this.status,
    required this.submittedAt,
    this.remarks,
  });

  factory WelfareRequestResponseModel.fromJson(Map<String, dynamic> json) {
    return WelfareRequestResponseModel(
      id: json['id']?.toString() ?? '',
      mobileUserId: json['mobile_user_id']?.toString() ?? 
                    json['mobileUserId']?.toString() ?? '',
      postingId: json['posting_id']?.toString() ?? 
                 json['postingId']?.toString() ?? '',
      status: json['status'] ?? '',
      submittedAt: json['submitted_at'] != null 
          ? DateTime.parse(json['submitted_at']) 
          : DateTime.now(),
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobileUserId': mobileUserId,
      'postingId': postingId,
      'status': status,
      'submittedAt': submittedAt.toIso8601String(),
      'remarks': remarks,
    };
  }
}