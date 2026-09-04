import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:mynagalaga_mobile_app/core/config/app_config.dart';
import 'package:mynagalaga_mobile_app/core/network/auth_interceptor.dart';
import 'package:mynagalaga_mobile_app/core/network/logging_interceptor.dart';

/// The single `FlutterSecureStorage` instance for the app. Nothing should
/// construct `const FlutterSecureStorage()` directly — read this provider
/// instead, so storage is swappable in tests and there's exactly one source
/// of truth for tokens.
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// The single `Dio` instance for the app. Every service provider should
/// read this instead of constructing its own `Dio`/`AuthInterceptor` pair.
final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);

  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    headers: {'Accept': 'application/json'},
    connectTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
  ));

  dio.interceptors.addAll([
    if (!kReleaseMode) LoggingInterceptor(),
    AuthInterceptor(storage),
  ]);

  return dio;
});
