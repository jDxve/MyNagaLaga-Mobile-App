import '../../../common/models/dio/data_state.dart';
import '../models/auth_models.dart';

abstract class AuthRepository {
  Future<DataState<OtpResponse>> requestSignupOtp({
    required SignupRequest request,
  });

  Future<DataState<OtpResponse>> requestLoginOtp({
    required LoginRequest request,
  });
}