import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Attaches the bearer token to every request and clears the session on a
/// 401. `QueuedInterceptor` (not `Interceptor`) so concurrent requests that
/// all 401 at once serialize through this handler instead of each racing to
/// clear/redirect independently.
///
/// Storage is injected (see `dioProvider`) rather than constructed here, so
/// there is exactly one `FlutterSecureStorage` instance app-wide.
class AuthInterceptor extends QueuedInterceptor {
  final FlutterSecureStorage _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _storage.deleteAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('stay_logged_in');
    }
    handler.next(err);
  }
}
