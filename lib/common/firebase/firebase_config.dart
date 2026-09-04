import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mynagalaga_mobile_app/firebase_options.dart';
import 'package:mynagalaga_mobile_app/features/notification/notifier/notification_notifier.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final title = message.notification?.title ?? '';
  final body = message.notification?.body ?? '';
  final type = message.data['type'] ?? 'GENERAL';

  if (title.isEmpty) return;

  // ✅ Riverpod not available in background — save directly to SharedPreferences
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cached_notifications');
    final List existing = raw != null ? jsonDecode(raw) : [];

    existing.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'type': type,
      'data': message.data,
      'receivedAt': DateTime.now().toIso8601String(),
      'isRead': false,
    });

    await prefs.setString('cached_notifications', jsonEncode(existing));
    debugPrint('🔔 Background cached: $title');
  } catch (e) {
    debugPrint('❌ Background cache failed: $e');
  }
}

class FirebaseConfig {
  static ProviderContainer? _container;

  static void setContainer(ProviderContainer container) {
    _container = container;
  }

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _setupFCM();
  }

  static Future<void> _setupFCM() async {
    final messaging = FirebaseMessaging.instance;

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

    if (Platform.isIOS) {
      String? apnsToken;
      for (int i = 0; i < 5; i++) {
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) break;
        debugPrint('⏳ Waiting for APNs token... attempt ${i + 1}');
        await Future.delayed(const Duration(seconds: 1));
      }
      if (apnsToken == null) {
        debugPrint('⚠️ APNs token unavailable — skipping FCM token fetch');
        return;
      }
    }

    try {
      final token = await messaging.getToken();
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔑 FCM Token: $token');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e) {
      debugPrint('❌ FCM getToken failed: $e');
      return;
    }

    messaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 FCM Token refreshed: $newToken');
    });

    // ✅ Foreground
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('🔔 ${message.notification?.title}: ${message.notification?.body}');
      _cacheNotification(message);
    });

    // ✅ Background tap
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('📲 Opened from background: ${message.notification?.title}');
      _cacheNotification(message);
    });

    // ✅ Terminated tap
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('🚀 Opened from terminated: ${initialMessage.notification?.title}');
      _cacheNotification(initialMessage);
    }
  }

  static void _cacheNotification(RemoteMessage message) {
    final container = _container;
    if (container == null) return;

    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';
    final type = message.data['type'] ?? 'GENERAL';

    if (title.isEmpty) return;

    container.read(notificationNotifierProvider.notifier).addNotification(
          title: title,
          body: body,
          type: type,
          data: message.data,
        );
  }
}