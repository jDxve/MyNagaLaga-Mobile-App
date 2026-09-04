import 'package:dio/dio.dart';

import 'models/error_response.dart';

enum AppErrorType {
  timeout,
  connection,
  unauthorized,
  validation,
  server,
  client,
  unknown,
}

/// Transport-agnostic error carried out of the data layer. Repositories map
/// `DioException` -> `AppException` (via `AppException.fromDioException` or
/// a repository-specific `mapError` override passed to `RepositoryGuard`);
/// nothing above the repository should see a `DioException`.
class AppException implements Exception {
  final int? statusCode;
  final String? message;
  final AppErrorType type;
  final List<String>? validationIssues;

  const AppException({
    this.statusCode,
    this.message,
    this.type = AppErrorType.unknown,
    this.validationIssues,
  });

  factory AppException.fromDioException(
    DioException e, {
    String? fallbackMessage,
  }) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const AppException(type: AppErrorType.timeout);
    }
    if (e.type == DioExceptionType.connectionError) {
      return const AppException(type: AppErrorType.connection);
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (statusCode == 401) {
      return AppException(
        statusCode: statusCode,
        type: AppErrorType.unauthorized,
        message: _extractServerMessage(data),
      );
    }

    if (statusCode == 400 && data is Map<String, dynamic> && data['details'] is List) {
      final issues = (data['details'] as List)
          .map((issue) => issue.toString())
          .toList(growable: false);
      return AppException(
        statusCode: statusCode,
        type: AppErrorType.validation,
        validationIssues: issues,
        message: _extractServerMessage(data),
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return AppException(
        statusCode: statusCode,
        type: AppErrorType.server,
        message: _extractServerMessage(data),
      );
    }

    if (statusCode != null) {
      return AppException(
        statusCode: statusCode,
        type: AppErrorType.client,
        message: _extractServerMessage(data) ?? fallbackMessage,
      );
    }

    return AppException(type: AppErrorType.unknown, message: e.message ?? fallbackMessage);
  }

  static String? _extractServerMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    try {
      return ErrorResponse.fromMap(data).message;
    } catch (_) {
      return null;
    }
  }

  /// The single place an `AppException` becomes user-facing copy. Prefers an
  /// explicit `message` (set by the server, or by a repository's `mapError`
  /// override) over the generic per-type copy.
  String toMessage({String fallback = 'Something went wrong. Please try again.'}) {
    if (message != null && message!.isNotEmpty) return message!;
    return switch (type) {
      AppErrorType.timeout => 'Connection timeout. Please check your internet connection.',
      AppErrorType.connection => 'Cannot connect to server. Please check your internet connection.',
      AppErrorType.unauthorized => 'Your session has expired. Please log in again.',
      AppErrorType.server => 'Server error. Please try again later.',
      AppErrorType.validation => validationIssues?.join('\n') ?? fallback,
      AppErrorType.client => fallback,
      AppErrorType.unknown => fallback,
    };
  }
}
