import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_models.dart';

class AuthSessionNotifier extends Notifier<AuthSessionState> {
  final _storage = const FlutterSecureStorage();

  static const _tokenKey = 'access_token';
  static const _emailKey = 'user_email';
  static const _userIdKey = 'user_id';
  static const _fullNameKey = 'full_name';
  static const _barangayIdKey = 'barangay_id';

  @override
  AuthSessionState build() {
    _checkSession();
    return AuthSessionState.loading();
  }

  Future<void> _checkSession() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final email = await _storage.read(key: _emailKey);
      final userId = await _storage.read(key: _userIdKey);
      final fullName = await _storage.read(key: _fullNameKey);
      final barangayId = await _storage.read(key: _barangayIdKey);

      if (token != null && token.isNotEmpty) {
        state = AuthSessionState(
          isAuthenticated: true,
          isLoading: false,
          userId: userId,
          email: email,
          fullName: fullName,
          barangayId: barangayId,
          accessToken: token,
        );
      } else {
        state = AuthSessionState.empty();
      }
    } catch (e) {
      state = AuthSessionState.empty();
    }
  }

  Future<void> saveSession({
    required String accessToken,
    required String email,
    required String userId,
    String? fullName,
    String? barangayId,
  }) async {
    try {
      await _storage.write(key: _tokenKey, value: accessToken);
      await _storage.write(key: _emailKey, value: email);
      await _storage.write(key: _userIdKey, value: userId);

      if (fullName != null) {
        await _storage.write(key: _fullNameKey, value: fullName);
      }

      if (barangayId != null) {
        await _storage.write(key: _barangayIdKey, value: barangayId);
      }

      state = AuthSessionState(
        isAuthenticated: true,
        isLoading: false,
        userId: userId,
        email: email,
        fullName: fullName,
        barangayId: barangayId,
        accessToken: accessToken,
      );
    } catch (e) {
      state = AuthSessionState.empty();
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = AuthSessionState.empty();
  }
}

final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthSessionState>(
  AuthSessionNotifier.new,
);