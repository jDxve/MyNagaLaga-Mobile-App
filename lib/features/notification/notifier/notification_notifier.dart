import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../model/notification_model.dart';

const _cacheKey = 'cached_notifications';
const _uuid = Uuid();

final notificationNotifierProvider =
    NotifierProvider<NotificationNotifier, List<NotificationModel>>(
  NotificationNotifier.new,
);

class NotificationNotifier extends Notifier<List<NotificationModel>> {
  @override
  List<NotificationModel> build() {
    _loadFromCache();
    return [];
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return;

    try {
      final List decoded = jsonDecode(raw);
      final notifications =
          decoded.map((e) => NotificationModel.fromJson(e)).toList();
      state = notifications;
    } catch (_) {
      state = [];
    }
  }

  Future<void> _saveToCache() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_cacheKey, encoded);
  }

  Future<void> addNotification({
    required String title,
    required String body,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final notification = NotificationModel.fromRemoteMessage(
      id: _uuid.v4(),
      title: title,
      body: body,
      type: type,
      data: data,
    );
    state = [notification, ...state];
    await _saveToCache();
  }

  Future<void> markAsRead(String id) async {
    state = state
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    await _saveToCache();
  }

  Future<void> markAllAsRead() async {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
    await _saveToCache();
  }

  Future<void> clearAll() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  int get unreadCount => state.where((n) => !n.isRead).length;
}

// Convenience provider for unread count
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationNotifierProvider);
  return notifications.where((n) => !n.isRead).length;
});