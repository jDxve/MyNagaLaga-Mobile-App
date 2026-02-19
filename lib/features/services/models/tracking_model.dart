class BarangayInfo {
  final String id;
  final String? name;

  const BarangayInfo({required this.id, this.name});

  factory BarangayInfo.fromJson(Map<String, dynamic> json) => BarangayInfo(
        id: json['id'].toString(),
        name: json['name'] as String?,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class ProgramInfo {
  final String id;
  final String? name;

  const ProgramInfo({required this.id, this.name});

  factory ProgramInfo.fromJson(Map<String, dynamic> json) => ProgramInfo(
        id: json['id'].toString(),
        name: json['name'] as String?,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class ServiceInfo {
  final String id;
  final String? name;

  const ServiceInfo({required this.id, this.name});

  factory ServiceInfo.fromJson(Map<String, dynamic> json) => ServiceInfo(
        id: json['id'].toString(),
        name: json['name'] as String?,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class PaginationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
        total: (json['total'] as num).toInt(),
        page: (json['page'] as num).toInt(),
        limit: (json['limit'] as num).toInt(),
        totalPages: (json['totalPages'] as num).toInt(),
      );
}

// ─── Unified Feed ─────────────────────────────────────────────────────────────

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
  final bool hasRated;

  const TrackingItemModel({
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
    this.hasRated = false,
  });

  factory TrackingItemModel.fromJson(Map<String, dynamic> json) =>
      TrackingItemModel(
        module: json['module'] as String,
        id: json['id'].toString(),
        code: json['code'] as String?,
        title: json['title'] as String?,
        statusRaw: json['status_raw'] as String?,
        statusLabel: (json['status_label'] as String?) ?? '',
        requestedAt: json['requested_at'] != null
            ? DateTime.tryParse(json['requested_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
        barangay: json['barangay'] != null
            ? BarangayInfo.fromJson(json['barangay'] as Map<String, dynamic>)
            : null,
        meta: json['meta'] as Map<String, dynamic>?,
        hasRated: json['has_rated'] as bool? ?? false,
      );

  TrackingItemModel copyWith({bool? hasRated}) => TrackingItemModel(
        module: module,
        id: id,
        code: code,
        title: title,
        statusRaw: statusRaw,
        statusLabel: statusLabel,
        requestedAt: requestedAt,
        updatedAt: updatedAt,
        barangay: barangay,
        meta: meta,
        hasRated: hasRated ?? this.hasRated,
      );
}

// ─── Programs ────────────────────────────────────────────────────────────────

class ProgramPostingModel {
  final String postingId;
  final String postingTitle;
  final String overallStatus;
  final DateTime? requestedAt;
  final BarangayInfo? barangay;
  final ServiceInfo? service;
  final bool hasRated;

  const ProgramPostingModel({
    required this.postingId,
    required this.postingTitle,
    required this.overallStatus,
    this.requestedAt,
    this.barangay,
    this.service,
    this.hasRated = false,
  });

  factory ProgramPostingModel.fromJson(Map<String, dynamic> json) =>
      ProgramPostingModel(
        postingId: json['posting_id'].toString(),
        postingTitle: (json['posting_title'] as String?) ?? '',
        overallStatus: (json['overall_status'] as String?) ?? '',
        requestedAt: json['requested_at'] != null
            ? DateTime.tryParse(json['requested_at'] as String)
            : null,
        barangay: json['barangay'] != null
            ? BarangayInfo.fromJson(json['barangay'] as Map<String, dynamic>)
            : null,
        service: json['service'] != null
            ? ServiceInfo.fromJson(json['service'] as Map<String, dynamic>)
            : null,
        hasRated: json['has_rated'] as bool? ?? false,
      );

  ProgramPostingModel copyWith({bool? hasRated}) => ProgramPostingModel(
        postingId: postingId,
        postingTitle: postingTitle,
        overallStatus: overallStatus,
        requestedAt: requestedAt,
        barangay: barangay,
        service: service,
        hasRated: hasRated ?? this.hasRated,
      );
}

class ProgramTrackingModel {
  final ProgramInfo program;
  final int totalApplications;
  final Map<String, int> byStatus;
  final DateTime? lastRequestedAt;
  final List<ProgramPostingModel> postings;

  const ProgramTrackingModel({
    required this.program,
    required this.totalApplications,
    required this.byStatus,
    this.lastRequestedAt,
    required this.postings,
  });

  factory ProgramTrackingModel.fromJson(Map<String, dynamic> json) =>
      ProgramTrackingModel(
        program: ProgramInfo.fromJson(json['program'] as Map<String, dynamic>),
        totalApplications: (json['total_applications'] as num).toInt(),
        byStatus: (json['by_status'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ),
        lastRequestedAt: json['last_requested_at'] != null
            ? DateTime.tryParse(json['last_requested_at'] as String)
            : null,
        postings: (json['postings'] as List<dynamic>)
            .map((e) => ProgramPostingModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ─── Services ────────────────────────────────────────────────────────────────

class ServicePostingModel {
  final String postingId;
  final String postingTitle;
  final String overallStatus;
  final DateTime? requestedAt;
  final BarangayInfo? barangay;
  final ProgramInfo? program;
  final bool hasRated;

  const ServicePostingModel({
    required this.postingId,
    required this.postingTitle,
    required this.overallStatus,
    this.requestedAt,
    this.barangay,
    this.program,
    this.hasRated = false,
  });

  factory ServicePostingModel.fromJson(Map<String, dynamic> json) =>
      ServicePostingModel(
        postingId: json['posting_id'].toString(),
        postingTitle: (json['posting_title'] as String?) ?? '',
        overallStatus: (json['overall_status'] as String?) ?? '',
        requestedAt: json['requested_at'] != null
            ? DateTime.tryParse(json['requested_at'] as String)
            : null,
        barangay: json['barangay'] != null
            ? BarangayInfo.fromJson(json['barangay'] as Map<String, dynamic>)
            : null,
        program: json['program'] != null
            ? ProgramInfo.fromJson(json['program'] as Map<String, dynamic>)
            : null,
        hasRated: json['has_rated'] as bool? ?? false,
      );

  ServicePostingModel copyWith({bool? hasRated}) => ServicePostingModel(
        postingId: postingId,
        postingTitle: postingTitle,
        overallStatus: overallStatus,
        requestedAt: requestedAt,
        barangay: barangay,
        program: program,
        hasRated: hasRated ?? this.hasRated,
      );
}

class ServiceTrackingModel {
  final ServiceInfo service;
  final ProgramInfo? program;
  final int totalApplications;
  final Map<String, int> byStatus;
  final DateTime? lastRequestedAt;
  final List<ServicePostingModel> postings;

  const ServiceTrackingModel({
    required this.service,
    this.program,
    required this.totalApplications,
    required this.byStatus,
    this.lastRequestedAt,
    required this.postings,
  });

  factory ServiceTrackingModel.fromJson(Map<String, dynamic> json) =>
      ServiceTrackingModel(
        service:
            ServiceInfo.fromJson(json['service'] as Map<String, dynamic>),
        program: json['program'] != null
            ? ProgramInfo.fromJson(json['program'] as Map<String, dynamic>)
            : null,
        totalApplications: (json['total_applications'] as num).toInt(),
        byStatus: (json['by_status'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ),
        lastRequestedAt: json['last_requested_at'] != null
            ? DateTime.tryParse(json['last_requested_at'] as String)
            : null,
        postings: (json['postings'] as List<dynamic>)
            .map((e) =>
                ServicePostingModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ─── Complaints ───────────────────────────────────────────────────────────────

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
  final bool hasRated;

  const ComplaintModel({
    required this.id,
    this.code,
    this.type,
    this.subject,
    this.status,
    required this.statusLabel,
    this.dateRequested,
    this.updatedAt,
    this.barangay,
    this.hasRated = false,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) => ComplaintModel(
        id: json['id'].toString(),
        code: json['code'] as String?,
        type: json['type'] as String?,
        subject: json['subject'] as String?,
        status: json['status'] as String?,
        statusLabel: (json['status_label'] as String?) ?? '',
        dateRequested: json['date_requested'] != null
            ? DateTime.tryParse(json['date_requested'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
        barangay: json['barangay'] != null
            ? BarangayInfo.fromJson(json['barangay'] as Map<String, dynamic>)
            : null,
        hasRated: json['has_rated'] as bool? ?? false,
      );

  ComplaintModel copyWith({bool? hasRated}) => ComplaintModel(
        id: id,
        code: code,
        type: type,
        subject: subject,
        status: status,
        statusLabel: statusLabel,
        dateRequested: dateRequested,
        updatedAt: updatedAt,
        barangay: barangay,
        hasRated: hasRated ?? this.hasRated,
      );
}

// ─── Badge Requests ───────────────────────────────────────────────────────────

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
  final bool hasRated;

  const BadgeRequestModel({
    required this.id,
    this.code,
    this.type,
    this.status,
    required this.statusLabel,
    this.dateRequested,
    this.reviewedAt,
    this.reviewNotes,
    this.updatedAt,
    this.hasRated = false,
  });

  factory BadgeRequestModel.fromJson(Map<String, dynamic> json) =>
      BadgeRequestModel(
        id: json['id'].toString(),
        code: json['code'] as String?,
        type: json['type'] as String?,
        status: json['status'] as String?,
        statusLabel: (json['status_label'] as String?) ?? '',
        dateRequested: json['date_requested'] != null
            ? DateTime.tryParse(json['date_requested'] as String)
            : null,
        reviewedAt: json['reviewed_at'] != null
            ? DateTime.tryParse(json['reviewed_at'] as String)
            : null,
        reviewNotes: json['review_notes'] as String?,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
        hasRated: json['has_rated'] as bool? ?? false,
      );

  BadgeRequestModel copyWith({bool? hasRated}) => BadgeRequestModel(
        id: id,
        code: code,
        type: type,
        status: status,
        statusLabel: statusLabel,
        dateRequested: dateRequested,
        reviewedAt: reviewedAt,
        reviewNotes: reviewNotes,
        updatedAt: updatedAt,
        hasRated: hasRated ?? this.hasRated,
      );
}

// ─── Feedback ─────────────────────────────────────────────────────────────────

class PendingFeedbackEntity {
  final String? code;
  final String? title;
  final String? typeName;

  const PendingFeedbackEntity({this.code, this.title, this.typeName});

  factory PendingFeedbackEntity.fromJson(
    Map<String, dynamic> json,
    String feedbackableType,
  ) {
    if (feedbackableType == 'case') {
      return PendingFeedbackEntity(
        code: json['case_code'] as String?,
        typeName:
            (json['case_types'] as Map<String, dynamic>?)?['name'] as String?,
      );
    } else if (feedbackableType == 'complaint') {
      return PendingFeedbackEntity(
        code: json['complaint_code'] as String?,
        title: json['subject'] as String?,
      );
    } else {
      final service = json['assistance_services'] as Map<String, dynamic>?;
      final program =
          service?['assistance_programs'] as Map<String, dynamic>?;
      return PendingFeedbackEntity(
        title: (json['title'] as String?) ?? service?['name'] as String?,
        typeName: program?['name'] as String?,
      );
    }
  }

  String get displayTitle {
    if (title != null && title!.isNotEmpty) return title!;
    if (code != null && code!.isNotEmpty) return code!;
    if (typeName != null && typeName!.isNotEmpty) return typeName!;
    return 'Request';
  }
}

class PendingFeedbackRequest {
  final String id;
  final String feedbackableType;
  final String feedbackableId;
  final String status;
  final DateTime expiresAt;
  final PendingFeedbackEntity? entity;

  const PendingFeedbackRequest({
    required this.id,
    required this.feedbackableType,
    required this.feedbackableId,
    required this.status,
    required this.expiresAt,
    this.entity,
  });

  factory PendingFeedbackRequest.fromJson(Map<String, dynamic> json) =>
      PendingFeedbackRequest(
        id: json['id'].toString(),
        feedbackableType: json['feedbackable_type'] as String,
        feedbackableId: json['feedbackable_id'].toString(),
        status: json['status'] as String,
        expiresAt: DateTime.parse(json['expires_at'] as String),
        entity: json['entity'] != null
            ? PendingFeedbackEntity.fromJson(
                json['entity'] as Map<String, dynamic>,
                json['feedbackable_type'] as String,
              )
            : null,
      );

  bool get isExpired => expiresAt.isBefore(DateTime.now());
  int get daysUntilExpiry => expiresAt.difference(DateTime.now()).inDays;
}