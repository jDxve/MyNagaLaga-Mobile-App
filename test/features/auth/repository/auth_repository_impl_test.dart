// Reference test for the RepositoryGuard pattern (my-flutter-way.md §7):
// mock the service one layer down, assert both the DataSuccess branch and
// that a repository-specific mapError override survives the migration onto
// the shared guard() helper (auth's 409 keeps its own copy instead of
// falling back to the generic message).

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrofit/retrofit.dart';

import 'package:mynagalaga_mobile_app/core/network/data_state.dart';
import 'package:mynagalaga_mobile_app/features/auth/models/auth_models.dart';
import 'package:mynagalaga_mobile_app/features/auth/repository/auth_repository_impl.dart';
import 'package:mynagalaga_mobile_app/features/auth/services/auth_service.dart';

class _MockAuthService extends Mock implements AuthService {}

class _FakeSignupRequest extends Fake implements SignupRequest {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeSignupRequest());
  });

  late _MockAuthService service;
  late AuthRepositoryImpl repository;

  setUp(() {
    service = _MockAuthService();
    repository = AuthRepositoryImpl(service: service);
  });

  SignupRequest signupRequest() => SignupRequest(
        email: 'a@b.com',
        fullName: 'A B',
        sex: 'M',
        address: '123 Main St',
      );

  group('requestSignupOtp', () {
    test('returns Success and carries the OTP response through', () async {
      final requestOptions = RequestOptions(path: '/mobile-auth/signup/request-otp');
      when(() => service.requestSignupOtp(request: any(named: 'request'))).thenAnswer(
        (_) async => HttpResponse(
          OtpResponse(sent: true),
          Response(requestOptions: requestOptions, statusCode: 200),
        ),
      );

      final result = await repository.requestSignupOtp(request: signupRequest());

      expect(result, isA<Success<OtpResponse>>());
      expect((result as Success<OtpResponse>).data.sent, isTrue);
    });

    test('maps a 409 to the preserved "already registered" copy, not the generic fallback', () async {
      final requestOptions = RequestOptions(path: '/mobile-auth/signup/request-otp');
      when(() => service.requestSignupOtp(request: any(named: 'request'))).thenThrow(
        DioException(
          requestOptions: requestOptions,
          response: Response(requestOptions: requestOptions, statusCode: 409),
        ),
      );

      final result = await repository.requestSignupOtp(request: signupRequest());

      expect(result, isA<Error<OtpResponse>>());
      expect(
        (result as Error<OtpResponse>).error,
        'Email already registered. Please login instead.',
      );
    });

    test('falls back to the generic message for an unmapped status code', () async {
      final requestOptions = RequestOptions(path: '/mobile-auth/signup/request-otp');
      when(() => service.requestSignupOtp(request: any(named: 'request'))).thenThrow(
        DioException(
          requestOptions: requestOptions,
          response: Response(requestOptions: requestOptions, statusCode: 418),
        ),
      );

      final result = await repository.requestSignupOtp(request: signupRequest());

      expect(result, isA<Error<OtpResponse>>());
      expect((result as Error<OtpResponse>).error, isNotNull);
    });
  });
}
