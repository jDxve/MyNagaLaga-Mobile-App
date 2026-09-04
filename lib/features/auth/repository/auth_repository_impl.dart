import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/network/data_state.dart';
import '../../../core/network/repository_guard.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import 'auth_repository.dart';

final authRepositoryProvider = Provider.autoDispose<AuthRepositoryImpl>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthRepositoryImpl(service: service);
});

class AuthRepositoryImpl with RepositoryGuard implements AuthRepository {
  final AuthService _service;

  AuthRepositoryImpl({required AuthService service}) : _service = service;

  @override
  Future<DataState<OtpResponse>> requestSignupOtp({
    required SignupRequest request,
  }) =>
      guard(
        () async => (await _service.requestSignupOtp(request: request)).data,
        mapError: (e) => _mapError(e, 'Failed to send OTP'),
      );

  @override
  Future<DataState<OtpResponse>> requestLoginOtp({
    required LoginRequest request,
  }) =>
      guard(
        () async => (await _service.requestLoginOtp(request: request)).data,
        mapError: (e) => _mapError(e, 'Failed to send OTP'),
      );

  AppException _mapError(DioException e, String defaultMessage) {
    return switch (e.response?.statusCode) {
      404 => const AppException(
          statusCode: 404,
          message: 'Service not found. Please contact support.',
        ),
      409 => const AppException(
          statusCode: 409,
          message: 'Email already registered. Please login instead.',
        ),
      429 => const AppException(
          statusCode: 429,
          message: 'Too many requests. Please wait a moment and try again.',
        ),
      _ => AppException.fromDioException(e, fallbackMessage: defaultMessage),
    };
  }
}