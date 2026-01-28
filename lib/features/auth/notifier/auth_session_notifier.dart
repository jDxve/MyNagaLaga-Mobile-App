// lib/features/auth/providers/auth_session_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Auth session notifier - manages authentication state
class AuthSessionNotifier extends Notifier<bool> {
  final _storage = const FlutterSecureStorage();
  
  static const _tokenKey = 'access_token';
  static const _emailKey = 'user_email';

  @override
  bool build() {
    _checkSession();
    return false;
  }

  /// Check if there's an existing session on app start
  Future<void> _checkSession() async {
    final token = await _storage.read(key: _tokenKey);
    state = token != null && token.isNotEmpty;
  }

  /// Save session after successful OTP verification
  Future<void> saveSession({
    required String accessToken,
    required String email,
  }) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _emailKey, value: email);
    state = true;
  }

  /// Get the current access token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Get the current user email
  Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  /// Clear session on logout
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _emailKey);
    state = false;
  }
}

/// Provider for auth session state
final authSessionProvider = NotifierProvider<AuthSessionNotifier, bool>(
  AuthSessionNotifier.new,
);