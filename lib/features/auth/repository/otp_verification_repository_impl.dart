import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/network/data_state.dart';
import '../../../core/network/repository_guard.dart';
import '../models/otp_model.dart';
import '../services/otp_verification_service.dart';
import 'otp_verification_repository.dart';

final otpVerificationRepositoryProvider =
    Provider.autoDispose<OtpVerificationRepositoryImpl>((ref) {
  final service = ref.watch(otpVerificationServiceProvider);
  return OtpVerificationRepositoryImpl(service: service);
});

class OtpVerificationRepositoryImpl
    with RepositoryGuard
    implements OtpVerificationRepository {
  final OtpVerificationService _service;

  OtpVerificationRepositoryImpl({required OtpVerificationService service})
      : _service = service;

  Future<void> _sendFcmToken(String accessToken) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;
      await _service.updateFcmToken(
        body: {'fcmToken': fcmToken},
        authorization: 'Bearer $accessToken',
      );
      debugPrint('✅ FCM token sent to backend');
    } catch (e) {
      debugPrint('❌ Failed to send FCM token: $e');
    }
  }

  @override
  Future<DataState<VerifyOtpResponse>> verifySignupOtp({
    required OtpVerificationRequest request,
  }) =>
      guard(
        () async {
          final response = await _service.verifySignupOtp(request: request);
          final accessToken = response.data.session?.accessToken;
          if (accessToken != null) await _sendFcmToken(accessToken);
          return response.data;
        },
        mapError: (e) => _mapError(e, 'Failed to verify OTP'),
      );

  @override
  Future<DataState<VerifyOtpResponse>> verifyLoginOtp({
    required OtpVerificationRequest request,
  }) =>
      guard(
        () async {
          final response = await _service.verifyLoginOtp(request: request);
          final accessToken = response.data.session?.accessToken;
          if (accessToken != null) await _sendFcmToken(accessToken);
          return response.data;
        },
        mapError: (e) => _mapError(e, 'Invalid OTP'),
      );

  AppException _mapError(DioException e, String defaultMessage) {
    return switch (e.response?.statusCode) {
      404 => const AppException(
          statusCode: 404,
          message: 'Service not found. Please contact support.',
        ),
      429 => const AppException(
          statusCode: 429,
          message: 'Too many attempts. Please wait before trying again.',
        ),
      401 => const AppException(
          statusCode: 401,
          message: 'Invalid or expired OTP code. Please try again.',
        ),
      _ => AppException.fromDioException(e, fallbackMessage: defaultMessage),
    };
  }
}