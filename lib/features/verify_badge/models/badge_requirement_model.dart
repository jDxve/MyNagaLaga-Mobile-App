import 'badge_type_model.dart';

class BadgeRequirement {
  final String id;
  final String key;
  final String label;
  final bool isRequired;
  final List<String> acceptedMimes;
  final int maxFiles;
  final int maxSizeMb;

  BadgeRequirement({
    required this.id,
    required this.key,
    required this.label,
    required this.isRequired,
    required this.acceptedMimes,
    required this.maxFiles,
    required this.maxSizeMb,
  });

  factory BadgeRequirement.fromJson(Map<String, dynamic> json) =>
      BadgeRequirement(
        id: json['id']?.toString() ?? '',
        key: json['key'] ?? '',
        label: json['label'] ?? '',
        isRequired: json['is_required'] ?? true,
        acceptedMimes: (json['accepted_mimes'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        maxFiles: json['max_files'] ?? 1,
        maxSizeMb: json['max_size_mb'] ?? 10,
      );
}

class BadgeRequirementsData {
  final BadgeType badgeType;
  final List<BadgeRequirement> requirements;

  BadgeRequirementsData({
    required this.badgeType,
    required this.requirements,
  });

  factory BadgeRequirementsData.fromJson(Map<String, dynamic> json) =>
      BadgeRequirementsData(
        badgeType: BadgeType.fromJson(json['badgeType'] ?? {}),
        requirements: (json['requirements'] as List<dynamic>?)
                ?.map((item) =>
                    BadgeRequirement.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class BadgeRequirementsResponse {
  final bool success;
  final BadgeRequirementsData data;

  BadgeRequirementsResponse({
    required this.success,
    required this.data,
  });

  factory BadgeRequirementsResponse.fromJson(Map<String, dynamic> json) =>
      BadgeRequirementsResponse(
        success: json['success'] ?? false,
        data: BadgeRequirementsData.fromJson(json['data'] ?? {}),
      );
}