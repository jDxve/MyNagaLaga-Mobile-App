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
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    final token = await messaging.getToken();
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔑 FCM Token: $token');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Listen to messages
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint(
        '🔔 ${message.notification?.title}: ${message.notification?.body}',
      );
    });
  }
}
