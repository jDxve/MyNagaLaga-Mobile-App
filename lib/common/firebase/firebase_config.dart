import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

/// Background message handler (must be top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('🔔 Background: ${message.notification?.title}');
}

class FirebaseConfig {
  /// Initialize Firebase & FCM
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _setupFCM();
  }

  static Future<void> _setupFCM() async {
    final messaging = FirebaseMessaging.instance;

    // Request permission
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      debugPrint('🔕 Notifications not authorized — skipping FCM token fetch');
      return;
    }

    // iOS requires APNs token before FCM token is available
    // Simulators never get an APNs token, so we guard here
    if (Platform.isIOS) {
      String? apnsToken;
      for (int i = 0; i < 5; i++) {
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) break;
        debugPrint('⏳ Waiting for APNs token... attempt ${i + 1}');
        await Future.delayed(const Duration(seconds: 1));
      }

      if (apnsToken == null) {
        debugPrint('⚠️ APNs token unavailable (simulator or capability missing) — skipping FCM token fetch');
        return;
      }
    }

    final token = await messaging.getToken();
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔑 FCM Token: $token');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Token refresh listener
    messaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 FCM Token refreshed: $newToken');
      // TODO: send newToken to your backend here
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint(
        '🔔 ${message.notification?.title}: ${message.notification?.body}',
      );
    });
  }
}