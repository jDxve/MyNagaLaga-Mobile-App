import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_models.dart';

class AuthSessionNotifier extends Notifier<AuthSessionState> {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _emailKey = 'user_email';
  static const _userIdKey = 'user_id';
  static const _fullNameKey = 'full_name';  // ✅ ADD THIS

  @override
  AuthSessionState build() {
    _checkSession();
    return AuthSessionState.loading();
  }

  Future<void> _checkSession() async {
    final token = await _storage.read(key: _tokenKey);
    final email = await _storage.read(key: _emailKey);
    final userId = await _storage.read(key: _userIdKey);
    final fullName = await _storage.read(key: _fullNameKey);  // ✅ ADD THIS

    debugPrint('📖 Reading session from storage:');
    debugPrint('   Email: $email');
    debugPrint('   User ID: $userId');
    debugPrint('   Full Name: $fullName');

    if (token != null && token.isNotEmpty) {
      state = AuthSessionState(
        isAuthenticated: true,
        isLoading: false,
        userId: userId,
        email: email,
        fullName: fullName,  // ✅ ADD THIS
        accessToken: token,
      );
    } else {
      state = AuthSessionState.empty();
    }
  }

  Future<void> saveSession({
    required String accessToken,
    required String email,
    required String userId,
    String? fullName,  // ✅ ADD THIS
  }) async {
    debugPrint('💾 Saving session:');
    debugPrint('   Email: $email');
    debugPrint('   User ID: $userId');
    debugPrint('   Full Name: $fullName');

    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _userIdKey, value: userId);
    if (fullName != null) {
      await _storage.write(key: _fullNameKey, value: fullName);  // ✅ ADD THIS
    }

    state = AuthSessionState(
      isAuthenticated: true,
      isLoading: false,
      userId: userId,
      email: email,
      fullName: fullName,  // ✅ ADD THIS
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