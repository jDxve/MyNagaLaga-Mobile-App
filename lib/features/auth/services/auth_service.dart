import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mynagalaga_mobile_app/core/network/dio_factory.dart';
import 'package:mynagalaga_mobile_app/features/auth/models/auth_models.dart';

part 'auth_service.g.dart';

final authServiceProvider = Provider.autoDispose<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthService(dio);
});

@RestApi()
abstract class AuthService {
  factory AuthService(Dio dio, {String? baseUrl}) = _AuthService;

  @POST('/mobile-auth/signup/request-otp')
  Future<HttpResponse<OtpResponse>> requestSignupOtp({
    @Body() required SignupRequest request,
  });

  @POST('/mobile-auth/login/request-otp')
  Future<HttpResponse<OtpResponse>> requestLoginOtp({
    @Body() required LoginRequest request,
  });
}