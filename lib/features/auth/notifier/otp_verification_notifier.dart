import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/otp_model.dart';
import '../repository/otp_verification_repository_impl.dart';

final otpVerificationNotifierProvider =
    NotifierProvider.autoDispose<OtpVerificationNotifier, DataState<VerifyOtpResponse>>(
  OtpVerificationNotifier.new,
);

class OtpVerificationNotifier extends Notifier<DataState<VerifyOtpResponse>> {
  @override
  DataState<VerifyOtpResponse> build() {
    return const DataState.started();
  }

  Future<void> verifyOtp({
    required String email,
    required String token,
  }) async {
    state = const DataState.loading();

    final repository = ref.read(otpVerificationRepositoryProvider);

    final request = OtpVerificationRequest(
      email: email,
      token: token,
      type: 'email',
    );

    final result = await repository.verifyOtp(request: request);

    state = result;
  }

  void reset() {
    state = const DataState.started();
  }
}