// lib/features/auth/repository/auth_repository_impl.dart

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

  AuthRepositoryImpl({
    required AuthService service,
  }) : _service = service;

  @override
  Future<DataState<OtpResponse>> requestSignupOtp({
    required SignupRequest request,
  }) async {
    DataState<OtpResponse> data;

    try {
      final response = await _service.requestSignupOtp(request: request);

      if (response.response.statusCode == 200 || response.response.statusCode == 201) {
        data = DataState.success(data: response.data);
      } else {
        final errorResponse = ErrorResponse.fromMap(
          response.data as Map<String, dynamic>,
        );
        data = DataState.error(
          error: errorResponse.message ?? 'Failed to send OTP',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorResponse = ErrorResponse.fromMap(
          e.response?.data as Map<String, dynamic>,
        );
        data = DataState.error(
          error: errorResponse.message ?? 'An error occurred',
        );
      } else {
        data = DataState.error(
          error: e.message ?? 'Network error occurred',
        );
      }
    } catch (e) {
      data = DataState.error(error: 'An unexpected error occurred: $e');
    }

    return data;
  }

  @override
  Future<DataState<OtpResponse>> requestLoginOtp({
    required LoginRequest request,
  }) async {
    DataState<OtpResponse> data;

    try {
      final response = await _service.requestLoginOtp(request: request);

      if (response.response.statusCode == 200 || response.response.statusCode == 201) {
        data = DataState.success(data: response.data);
      } else {
        final errorResponse = ErrorResponse.fromMap(
          response.data as Map<String, dynamic>,
        );
        data = DataState.error(
          error: errorResponse.message ?? 'Failed to send OTP',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorResponse = ErrorResponse.fromMap(
          e.response?.data as Map<String, dynamic>,
        );
        data = DataState.error(
          error: errorResponse.message ?? 'An error occurred',
        );
      } else {
        data = DataState.error(
          error: e.message ?? 'Network error occurred',
        );
      }
    } catch (e) {
      data = DataState.error(error: 'An unexpected error occurred: $e');
    }

    return data;
  }
}