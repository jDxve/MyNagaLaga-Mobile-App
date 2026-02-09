import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/auth_models.dart';
import '../repository/auth_repository_impl.dart';

final signupNotifierProvider =
    NotifierProvider.autoDispose<SignupNotifier, DataState<OtpResponse>>(
  SignupNotifier.new,
);

final loginNotifierProvider =
    NotifierProvider.autoDispose<LoginNotifier, DataState<OtpResponse>>(
  LoginNotifier.new,
);

class SignupNotifier extends Notifier<DataState<OtpResponse>> {
  @override
  DataState<OtpResponse> build() => const DataState.started();

  Future<void> requestSignupOtp({
    required String email,
    required String fullName,
    required String sex,
    required String address,
    String? phoneNumber,
  }) async {
    state = const DataState.loading();

    final repository = ref.read(authRepositoryProvider);
    final request = SignupRequest(
      email: email,
      fullName: fullName,
      sex: sex,
      address: address,
      phoneNumber: phoneNumber,
    );

    final result = await repository.requestSignupOtp(request: request);
    state = result;
  }

  void reset() {
    state = const DataState.started();
  }
}

class LoginNotifier extends Notifier<DataState<OtpResponse>> {
  @override
  DataState<OtpResponse> build() => const DataState.started();

  Future<void> requestLoginOtp({required String email}) async {
    state = const DataState.loading();

    final repository = ref.read(authRepositoryProvider);
    final request = LoginRequest(email: email);

    final result = await repository.requestLoginOtp(request: request);
    state = result;
  }

  void reset() {
    state = const DataState.started();
  }
}