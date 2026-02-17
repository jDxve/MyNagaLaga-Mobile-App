class PostingRequirement {
  final int id;
  final String label;
  final String category;
  final String type;
  final bool required;
  final String? notes;
  final int order;

  const PostingRequirement({   // ← add const here
    required this.id,
    required this.label,
    required this.category,
    required this.type,
    required this.required,
    this.notes,
    required this.order,
  });
}