import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Debug-only request/response logging (wired in by `dioProvider` only when
/// `!kReleaseMode`). Redacts the `Authorization` header and any `/auth`
/// request/response bodies so tokens, passwords, and OTPs never hit the
/// console or a log sink, even in debug builds.
class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      printTime: false,
    ),
  );

  bool _isAuthPath(String path) => path.contains('/auth');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i('${options.method} request => ${options.uri}');
    if (options.headers.containsKey('Authorization')) {
      _logger.i('Authorization: Bearer <redacted>');
    }
    if (_isAuthPath(options.path)) {
      _logger.i('${options.method} payload => <redacted, auth endpoint>');
    } else {
      _logger.i('${options.method} payload => ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_isAuthPath(response.requestOptions.path)) {
      _logger.d(
          'StatusCode: ${response.statusCode} <body redacted, auth endpoint>');
    } else {
      _logger.d('StatusCode: ${response.statusCode}, Data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    _logger.d('${options.method} request => ${options.baseUrl}${options.path}');
    _logger.e('Error: ${err.error}, Message: ${err.message}');
    handler.next(err);
  }
}
