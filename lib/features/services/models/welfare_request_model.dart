class WelfareRequestModel {
  final String mobileUserId;
  final String postingId;
  final int submittedCount;
  final List<WelfareAutoAttachedRequirement> autoAttachedRequirements;
  final List<WelfareAutoAttachedCategory> autoAttachedByCategory;
  final List<WelfareAutoFilledCategory> autoFilledTextByCategory;

  const WelfareRequestModel({
    required this.mobileUserId,
    required this.postingId,
    required this.submittedCount,
    required this.autoAttachedRequirements,
    required this.autoAttachedByCategory,
    required this.autoFilledTextByCategory,
  });

  factory WelfareRequestModel.fromMap(Map<String, dynamic> map) {
    return WelfareRequestModel(
      mobileUserId: map['mobile_user_id']?.toString() ?? '',
      postingId: map['posting_id']?.toString() ?? '',
      submittedCount: (map['submitted_count'] as num?)?.toInt() ?? 0,
      autoAttachedRequirements:
          (map['auto_attached_requirements'] as List<dynamic>? ?? [])
              .map((e) => WelfareAutoAttachedRequirement.fromMap(
                  e as Map<String, dynamic>))
              .toList(),
      autoAttachedByCategory:
          (map['auto_attached_requirements_by_category'] as List<dynamic>? ?? [])
              .map((e) => WelfareAutoAttachedCategory.fromMap(
                  e as Map<String, dynamic>))
              .toList(),
      autoFilledTextByCategory:
          (map['auto_filled_text_requirements_by_category']
                      as List<dynamic>? ??
                  [])
              .map((e) => WelfareAutoFilledCategory.fromMap(
                  e as Map<String, dynamic>))
              .toList(),
    );
  }
}

class WelfareAutoAttachedRequirement {
  final String requirementId;
  final String label;
  final double matchScore;

  const WelfareAutoAttachedRequirement({
    required this.requirementId,
    required this.label,
    required this.matchScore,
  });

  factory WelfareAutoAttachedRequirement.fromMap(Map<String, dynamic> map) {
    return WelfareAutoAttachedRequirement(
      requirementId: map['requirement_id']?.toString() ?? '',
      label: map['label'] ?? '',
      matchScore: (map['match_score'] as num?)?.toDouble() ?? 0,
    );
  }
}

class WelfareAutoAttachedCategory {
  final String category;
  final List<WelfareAutoAttachedRequirement> items;

  const WelfareAutoAttachedCategory({
    required this.category,
    required this.items,
  });

  factory WelfareAutoAttachedCategory.fromMap(Map<String, dynamic> map) {
    return WelfareAutoAttachedCategory(
      category: map['category'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((e) => WelfareAutoAttachedRequirement.fromMap(
              e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WelfareAutoFilledItem {
  final String requirementId;
  final String label;
  final double matchScore;
  final String badgeTypeId;
  final String badgeTypeName;
  final String fieldKey;

  const WelfareAutoFilledItem({
    required this.requirementId,
    required this.label,
    required this.matchScore,
    required this.badgeTypeId,
    required this.badgeTypeName,
    required this.fieldKey,
  });

  factory WelfareAutoFilledItem.fromMap(Map<String, dynamic> map) {
    return WelfareAutoFilledItem(
      requirementId: map['requirement_id']?.toString() ?? '',
      label: map['label'] ?? '',
      matchScore: (map['match_score'] as num?)?.toDouble() ?? 0,
      badgeTypeId: map['badge_type_id']?.toString() ?? '',
      badgeTypeName: map['badge_type_name'] ?? '',
      fieldKey: map['field_key'] ?? '',
    );
  }
}

class WelfareAutoFilledCategory {
  final String category;
  final List<WelfareAutoFilledItem> items;

  const WelfareAutoFilledCategory({
    required this.category,
    required this.items,
  });

  factory WelfareAutoFilledCategory.fromMap(Map<String, dynamic> map) {
    return WelfareAutoFilledCategory(
      category: map['category'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((e) =>
              WelfareAutoFilledItem.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}