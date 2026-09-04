import 'package:mynagalaga_mobile_app/core/network/data_state.dart';
import 'package:mynagalaga_mobile_app/features/auth/models/otp_model.dart';

abstract class OtpVerificationRepository {
  Future<DataState<VerifyOtpResponse>> verifySignupOtp({
    required OtpVerificationRequest request,
  });

  Future<DataState<VerifyOtpResponse>> verifyLoginOtp({
    required OtpVerificationRequest request,
  });
}