import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// Seam for a crash reporter (Crashlytics/Sentry) to plug into later.
/// `main.dart`'s global error hooks route through this instead of calling a
/// concrete reporter directly, so wiring in a real service is a one-line
/// change at `errorReporterProvider`.
abstract class ErrorReporter {
  void reportError(Object error, StackTrace stack, {String? context});
  void reportFlutterError(FlutterErrorDetails details);
}

class LoggerErrorReporter implements ErrorReporter {
  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 4, dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart),
  );

  @override
  void reportError(Object error, StackTrace stack, {String? context}) {
    _logger.e(
      context != null ? 'Unhandled error [$context]' : 'Unhandled error',
      error: error,
      stackTrace: stack,
    );
  }

  @override
  void reportFlutterError(FlutterErrorDetails details) {
    _logger.e(
      'Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
  }
}

final errorReporterProvider = Provider<ErrorReporter>((ref) => LoggerErrorReporter());
