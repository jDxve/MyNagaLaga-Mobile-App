import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _storage.deleteAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('stay_logged_in');
      
    }
    super.onError(err, handler);
  }
}