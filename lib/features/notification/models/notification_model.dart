class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final DateTime receivedAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.receivedAt,
    this.isRead = false,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      data: data,
      receivedAt: receivedAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type,
        'data': data,
        'receivedAt': receivedAt.toIso8601String(),
        'isRead': isRead,
      };

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      receivedAt: DateTime.parse(json['receivedAt']),
      isRead: json['isRead'] ?? false,
    );
  }

  factory NotificationModel.fromRemoteMessage({
    required String id,
    required String title,
    required String body,
    required String type,
    required Map<String, dynamic> data,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      data: data,
      receivedAt: DateTime.now(),
      isRead: false,
    );
  }
}