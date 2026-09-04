import 'dart:convert';

class ErrorResponse {
  bool? success;
  dynamic data;
  String? message;

  ErrorResponse({
    required this.success,
    required this.data,
    this.message,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    
    if (success != null) {
      result.addAll({'success': success});
    }
    result.addAll({'data': data});
    if (message != null) {
      result.addAll({'message': message});
    }

    return result;
  }

  factory ErrorResponse.fromMap(Map<String, dynamic> map) {
    return ErrorResponse(
      success: map['success'],
      data: map['data'],
      message: map['message'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ErrorResponse.fromJson(String source) =>
      ErrorResponse.fromMap(json.decode(source));
}