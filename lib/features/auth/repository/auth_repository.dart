import 'package:mynagalaga_mobile_app/core/network/data_state.dart';
import 'package:mynagalaga_mobile_app/features/auth/models/auth_models.dart';

abstract class AuthRepository {
  Future<DataState<OtpResponse>> requestSignupOtp({
    required SignupRequest request,
  });

  Future<DataState<OtpResponse>> requestLoginOtp({
    required LoginRequest request,
  });
}