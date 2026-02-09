class BadgeType {
  final String id;
  final String name;

  BadgeType({
    required this.id,
    required this.name,
  });

  factory BadgeType.fromJson(Map<String, dynamic> json) => BadgeType(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
      );

  String get badgeKey {
    final n = name.toLowerCase();
    if (n.contains('senior')) return 'senior_citizen';
    if (n.contains('pwd') || n.contains('disability')) return 'pwd';
    if (n.contains('solo')) return 'solo_parent';
    if (n.contains('student')) return 'student';
    if (n.contains('indigent')) return 'indigent';
    if (n.contains('citizen')) return 'citizen';
    return 'other';
  }
}

class BadgeTypesResponse {
  final bool success;
  final List<BadgeType> data;

  BadgeTypesResponse({
    required this.success,
    required this.data,
  });

  factory BadgeTypesResponse.fromJson(Map<String, dynamic> json) =>
      BadgeTypesResponse(
        success: json['success'] ?? false,
        data: (json['data'] as List<dynamic>?)
                ?.map((item) => BadgeType.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [],
      );
}