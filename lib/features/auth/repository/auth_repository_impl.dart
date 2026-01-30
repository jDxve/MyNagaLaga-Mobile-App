import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    try {
      debugPrint('📤 Sending signup OTP request: ${request.toJson()}');
      final response = await _service.requestSignupOtp(request: request);
      debugPrint('📥 Signup OTP response: ${response.data}');
      return DataState.success(data: response.data);
    } on DioException catch (e) {
      debugPrint('❌ DioException status: ${e.response?.statusCode}');
      debugPrint('❌ DioException data: ${e.response?.data}');
      
      if (e.response?.data != null) {
        final errorResponse = ErrorResponse.fromMap(
          e.response!.data as Map<String, dynamic>,
        );
        return DataState.error(
          error: errorResponse.message ?? 'Failed to send OTP',
        );
      }
      return DataState.error(
        error: e.message ?? 'Network error occurred',
      );
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return DataState.error(error: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<DataState<OtpResponse>> requestLoginOtp({
    required LoginRequest request,
  }) async {
    try {
      debugPrint('📤 Sending login OTP request: ${request.toJson()}');
      final response = await _service.requestLoginOtp(request: request);
      debugPrint('📥 Login OTP response: ${response.data}');
      return DataState.success(data: response.data);
    } on DioException catch (e) {
      debugPrint('❌ DioException status: ${e.response?.statusCode}');
      debugPrint('❌ DioException data: ${e.response?.data}');
      
      if (e.response?.data != null) {
        final errorResponse = ErrorResponse.fromMap(
          e.response!.data as Map<String, dynamic>,
        );
        return DataState.error(
          error: errorResponse.message ?? 'Failed to send OTP',
        );
      }
      return DataState.error(
        error: e.message ?? 'Network error occurred',
      );
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return DataState.error(error: 'An unexpected error occurred: $e');
    }
  }
}