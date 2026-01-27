import 'dart:convert';

class EmptyDataResponse {
  bool success = false;
  dynamic data;
  String message = "";

  EmptyDataResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'success': success,
      'data': data,
      'message': message,
    };
  }

  factory EmptyDataResponse.fromMap(Map<String, dynamic> map) {
    return EmptyDataResponse(
      success: map['success'] as bool,
      data: map['data'],
      message: map['message'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory EmptyDataResponse.fromJson(Map<String, dynamic> source) =>
      EmptyDataResponse.fromMap(source);
}