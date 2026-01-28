import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../models/otp_model.dart';

part 'otp_verification_service.g.dart';

final otpVerificationServiceProvider = Provider.autoDispose<OtpVerificationService>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://kqwkwwyoidmfzvoctokb.supabase.co',
    headers: {'Content-Type': 'application/json'},
  ));
  return OtpVerificationService(dio);
});

@RestApi()
abstract class OtpVerificationService {
  factory OtpVerificationService(Dio dio, {String? baseUrl}) = _OtpVerificationService;

  @POST('/auth/v1/verify')
  Future<HttpResponse<VerifyOtpResponse>> verifyOtp({
    @Body() required OtpVerificationRequest request,
  });
}