import '../../../common/models/dio/data_state.dart';
import '../models/otp_model.dart';

abstract class OtpVerificationRepository {
  Future<DataState<VerifyOtpResponse>> verifySignupOtp({
    required OtpVerificationRequest request,
  });

  Future<DataState<VerifyOtpResponse>> verifyLoginOtp({
    required OtpVerificationRequest request,
  });
}