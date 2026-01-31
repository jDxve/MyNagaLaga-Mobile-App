enum BadgeType { student, soloParent, seniorCitizen, pwd, indigentFamily, other }

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
    return BadgeModel(
      id: json['id'].toString(),
      badgeTypeId: json['badgeTypeId'].toString(),
      badgeTypeName: json['badgeTypeName'] ?? '',
      badgeTypeKey: _parseBadgeType(json['badgeTypeKey']),
      status: json['status'] ?? 'Active',
      approvedAt: json['approvedAt'] != null 
          ? DateTime.parse(json['approvedAt']) 
          : null,
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
      isExpired: json['isExpired'] ?? false,
      daysUntilExpiry: json['daysUntilExpiry'],
    );
  }

  static BadgeType _parseBadgeType(String? key) {
    switch (key?.toLowerCase()) {
      case 'student':
        return BadgeType.student;
      case 'soloparent':
        return BadgeType.soloParent;
      case 'seniorcitizen':
        return BadgeType.seniorCitizen;
      case 'pwd':
        return BadgeType.pwd;
      case 'indigentfamily':
        return BadgeType.indigentFamily;
      default:
        return BadgeType.other;
    }
  }
}

class BadgesResponse {
  final String mobileUserId;
  final int totalBadges;
  final List<BadgeModel> badges;

  BadgesResponse({
    required this.mobileUserId,
    required this.totalBadges,
    required this.badges,
  });

  factory BadgesResponse.fromJson(Map<String, dynamic> json) {
    return BadgesResponse(
      mobileUserId: json['mobileUserId'].toString(),
      totalBadges: json['totalBadges'] ?? 0,
      badges: (json['badges'] as List<dynamic>?)
              ?.map((badge) => BadgeModel.fromJson(badge))
              .toList() ??
          [],
    );
  }
}