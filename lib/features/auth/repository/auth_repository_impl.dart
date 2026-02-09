import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/models/responses/error_response.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import 'auth_repository.dart';

final authRepositoryProvider = Provider.autoDispose<AuthRepositoryImpl>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthRepositoryImpl(service: service);
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _service;

  AuthRepositoryImpl({required AuthService service}) : _service = service;

  @override
  Future<DataState<OtpResponse>> requestSignupOtp({
    required SignupRequest request,
  }) async {
    try {
      final response = await _service.requestSignupOtp(request: request);
      return DataState.success(data: response.data);
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to send OTP');
    } catch (e) {
      return DataState.error(error: 'An unexpected error occurred');
    }
  }

  @override
  Future<DataState<OtpResponse>> requestLoginOtp({
    required LoginRequest request,
  }) async {
    try {
      final response = await _service.requestLoginOtp(request: request);
      return DataState.success(data: response.data);
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to send OTP');
    } catch (e) {
      return DataState.error(error: 'An unexpected error occurred');
    }
  }

  DataState<OtpResponse> _handleDioError(DioException e, String defaultMessage) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return DataState.error(
        error: 'Connection timeout. Please check your internet connection.',
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return DataState.error(
        error: 'Cannot connect to server. Please check your internet connection.',
      );
    }

    final statusCode = e.response?.statusCode;

    if (statusCode == 404) {
      return DataState.error(error: 'Service not found. Please contact support.');
    }

    if (statusCode == 500 || statusCode == 502 || statusCode == 503) {
      return DataState.error(
        error: 'Server error. Please try again later.',
      );
    }

    if (statusCode == 429) {
      return DataState.error(
        error: 'Too many requests. Please wait a moment and try again.',
      );
    }

    if (statusCode == 409) {
      return DataState.error(
        error: 'Email already registered. Please login instead.',
      );
    }

    if (e.response?.data != null) {
      try {
        final errorResponse = ErrorResponse.fromMap(
          e.response!.data as Map<String, dynamic>,
        );
        return DataState.error(error: errorResponse.message ?? defaultMessage);
      } catch (_) {
        return DataState.error(error: defaultMessage);
      }
    }

    return DataState.error(error: e.message ?? defaultMessage);
  }
}