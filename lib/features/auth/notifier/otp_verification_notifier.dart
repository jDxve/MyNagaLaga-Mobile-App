import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/otp_model.dart';
import '../repository/otp_verification_repository_impl.dart';
import 'auth_session_notifier.dart';

final signupOtpVerificationNotifierProvider =
    NotifierProvider.autoDispose<SignupOtpVerificationNotifier, DataState<VerifyOtpResponse>>(
  SignupOtpVerificationNotifier.new,
);

final loginOtpVerificationNotifierProvider =
    NotifierProvider.autoDispose<LoginOtpVerificationNotifier, DataState<VerifyOtpResponse>>(
  LoginOtpVerificationNotifier.new,
);

class SignupOtpVerificationNotifier extends Notifier<DataState<VerifyOtpResponse>> {
  @override
  DataState<VerifyOtpResponse> build() {
    return const DataState.started();
  }

  Future<void> verifySignupOtp({
    required String email,
    required String token,
  }) async {
    state = const DataState.loading();

    final repository = ref.read(otpVerificationRepositoryProvider);
    final request = OtpVerificationRequest(
      email: email,
      token: token,
    );

    final result = await repository.verifySignupOtp(request: request);
    state = result;

    // Save session if successful
    result.whenOrNull(
      success: (data) async {
        debugPrint('🔍 Signup OTP Verification Success!');
        debugPrint('📧 Email: ${data.userEmail}');
        debugPrint('🆔 User ID: ${data.userId}');
        debugPrint('👤 Full Name: ${data.mobileUser.fullName}');

        if (data.session != null) {
          await ref.read(authSessionProvider.notifier).saveSession(
            accessToken: data.session!.accessToken,
            email: data.userEmail ?? email,
            userId: data.userId,
            fullName: data.mobileUser.fullName,  // ✅ ADD THIS
          );
        }
      },
    );
  }

  void reset() {
    state = const DataState.started();
  }
}

class LoginOtpVerificationNotifier extends Notifier<DataState<VerifyOtpResponse>> {
  @override
  DataState<VerifyOtpResponse> build() {
    return const DataState.started();
  }

  Future<void> verifyLoginOtp({
    required String email,
    required String token,
  }) async {
    state = const DataState.loading();

    final repository = ref.read(otpVerificationRepositoryProvider);
    final request = OtpVerificationRequest(
      email: email,
      token: token,
    );

    final result = await repository.verifyLoginOtp(request: request);
    state = result;

    // Save session if successful
    result.whenOrNull(
      success: (data) async {
        debugPrint('🔍 Login OTP Verification Success!');
        debugPrint('📧 Email: ${data.userEmail}');
        debugPrint('🆔 User ID: ${data.userId}');
        debugPrint('👤 Full Name: ${data.mobileUser.fullName}');

        if (data.session != null) {
          await ref.read(authSessionProvider.notifier).saveSession(
            accessToken: data.session!.accessToken,
            email: data.userEmail ?? email,
            userId: data.userId,
            fullName: data.mobileUser.fullName,  // ✅ ADD THIS
          );
        }
      },
    );
  }

  void reset() {
    state = const DataState.started();
  }
}