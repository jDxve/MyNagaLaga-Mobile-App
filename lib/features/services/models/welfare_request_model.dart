class WelfarePrefillFile {
  final String requirementKey;
  final String requirementLabel;
  final String storagePath;
  final String fileName;
  final String mimeType;
  final String? url;

  const WelfarePrefillFile({
    required this.requirementKey,
    required this.requirementLabel,
    required this.storagePath,
    required this.fileName,
    required this.mimeType,
    this.url,
  });

  factory WelfarePrefillFile.fromMap(Map<String, dynamic> map) {
    return WelfarePrefillFile(
      requirementKey: map['requirementKey']?.toString() ?? '',
      requirementLabel: map['requirementLabel']?.toString() ?? '',
      storagePath: map['storagePath']?.toString() ?? '',
      fileName: map['fileName']?.toString() ?? '',
      mimeType: map['mimeType']?.toString() ?? '',
      url: map['url']?.toString(),
    );
  }
}

class WelfarePrefillBadge {
  final String badgeTypeId;
  final String badgeTypeName;
  final Map<String, String> formCommon;
  final Map<String, String> formExtraNonNull;
  final List<WelfarePrefillFile> files;

  const WelfarePrefillBadge({
    required this.badgeTypeId,
    required this.badgeTypeName,
    required this.formCommon,
    required this.formExtraNonNull,
    required this.files,
  });

  factory WelfarePrefillBadge.fromMap(Map<String, dynamic> map) {
    final form = map['form'] as Map<String, dynamic>? ?? {};
    final common = form['common'] as Map<String, dynamic>? ?? {};
    final extra = form['extraNonNull'] as Map<String, dynamic>? ?? {};
    final rawFiles = map['files'] as List<dynamic>? ?? [];
    return WelfarePrefillBadge(
      badgeTypeId: map['badgeTypeId']?.toString() ?? '',
      badgeTypeName: map['badgeTypeName']?.toString() ?? '',
      formCommon: common.map((k, v) => MapEntry(k, v?.toString() ?? '')),
      formExtraNonNull: extra.map((k, v) => MapEntry(k, v?.toString() ?? '')),
      files: rawFiles
          .map((f) => WelfarePrefillFile.fromMap(f as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WelfareRequestModel {
  final String mobileUserId;
  final String postingId;
  final int submittedCount;
  final List<WelfareAutoAttachedRequirement> autoAttachedRequirements;
  final List<WelfareAutoAttachedCategory> autoAttachedByCategory;
  final List<WelfareAutoFilledCategory> autoFilledTextByCategory;
  final List<WelfarePrefillBadge> prefillBadges;

  const WelfareRequestModel({
    required this.mobileUserId,
    required this.postingId,
    required this.submittedCount,
    required this.autoAttachedRequirements,
    required this.autoAttachedByCategory,
    required this.autoFilledTextByCategory,
    required this.prefillBadges,
  });

  factory WelfareRequestModel.fromMap(Map<String, dynamic> map) {
    final prefill = map['prefill'] as Map<String, dynamic>? ?? {};
    final rawBadges = prefill['badges'] as List<dynamic>? ?? [];

    return WelfareRequestModel(
      mobileUserId: map['mobile_user_id']?.toString() ?? '',
      postingId: map['posting_id']?.toString() ?? '',
      submittedCount: (map['submitted_count'] as num?)?.toInt() ?? 0,
      autoAttachedRequirements:
          (map['auto_attached_requirements'] as List<dynamic>? ?? [])
              .map((e) => WelfareAutoAttachedRequirement.fromMap(e as Map<String, dynamic>))
              .toList(),
      autoAttachedByCategory:
          (map['auto_attached_requirements_by_category'] as List<dynamic>? ?? [])
              .map((e) => WelfareAutoAttachedCategory.fromMap(e as Map<String, dynamic>))
              .toList(),
      autoFilledTextByCategory:
          (map['auto_filled_text_requirements_by_category'] as List<dynamic>? ?? [])
              .map((e) => WelfareAutoFilledCategory.fromMap(e as Map<String, dynamic>))
              .toList(),
      prefillBadges: rawBadges
          .map((b) => WelfarePrefillBadge.fromMap(b as Map<String, dynamic>))
          .toList(),
    );
  }

  WelfarePrefillFile? findBestPrefillFile({
    required String requirementKey,
    required String requirementLabel,
  }) {
    WelfarePrefillFile? best;
    double bestScore = 0;

    for (final badge in prefillBadges) {
      for (final file in badge.files) {
        if (file.requirementKey.isNotEmpty && file.requirementKey == requirementKey) {
          return file;
        }

        final score = _labelSimilarity(
          file.requirementLabel.toLowerCase(),
          requirementLabel.toLowerCase(),
        );

        if (score > bestScore && score >= 0.6) {
          best = file;
          bestScore = score;
        }
      }
    }

    return best;
  }

  double _labelSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.contains(b) || b.contains(a)) return 0.8;

    final ta = a.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toSet();
    final tb = b.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toSet();

    if (ta.isEmpty || tb.isEmpty) return 0;

    final inter = ta.intersection(tb).length;
    final union = ta.union(tb).length;

    return union == 0 ? 0 : inter / union;
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
          .map((e) => WelfareAutoAttachedRequirement.fromMap(e as Map<String, dynamic>))
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
          .map((e) => WelfareAutoFilledItem.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}