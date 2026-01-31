// posting_requirement_model.dart
class PostingRequirement {
  final int id;
  final String label;
  final String category;
  final String type;
  final bool required;
  final String? notes;
  final int order;

  PostingRequirement({
    required this.id,
    required this.label,
    required this.category,
    required this.type,
    required this.required,
    this.notes,
    required this.order,
  });

  factory PostingRequirement.fromJson(Map<String, dynamic> json) {
    final requirement = json['assistance_service_requirements'] as Map<String, dynamic>?;
    final item = requirement?['item'] as Map<String, dynamic>?;
    
    // Parse order from the correct location
    int order = 0;
    if (requirement != null && requirement.containsKey('order')) {
      order = int.tryParse(requirement['order'].toString()) ?? 0;
    }
    
    return PostingRequirement(
      id: int.parse(json['id']?.toString() ?? '0'),
      label: item?['label'] ?? '',
      category: requirement?['category'] ?? '',
      type: item?['type'] ?? 'file',
      required: item?['required'] ?? true,
      notes: item?['notes'],
      order: order, // This will now correctly get 1, 2, 3, etc.
    );
  }
}