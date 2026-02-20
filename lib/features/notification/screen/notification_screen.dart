import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../model/notification_model.dart';
import '../notifier/notification_notifier.dart';
import '../components/notification_tile.dart';

class NotificationScreen extends ConsumerWidget {
  static const routeName = '/notifications';

  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationNotifierProvider);
    final notifier = ref.read(notificationNotifierProvider.notifier);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        title: unreadCount > 0 ? 'Notifications ($unreadCount)' : 'Notifications',
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                  12.gapH,
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: D.textBase,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // ✅ Actions bar
                if (notifications.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (unreadCount > 0)
                          TextButton.icon(
                            onPressed: notifier.markAllAsRead,
                            icon: Icon(Icons.done_all_rounded,
                                size: 16.w, color: AppColors.primary),
                            label: Text(
                              'Mark all read',
                              style: TextStyle(
                                fontSize: D.textXS,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        TextButton.icon(
                          onPressed: () => _showClearDialog(context, notifier),
                          icon: Icon(Icons.delete_outline_rounded,
                              size: 16.w, color: Colors.grey[400]),
                          label: Text(
                            'Clear all',
                            style: TextStyle(
                              fontSize: D.textXS,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return NotificationTile(
                        notification: notif,
                        onTap: () {
                          notifier.markAsRead(notif.id);
                          _handleTap(context, notif);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _handleTap(BuildContext context, NotificationModel notif) {
    switch (notif.type) {
      case 'COMPLAINT_STATUS_UPDATE':
      case 'CASE_STATUS_UPDATE':
        Navigator.pushNamed(context, '/track-cases');
        break;
      case 'ASSISTANCE_REQUEST_STATUS_UPDATE':
      case 'DISBURSEMENT_UPDATE':
        Navigator.pushNamed(context, '/services');
        break;
      default:
        break;
    }
  }

  void _showClearDialog(BuildContext context, NotificationNotifier notifier) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear all notifications?'),
        content: const Text('This will remove all notifications permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notifier.clearAll();
              Navigator.pop(context);
            },
            child: Text('Clear', style: TextStyle(color: Colors.red[400])),
          ),
        ],
      ),
    );
  }
}