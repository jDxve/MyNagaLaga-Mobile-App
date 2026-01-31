class BadgeType {
  final String id;
  final String name;
  final bool requiresExpiry;
  final int? expiryDays;
  final bool isActive;

  BadgeType({
    required this.id,
    required this.name,
    required this.requiresExpiry,
    this.expiryDays,
    required this.isActive,
  });

  factory BadgeType.fromJson(Map<String, dynamic> json) {
    return BadgeType(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      requiresExpiry: json['requiresExpiry'] ?? false,
      expiryDays: json['expiryDays'],
      isActive: json['isActive'] ?? true,
    );
  }

  String get badgeKey {
    final n = name.toLowerCase();
    if (n.contains('senior')) return 'senior_citizen';
    if (n.contains('pwd') || n.contains('disability')) return 'pwd';
    if (n.contains('solo')) return 'solo_parent';
    if (n.contains('student')) return 'student';
    if (n.contains('indigent')) return 'indigent';
    return 'other';
  }

  static get student => null;
}