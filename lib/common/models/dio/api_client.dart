import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/auth_interceptor.dart';

// Deprecated: superseded by `dioProvider` in core/network/dio_factory.dart,
// which shares one Dio/storage instance instead of a fresh one per call
// site. Kept temporarily so already-migrated and not-yet-migrated call
// sites both compile; deleted once every call site reads dioProvider.

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
      AuthInterceptor(const FlutterSecureStorage()),
    ]);

  static ApiClient fromEnv() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';
    return ApiClient(baseUrl);
  }
}