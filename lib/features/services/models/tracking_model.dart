class BarangayInfo {
  final String id;
  final String? name;

  BarangayInfo({required this.id, this.name});

  factory BarangayInfo.fromJson(Map<String, dynamic> json) {
    return BarangayInfo(
      id: json['id'].toString(),
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class ProgramInfo {
  final String id;
  final String? name;

  ProgramInfo({required this.id, this.name});

  factory ProgramInfo.fromJson(Map<String, dynamic> json) {
    return ProgramInfo(
      id: json['id'].toString(),
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class ServiceInfo {
  final String id;
  final String? name;

  ServiceInfo({required this.id, this.name});

  factory ServiceInfo.fromJson(Map<String, dynamic> json) {
    return ServiceInfo(
      id: json['id'].toString(),
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class PaginationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }
}

class TrackingItemModel {
  final String module;
  final String id;
  final String? code;
  final String? title;
  final String? statusRaw;
  final String statusLabel;
  final DateTime? requestedAt;
  final DateTime? updatedAt;
  final BarangayInfo? barangay;
  final Map<String, dynamic>? meta;

  TrackingItemModel({
    required this.module,
    required this.id,
    this.code,
    this.title,
    this.statusRaw,
    required this.statusLabel,
    this.requestedAt,
    this.updatedAt,
    this.barangay,
    this.meta,
  });

  factory TrackingItemModel.fromJson(Map<String, dynamic> json) {
    return TrackingItemModel(
      module: json['module'] as String,
      id: json['id'].toString(),
      code: json['code'] as String?,
      title: json['title'] as String?,
      statusRaw: json['status_raw'] as String?,
      statusLabel: json['status_label'] as String,
      requestedAt: json['requested_at'] != null
          ? DateTime.parse(json['requested_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      barangay: json['barangay'] != null
          ? BarangayInfo.fromJson(json['barangay'] as Map<String, dynamic>)
          : null,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'module': module,
      'id': id,
      'code': code,
      'title': title,
      'status_raw': statusRaw,
      'status_label': statusLabel,
      'requested_at': requestedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'barangay': barangay?.toJson(),
      'meta': meta,
    };
  }
}

class TrackingResponseModel {
  final List<TrackingItemModel> data;
  final PaginationMeta meta;

  TrackingResponseModel({required this.data, required this.meta});

  factory TrackingResponseModel.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List<dynamic>)
        .map((item) => TrackingItemModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return TrackingResponseModel(
      data: dataList,
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}

class BadgeRequestModel {
  final String id;
  final String? code;
  final String? type;
  final String? status;
  final String statusLabel;
  final DateTime? dateRequested;
  final DateTime? reviewedAt;
  final String? reviewNotes;
  final DateTime? updatedAt;

  BadgeRequestModel({
    required this.id,
    this.code,
    this.type,
    this.status,
    required this.statusLabel,
    this.dateRequested,
    this.reviewedAt,
    this.reviewNotes,
    this.updatedAt,
  });

  factory BadgeRequestModel.fromJson(Map<String, dynamic> json) {
    return BadgeRequestModel(
      id: json['id'].toString(),
      code: json['code'] as String?,
      type: json['type'] as String?,
      status: json['status'] as String?,
      statusLabel: json['status_label'] as String,
      dateRequested: json['date_requested'] != null
          ? DateTime.parse(json['date_requested'] as String)
          : null,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      reviewNotes: json['review_notes'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'type': type,
      'status': status,
      'status_label': statusLabel,
      'date_requested': dateRequested?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'review_notes': reviewNotes,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class BadgeRequestsResponseModel {
  final List<BadgeRequestModel> data;
  final PaginationMeta meta;

  BadgeRequestsResponseModel({required this.data, required this.meta});

  factory BadgeRequestsResponseModel.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List<dynamic>)
        .map((item) => BadgeRequestModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return BadgeRequestsResponseModel(
      data: dataList,
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}

class RequirementInfo {
  final String requestId;
  final String requirementId;
  final String status;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? reviewNotes;

  RequirementInfo({
    required this.requestId,
    required this.requirementId,
    required this.status,
    this.submittedAt,
    this.reviewedAt,
    this.reviewNotes,
  });

  factory RequirementInfo.fromJson(Map<String, dynamic> json) {
    return RequirementInfo(
      requestId: json['request_id'].toString(),
      requirementId: json['requirement_id'].toString(),
      status: json['status'] as String,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      reviewNotes: json['review_notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'requirement_id': requirementId,
      'status': status,
      'submitted_at': submittedAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'review_notes': reviewNotes,
    };
  }
}

class ApplicationModel {
  final String postingId;
  final String? postingTitle;
  final String? postingStatus;
  final ProgramInfo? program;
  final ServiceInfo? service;
  final BarangayInfo? barangay;
  final String overallStatus;
  final DateTime? requestedAt;
  final DateTime? lastUpdatedAt;
  final DateTime? reviewedAt;
  final String? reviewedByUserProfileId;
  final String? reviewNotes;
  final List<RequirementInfo> requirements;
  final int requirementsCount;

  ApplicationModel({
    required this.postingId,
    this.postingTitle,
    this.postingStatus,
    this.program,
    this.service,
    this.barangay,
    required this.overallStatus,
    this.requestedAt,
    this.lastUpdatedAt,
    this.reviewedAt,
    this.reviewedByUserProfileId,
    this.reviewNotes,
    required this.requirements,
    required this.requirementsCount,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      postingId: json['posting_id'].toString(),
      postingTitle: json['posting_title'] as String?,
      postingStatus: json['posting_status'] as String?,
      program: json['program'] != null
          ? ProgramInfo.fromJson(json['program'] as Map<String, dynamic>)
          : null,
      service: json['service'] != null
          ? ServiceInfo.fromJson(json['service'] as Map<String, dynamic>)
          : null,
      barangay: json['barangay'] != null
          ? BarangayInfo.fromJson(json['barangay'] as Map<String, dynamic>)
          : null,
      overallStatus: json['overall_status'] as String,
      requestedAt: json['requested_at'] != null
          ? DateTime.parse(json['requested_at'] as String)
          : null,
      lastUpdatedAt: json['last_updated_at'] != null
          ? DateTime.parse(json['last_updated_at'] as String)
          : null,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      reviewedByUserProfileId: json['reviewed_by_user_profile_id'] as String?,
      reviewNotes: json['review_notes'] as String?,
      requirements: (json['requirements'] as List<dynamic>)
          .map((req) => RequirementInfo.fromJson(req as Map<String, dynamic>))
          .toList(),
      requirementsCount: json['requirements_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posting_id': postingId,
      'posting_title': postingTitle,
      'posting_status': postingStatus,
      'program': program?.toJson(),
      'service': service?.toJson(),
      'barangay': barangay?.toJson(),
      'overall_status': overallStatus,
      'requested_at': requestedAt?.toIso8601String(),
      'last_updated_at': lastUpdatedAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'reviewed_by_user_profile_id': reviewedByUserProfileId,
      'review_notes': reviewNotes,
      'requirements': requirements.map((req) => req.toJson()).toList(),
      'requirements_count': requirementsCount,
    };
  }
}

class ApplicationsResponseModel {
  final List<ApplicationModel> data;
  final PaginationMeta meta;

  ApplicationsResponseModel({required this.data, required this.meta});

  factory ApplicationsResponseModel.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List<dynamic>)
        .map((item) => ApplicationModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return ApplicationsResponseModel(
      data: dataList,
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}

class ProgramPostingModel {
  final String postingId;
  final String postingTitle;
  final String overallStatus;
  final DateTime? requestedAt;
  final BarangayInfo? barangay;
  final ServiceInfo? service;

  ProgramPostingModel({
    required this.postingId,
    required this.postingTitle,
    required this.overallStatus,
    this.requestedAt,
    this.barangay,
    this.service,
  });

  factory ProgramPostingModel.fromJson(Map<String, dynamic> json) {
    return ProgramPostingModel(
      postingId: json['posting_id'].toString(),
      postingTitle: json['posting_title'] as String,
      overallStatus: json['overall_status'] as String,
      requestedAt: json['requested_at'] != null
          ? DateTime.parse(json['requested_at'] as String)
          : null,
      barangay: json['barangay'] != null
          ? BarangayInfo.fromJson(json['barangay'] as Map<String, dynamic>)
          : null,
      service: json['service'] != null
          ? ServiceInfo.fromJson(json['service'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posting_id': postingId,
      'posting_title': postingTitle,
      'overall_status': overallStatus,
      'requested_at': requestedAt?.toIso8601String(),
      'barangay': barangay?.toJson(),
      'service': service?.toJson(),
    };
  }
}

class ProgramTrackingModel {
  final ProgramInfo program;
  final int totalApplications;
  final Map<String, int> byStatus;
  final DateTime? lastRequestedAt;
  final List<ProgramPostingModel> postings;

  ProgramTrackingModel({
    required this.program,
    required this.totalApplications,
    required this.byStatus,
    this.lastRequestedAt,
    required this.postings,
  });

  factory ProgramTrackingModel.fromJson(Map<String, dynamic> json) {
    return ProgramTrackingModel(
      program: ProgramInfo.fromJson(json['program'] as Map<String, dynamic>),
      totalApplications: json['total_applications'] as int,
      byStatus: Map<String, int>.from(json['by_status'] as Map),
      lastRequestedAt: json['last_requested_at'] != null
          ? DateTime.parse(json['last_requested_at'] as String)
          : null,
      postings: (json['postings'] as List<dynamic>)
          .map((posting) =>
              ProgramPostingModel.fromJson(posting as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'program': program.toJson(),
      'total_applications': totalApplications,
      'by_status': byStatus,
      'last_requested_at': lastRequestedAt?.toIso8601String(),
      'postings': postings.map((p) => p.toJson()).toList(),
    };
  }
}

class ProgramsTrackingResponseModel {
  final List<ProgramTrackingModel> data;

  ProgramsTrackingResponseModel({required this.data});

  factory ProgramsTrackingResponseModel.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List<dynamic>)
        .map((item) =>
            ProgramTrackingModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return ProgramsTrackingResponseModel(data: dataList);
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class ServicePostingModel {
  final String postingId;
  final String postingTitle;
  final String overallStatus;
  final DateTime? requestedAt;
  final BarangayInfo? barangay;
  final ProgramInfo? program;

  ServicePostingModel({
    required this.postingId,
    required this.postingTitle,
    required this.overallStatus,
    this.requestedAt,
    this.barangay,
    this.program,
  });

  factory ServicePostingModel.fromJson(Map<String, dynamic> json) {
    return ServicePostingModel(
      postingId: json['posting_id'].toString(),
      postingTitle: json['posting_title'] as String,
      overallStatus: json['overall_status'] as String,
      requestedAt: json['requested_at'] != null
          ? DateTime.parse(json['requested_at'] as String)
          : null,
      barangay: json['barangay'] != null
          ? BarangayInfo.fromJson(json['barangay'] as Map<String, dynamic>)
          : null,
      program: json['program'] != null
          ? ProgramInfo.fromJson(json['program'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posting_id': postingId,
      'posting_title': postingTitle,
      'overall_status': overallStatus,
      'requested_at': requestedAt?.toIso8601String(),
      'barangay': barangay?.toJson(),
      'program': program?.toJson(),
    };
  }
}

class ServiceTrackingModel {
  final ServiceInfo service;
  final ProgramInfo program;
  final int totalApplications;
  final Map<String, int> byStatus;
  final DateTime? lastRequestedAt;
  final List<ServicePostingModel> postings;

  ServiceTrackingModel({
    required this.service,
    required this.program,
    required this.totalApplications,
    required this.byStatus,
    this.lastRequestedAt,
    required this.postings,
  });

  factory ServiceTrackingModel.fromJson(Map<String, dynamic> json) {
    return ServiceTrackingModel(
      service: ServiceInfo.fromJson(json['service'] as Map<String, dynamic>),
      program: ProgramInfo.fromJson(json['program'] as Map<String, dynamic>),
      totalApplications: json['total_applications'] as int,
      byStatus: Map<String, int>.from(json['by_status'] as Map),
      lastRequestedAt: json['last_requested_at'] != null
          ? DateTime.parse(json['last_requested_at'] as String)
          : null,
      postings: (json['postings'] as List<dynamic>)
          .map((posting) =>
              ServicePostingModel.fromJson(posting as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service': service.toJson(),
      'program': program.toJson(),
      'total_applications': totalApplications,
      'by_status': byStatus,
      'last_requested_at': lastRequestedAt?.toIso8601String(),
      'postings': postings.map((p) => p.toJson()).toList(),
    };
  }
}

class ServicesTrackingResponseModel {
  final List<ServiceTrackingModel> data;
  final PaginationMeta meta;

  ServicesTrackingResponseModel({required this.data, required this.meta});

  factory ServicesTrackingResponseModel.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List<dynamic>)
        .map((item) =>
            ServiceTrackingModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return ServicesTrackingResponseModel(
      data: dataList,
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}

class ComplaintModel {
  final String id;
  final String? code;
  final String? type;
  final String? subject;
  final String? status;
  final String statusLabel;
  final DateTime? dateRequested;
  final DateTime? updatedAt;
  final BarangayInfo? barangay;

  ComplaintModel({
    required this.id,
    this.code,
    this.type,
    this.subject,
    this.status,
    required this.statusLabel,
    this.dateRequested,
    this.updatedAt,
    this.barangay,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'].toString(),
      code: json['code'] as String?,
      type: json['type'] as String?,
      subject: json['subject'] as String?,
      status: json['status'] as String?,
      statusLabel: json['status_label'] as String,
      dateRequested: json['date_requested'] != null
          ? DateTime.parse(json['date_requested'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      barangay: json['barangay'] != null
          ? BarangayInfo.fromJson(json['barangay'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'type': type,
      'subject': subject,
      'status': status,
      'status_label': statusLabel,
      'date_requested': dateRequested?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'barangay': barangay?.toJson(),
    };
  }
}

class ComplaintsResponseModel {
  final List<ComplaintModel> data;
  final PaginationMeta meta;

  ComplaintsResponseModel({required this.data, required this.meta});

  factory ComplaintsResponseModel.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List<dynamic>)
        .map((item) => ComplaintModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return ComplaintsResponseModel(
      data: dataList,
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}