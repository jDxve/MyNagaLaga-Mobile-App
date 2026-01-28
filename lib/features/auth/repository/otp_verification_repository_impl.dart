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
  Future<DataState<VerifyOtpResponse>> verifyOtp({
    required OtpVerificationRequest request,
  }) async {
    DataState<VerifyOtpResponse> data;

    try {
      final response = await _service.verifyOtp(request: request);

      if (response.response.statusCode == 200 || response.response.statusCode == 201) {
        data = DataState.success(data: response.data);
      } else {
        final errorResponse = ErrorResponse.fromMap(
          response.data as Map<String, dynamic>,
        );
        data = DataState.error(
          error: errorResponse.message ?? 'Failed to verify OTP',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorResponse = ErrorResponse.fromMap(
          e.response?.data as Map<String, dynamic>,
        );
        data = DataState.error(
          error: errorResponse.message ?? 'Invalid OTP',
        );
      } else {
        data = DataState.error(
          error: e.message ?? 'Network error occurred',
        );
      }
    } catch (e) {
      data = DataState.error(error: 'An unexpected error occurred: $e');
    }

    return data;
  }
}