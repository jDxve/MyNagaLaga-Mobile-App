import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_models.dart';

class AuthSessionNotifier extends Notifier<AuthSessionState> {
  final _storage = const FlutterSecureStorage();
  
  static const _tokenKey = 'access_token';
  static const _emailKey = 'user_email';
  static const _userIdKey = 'user_id';

  @override
  AuthSessionState build() {
    _checkSession();
    return AuthSessionState.empty();
  }

  Future<void> _checkSession() async {
    final token = await _storage.read(key: _tokenKey);
    final email = await _storage.read(key: _emailKey);
    final userId = await _storage.read(key: _userIdKey);

    if (token != null && token.isNotEmpty) {
      state = AuthSessionState(
        isAuthenticated: true,
        userId: userId,
        email: email,
        accessToken: token,
      );
    }
  }

  Future<void> saveSession({
    required String accessToken,
    required String email,
    required String userId,
  }) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _userIdKey, value: userId);

    state = AuthSessionState(
      isAuthenticated: true,
      userId: userId,
      email: email,
      accessToken: accessToken,
    );
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = AuthSessionState.empty();
  }
}

final authSessionProvider = NotifierProvider<AuthSessionNotifier, AuthSessionState>(
  AuthSessionNotifier.new,
);