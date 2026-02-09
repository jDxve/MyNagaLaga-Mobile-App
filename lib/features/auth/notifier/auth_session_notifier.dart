import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class AuthSessionNotifier extends Notifier<AuthSessionState> {
  final _storage = const FlutterSecureStorage();

  static const _tokenKey = 'access_token';
  static const _emailKey = 'user_email';
  static const _userIdKey = 'user_id';
  static const _fullNameKey = 'full_name';
  static const _stayLoggedInKey = 'stay_logged_in';

  @override
  AuthSessionState build() {
    _checkSession();
    return AuthSessionState.loading();
  }

  Future<void> _checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stayLoggedIn = prefs.getBool(_stayLoggedInKey) ?? false;

      if (stayLoggedIn) {
        final token = await _storage.read(key: _tokenKey);
        final email = await _storage.read(key: _emailKey);
        final userId = await _storage.read(key: _userIdKey);
        final fullName = await _storage.read(key: _fullNameKey);

        if (token != null && token.isNotEmpty) {
          state = AuthSessionState(
            isAuthenticated: true,
            isLoading: false,
            userId: userId,
            email: email,
            fullName: fullName,
            barangayId: null,
            accessToken: token,
          );
          return;
        }
      }

      state = AuthSessionState.empty();
    } catch (e) {
      state = AuthSessionState.empty();
    }
  }

  Future<void> saveSession({
    required String accessToken,
    required String email,
    required String userId,
    String? fullName,
    bool stayLoggedIn = false,
  }) async {
    try {
      await _storage.write(key: _tokenKey, value: accessToken);
      await _storage.write(key: _emailKey, value: email);
      await _storage.write(key: _userIdKey, value: userId);

      if (fullName != null) {
        await _storage.write(key: _fullNameKey, value: fullName);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_stayLoggedInKey, stayLoggedIn);

      if (stayLoggedIn) {
        await prefs.setString('saved_email', email);
        await prefs.setBool('remember_me', true);
      }

      state = AuthSessionState(
        isAuthenticated: true,
        isLoading: false,
        userId: userId,
        email: email,
        fullName: fullName,
        barangayId: null,
        accessToken: accessToken,
      );
    } catch (e) {
      state = AuthSessionState.empty();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;

    await _storage.deleteAll();
    await prefs.remove(_stayLoggedInKey);

    if (!rememberMe) {
      await prefs.remove('saved_email');
      await prefs.setBool('remember_me', false);
    }

    state = AuthSessionState.empty();
  }
}

final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthSessionState>(
  AuthSessionNotifier.new,
);