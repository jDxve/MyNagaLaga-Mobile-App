import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_interceptor.dart';
import 'logging_interceptor.dart';

class ApiClient {
  final String _baseUrl;

  ApiClient(this._baseUrl);

  BaseOptions _createBaseOptions() => BaseOptions(
        headers: {"Accept": "application/json"},
        baseUrl: _baseUrl,
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        connectTimeout: const Duration(seconds: 60),
      );

  Dio create() => Dio(_createBaseOptions())
    ..interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
    ]);

  // Static factory method
  static ApiClient fromEnv() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';
    return ApiClient(baseUrl);
  }
}