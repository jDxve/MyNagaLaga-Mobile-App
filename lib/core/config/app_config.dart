import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';

  /// Fails fast at boot in release builds if the API URL isn't https, rather
  /// than surfacing as a confusing connection error on the first request.
  static void assertSecureBaseUrl() {
    if (kReleaseMode && !apiBaseUrl.startsWith('https://')) {
      throw StateError(
        'API_BASE_URL must use https in release builds. '
        'Current value: "$apiBaseUrl". Set API_BASE_URL before shipping.',
      );
    }
  }
}
