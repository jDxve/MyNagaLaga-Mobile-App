import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/models/responses/error_response.dart';
import '../models/otp_model.dart';
import '../services/otp_verification_service.dart';
import 'otp_verification_repository.dart';

final otpVerificationRepositoryProvider =
    Provider.autoDispose<OtpVerificationRepositoryImpl>((ref) {
  final service = ref.watch(otpVerificationServiceProvider);
  return OtpVerificationRepositoryImpl(service: service);
});

class OtpVerificationRepositoryImpl implements OtpVerificationRepository {
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
  }) async {
    try {
      final response = await _service.verifySignupOtp(request: request);
      final accessToken = response.data.session?.accessToken;
      if (accessToken != null) {
        await _sendFcmToken(accessToken);
      }
      return DataState.success(data: response.data);
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to verify OTP');
    } catch (e) {
      return DataState.error(error: 'An unexpected error occurred');
    }
  }

  @override
  Future<DataState<VerifyOtpResponse>> verifyLoginOtp({
    required OtpVerificationRequest request,
  }) async {
    try {
      final response = await _service.verifyLoginOtp(request: request);
      final accessToken = response.data.session?.accessToken;
      if (accessToken != null) {
        await _sendFcmToken(accessToken);
      }
      return DataState.success(data: response.data);
    } on DioException catch (e) {
      return _handleDioError(e, 'Invalid OTP');
    } catch (e) {
      return DataState.error(error: 'An unexpected error occurred');
    }
  }

  DataState<VerifyOtpResponse> _handleDioError(
      DioException e, String defaultMessage) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return DataState.error(
        error: 'Connection timeout. Please check your internet connection.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return DataState.error(
        error: 'Cannot connect to server. Please check your internet connection.',
      );
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 404) {
      return DataState.error(error: 'Service not found. Please contact support.');
    }
    if (statusCode == 500 || statusCode == 502 || statusCode == 503) {
      return DataState.error(error: 'Server error. Please try again later.');
    }
    if (statusCode == 429) {
      return DataState.error(
        error: 'Too many attempts. Please wait before trying again.',
      );
    }
    if (statusCode == 401) {
      return DataState.error(
        error: 'Invalid or expired OTP code. Please try again.',
      );
    }
    if (e.response?.data != null) {
      try {
        final errorResponse =
            ErrorResponse.fromMap(e.response!.data as Map<String, dynamic>);
        return DataState.error(error: errorResponse.message ?? defaultMessage);
      } catch (_) {
        return DataState.error(error: defaultMessage);
      }
    }
    return DataState.error(error: e.message ?? defaultMessage);
  }
}