class WelfarePostingModel {
  final String id;
  final String title;
  final String? description;
  final String status;

  final DateTime startAt;
  final DateTime? endAt;

  final String? barangayName;
  final String? programName;
  final String? serviceName;

  WelfarePostingModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.startAt,
    this.endAt,
    this.barangayName,
    this.programName,
    this.serviceName,
  });

  factory WelfarePostingModel.fromJson(Map<String, dynamic> json) {
    return WelfarePostingModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? '',

      startAt: DateTime.parse(json['start_at']),
      endAt: json['end_at'] != null
          ? DateTime.parse(json['end_at'])
          : null,

      barangayName: json['barangays']?['name'],
      serviceName: json['assistance_services']?['name'],
      programName: json['assistance_services']
          ?['assistance_programs']?['name'],
    );
  }
}
