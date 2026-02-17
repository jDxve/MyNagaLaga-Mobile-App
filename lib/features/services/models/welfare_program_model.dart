class WelfareProgramServiceModel {
  final String id;
  final String name;

  const WelfareProgramServiceModel({required this.id, required this.name});

  factory WelfareProgramServiceModel.fromJson(Map<String, dynamic> json) =>
      WelfareProgramServiceModel(
        id: json['id'].toString(),
        name: json['name'] ?? '',
      );
}

class WelfareProgramModel {
  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final List<WelfareProgramServiceModel> services;

  const WelfareProgramModel({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    required this.services,
  });

  factory WelfareProgramModel.fromJson(Map<String, dynamic> json) {
    final rawServices = json['assistance_services'] as List<dynamic>? ?? [];
    return WelfareProgramModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'],
      isActive: json['is_active'] ?? true,
      services: rawServices
          .map((s) => WelfareProgramServiceModel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BadgeTypeModel {
  final String id;
  final String name;

  const BadgeTypeModel({required this.id, required this.name});

  factory BadgeTypeModel.fromJson(Map<String, dynamic> json) => BadgeTypeModel(
        id: json['id'].toString(),
        name: json['name'] ?? '',
      );
}

class WelfarePostingModel {
  final String id;
  final String title;
  final String? description;
  final String status;
  final String? intakeMode;
  final DateTime startAt;
  final DateTime? endAt;
  final String? programName;
  final String? serviceName;
  final int? slotsTotal;
  final int? slotsRemaining;
  final String? barangayName;
  final String? batchNo;
  final List<BadgeTypeModel> requiredBadges;

  const WelfarePostingModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.intakeMode,
    required this.startAt,
    this.endAt,
    this.programName,
    this.serviceName,
    this.slotsTotal,
    this.slotsRemaining,
    this.barangayName,
    this.batchNo,
    this.requiredBadges = const [],
  });

  /// True if posting requires no badge OR user holds at least one required badge.
  bool isEligible(List<String> userBadgeTypeIds) {
    if (requiredBadges.isEmpty) return true;
    return requiredBadges.any((b) => userBadgeTypeIds.contains(b.id));
  }

  factory WelfarePostingModel.fromJson(Map<String, dynamic> json) {
    final rawBadges =
        json['assistance_posting_badge_types'] as List<dynamic>? ?? [];
    final badges = rawBadges
        .map((b) {
          final bt = b['badge_types'] as Map<String, dynamic>?;
          return bt != null ? BadgeTypeModel.fromJson(bt) : null;
        })
        .whereType<BadgeTypeModel>()
        .toList();

    return WelfarePostingModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? '',
      intakeMode: json['intake_mode'],
      startAt: DateTime.parse(json['start_at']),
      endAt: json['end_at'] != null ? DateTime.parse(json['end_at']) : null,
      serviceName: json['assistance_services']?['name'],
      programName: json['assistance_services']?['assistance_programs']?['name'],
      slotsTotal: json['slots_total'] != null
          ? int.tryParse(json['slots_total'].toString())
          : null,
      slotsRemaining: json['slots_remaining'] != null
          ? int.tryParse(json['slots_remaining'].toString())
          : null,
      barangayName: json['barangays']?['name'],
      batchNo: json['batch_no']?.toString(),
      requiredBadges: badges,
    );
  }
}