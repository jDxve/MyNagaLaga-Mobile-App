class HouseholdLinkRequestModel {
  final String requestId;
  final String householdId;
  final String householdCode;
  final String status;
  final String? reviewNotes;
  final String? requestedAt;

  HouseholdLinkRequestModel({
    required this.requestId,
    required this.householdId,
    required this.householdCode,
    required this.status,
    this.reviewNotes,
    this.requestedAt,
  });

  factory HouseholdLinkRequestModel.fromJson(Map<String, dynamic> json) {
    return HouseholdLinkRequestModel(
      requestId: json['id'].toString(),
      householdId: json['household_id'].toString(),
      householdCode: json['households']?['household_code'] ?? '',
      status: json['status'] ?? 'Pending',
      reviewNotes: json['review_notes'],
      requestedAt: json['requested_at'],
    );
  }
}