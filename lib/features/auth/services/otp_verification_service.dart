import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../../core/network/dio_factory.dart';
import '../models/otp_model.dart';

part 'otp_verification_service.g.dart';

final otpVerificationServiceProvider =
    Provider.autoDispose<OtpVerificationService>((ref) {
  final dio = ref.watch(dioProvider);
  return OtpVerificationService(dio);
});

@RestApi()
abstract class OtpVerificationService {
  factory OtpVerificationService(Dio dio, {String? baseUrl}) =
      _OtpVerificationService;

  @POST('/mobile-auth/signup/verify-otp')
  Future<HttpResponse<VerifyOtpResponse>> verifySignupOtp({
    @Body() required OtpVerificationRequest request,
  });

  @POST('/mobile-auth/login/verify-otp')
  Future<HttpResponse<VerifyOtpResponse>> verifyLoginOtp({
    @Body() required OtpVerificationRequest request,
  });

  @POST('/mobile-auth/fcm-token')
  Future<HttpResponse<void>> updateFcmToken({
    @Body() required Map<String, dynamic> body,
    @Header('Authorization') required String authorization,
  });
}