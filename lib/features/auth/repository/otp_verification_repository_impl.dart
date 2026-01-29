import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/models/responses/error_response.dart';
import '../models/otp_model.dart';
import '../services/otp_verification_service.dart';
import 'otp_verification_repository.dart';

final otpVerificationRepositoryProvider = Provider.autoDispose<OtpVerificationRepositoryImpl>((ref) {
  final service = ref.watch(otpVerificationServiceProvider);
  return OtpVerificationRepositoryImpl(service: service);
});

class OtpVerificationRepositoryImpl implements OtpVerificationRepository {
  final OtpVerificationService _service;

  OtpVerificationRepositoryImpl({
    required OtpVerificationService service,
  }) : _service = service;

  @override
  Future<DataState<VerifyOtpResponse>> verifySignupOtp({
    required OtpVerificationRequest request,
  }) async {
    try {
      final response = await _service.verifySignupOtp(request: request);
      return DataState.success(data: response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ErrorResponse.fromMap(
          e.response!.data as Map<String, dynamic>,
        );
        return DataState.error(
          error: errorResponse.message ?? 'Failed to verify OTP',
        );
      }
      return DataState.error(
        error: e.message ?? 'Network error occurred',
      );
    } catch (e) {
      return DataState.error(error: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<DataState<VerifyOtpResponse>> verifyLoginOtp({
    required OtpVerificationRequest request,
  }) async {
    try {
      final response = await _service.verifyLoginOtp(request: request);
      return DataState.success(data: response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ErrorResponse.fromMap(
          e.response!.data as Map<String, dynamic>,
        );
        return DataState.error(
          error: errorResponse.message ?? 'Invalid OTP',
        );
      }
      return DataState.error(
        error: e.message ?? 'Network error occurred',
      );
    } catch (e) {
      return DataState.error(error: 'An unexpected error occurred: $e');
    }
  }
}