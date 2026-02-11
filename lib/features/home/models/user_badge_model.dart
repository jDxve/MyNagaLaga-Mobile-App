enum BadgeType { 
  student, 
  soloParent, 
  seniorCitizen, 
  pwd, 
  indigent,
  citizen,
  other 
}

class BadgeModel {
  final String id;
  final String badgeTypeId;
  final String badgeTypeName;
  final BadgeType badgeTypeKey;
  final String status;
  final DateTime? approvedAt;
  final DateTime? expiresAt;
  final bool isExpired;
  final int? daysUntilExpiry;

  BadgeModel({
    required this.id,
    required this.badgeTypeId,
    required this.badgeTypeName,
    required this.badgeTypeKey,
    required this.status,
    this.approvedAt,
    this.expiresAt,
    required this.isExpired,
    this.daysUntilExpiry,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    final badgeType = json['badgeType'] as Map<String, dynamic>?;
    final expiresAtStr = json['expiresAt'] as String?;
    final approvedAtStr = json['approvedAt'] as String?;
    
    final expiresAt = expiresAtStr != null ? DateTime.parse(expiresAtStr) : null;
    final now = DateTime.now();
    final isExpired = expiresAt != null && expiresAt.isBefore(now);
    final daysUntilExpiry = expiresAt != null && !isExpired
        ? expiresAt.difference(now).inDays
        : null;

    return BadgeModel(
      id: json['id'].toString(),
      badgeTypeId: badgeType?['id']?.toString() ?? '',
      badgeTypeName: badgeType?['name']?.toString() ?? '',
      badgeTypeKey: _parseBadgeType(badgeType?['name']?.toString()),
      status: json['status']?.toString() ?? 'Active',
      approvedAt: approvedAtStr != null ? DateTime.parse(approvedAtStr) : null,
      expiresAt: expiresAt,
      isExpired: isExpired,
      daysUntilExpiry: daysUntilExpiry,
    );
  }

  static BadgeType _parseBadgeType(String? name) {
    if (name == null) return BadgeType.other;
    
    final normalized = name.toLowerCase().replaceAll(' ', '');
    
    if (normalized.contains('student')) return BadgeType.student;
    if (normalized.contains('solo') || normalized.contains('parent')) return BadgeType.soloParent;
    if (normalized.contains('senior') || normalized.contains('citizen')) return BadgeType.seniorCitizen;
    if (normalized.contains('pwd') || normalized.contains('disability')) return BadgeType.pwd;
    if (normalized.contains('indigent')) return BadgeType.indigent;
    if (normalized == 'citizen') return BadgeType.citizen;
    
    return BadgeType.other;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'badgeTypeId': badgeTypeId,
      'badgeTypeName': badgeTypeName,
      'badgeTypeKey': badgeTypeKey.name,
      'status': status,
      'approvedAt': approvedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isExpired': isExpired,
      'daysUntilExpiry': daysUntilExpiry,
    };
  }
}

class BadgesResponse {
  final List<BadgeModel> badges;

  BadgesResponse({required this.badges});

  int get totalBadges => badges.length;

  factory BadgesResponse.fromJson(List<dynamic> json) {
    return BadgesResponse(
      badges: json.map((badge) => BadgeModel.fromJson(badge as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'badges': badges.map((b) => b.toJson()).toList(),
      'totalBadges': totalBadges,
    };
  }
}