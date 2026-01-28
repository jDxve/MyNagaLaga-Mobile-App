import '../../../common/models/dio/data_state.dart';
import '../models/otp_model.dart';

abstract class OtpVerificationRepository {
  Future<DataState<VerifyOtpResponse>> verifyOtp({
    required OtpVerificationRequest request,
  });
}