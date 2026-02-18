class WelfareRequirementItem {
  final String requirementId; // ✅ DB id from assistance_posting_requirements
  final String key;
  final String label;
  final String type;
  final bool required;
  final String? notes;

  const WelfareRequirementItem({
    required this.requirementId,
    required this.key,
    required this.label,
    required this.type,
    required this.required,
    this.notes,
  });

  factory WelfareRequirementItem.fromMap(Map<String, dynamic> map) {
    return WelfareRequirementItem(
      requirementId: map['requirementId']?.toString() ?? '',
      key: map['key'] ?? '',
      label: map['label'] ?? '',
      type: map['type'] ?? 'file',
      required: map['required'] ?? true,
      notes: map['notes'],
    );
  }
}

class WelfareRequirementGroup {
  final String category;
  final String? description;
  final List<WelfareRequirementItem> items;

  const WelfareRequirementGroup({
    required this.category,
    this.description,
    required this.items,
  });

  factory WelfareRequirementGroup.fromList(
    String category,
    String? description,
    List<dynamic> items,
  ) {
    return WelfareRequirementGroup(
      category: category,
      description: description,
      items: items
          .map((e) => WelfareRequirementItem.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

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
          .map((s) =>
              WelfareProgramServiceModel.fromJson(s as Map<String, dynamic>))
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
  final List<WelfareRequirementGroup> requirements;

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
    this.requirements = const [],
  });

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

    final rawReqs =
        json['assistance_posting_requirements'] as List<dynamic>? ?? [];
    final groupMap = <String, _GroupBuffer>{};

    for (final raw in rawReqs) {
      final rawMap = raw as Map<String, dynamic>;
      final meta = rawMap['assistance_service_requirements'] as Map<String, dynamic>?;
      if (meta == null) continue;
      final category = meta['category'] as String? ?? 'Other';
      final desc = meta['group_description'] as String?;
      final item = meta['item'] as Map<String, dynamic>?;
      if (item == null) continue;

      // ✅ Inject the posting requirement DB id into the item map
      final itemWithId = {
        ...item,
        'requirementId': rawMap['id'].toString(),
      };

      groupMap.putIfAbsent(category, () => _GroupBuffer(category, desc));
      groupMap[category]!.items.add(itemWithId);
    }

    final groups = groupMap.values
        .map((g) =>
            WelfareRequirementGroup.fromList(g.category, g.desc, g.items))
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
      programName:
          json['assistance_services']?['assistance_programs']?['name'],
      slotsTotal: json['slots_total'] != null
          ? int.tryParse(json['slots_total'].toString())
          : null,
      slotsRemaining: json['slots_remaining'] != null
          ? int.tryParse(json['slots_remaining'].toString())
          : null,
      barangayName: json['barangays']?['name'],
      batchNo: json['batch_no']?.toString(),
      requiredBadges: badges,
      requirements: groups,
    );
  }
}

class _GroupBuffer {
  final String category;
  final String? desc;
  final List<dynamic> items = [];
  _GroupBuffer(this.category, this.desc);
}