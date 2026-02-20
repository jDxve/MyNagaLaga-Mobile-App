import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../model/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  IconData _getIcon(String type) {
    switch (type) {
      case 'COMPLAINT_STATUS_UPDATE':
        return Icons.report_outlined;
      case 'CASE_STATUS_UPDATE':
        return Icons.folder_outlined;
      case 'ANNOUNCEMENT':
        return Icons.campaign_outlined;
      case 'ASSISTANCE_REQUEST_STATUS_UPDATE':
        return Icons.volunteer_activism_outlined;
      case 'DISBURSEMENT_UPDATE':
        return Icons.payments_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isRead
                ? Colors.transparent
                : AppColors.primary.withOpacity(0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(notification.type),
                color: AppColors.primary,
                size: D.iconSM,
              ),
            ),
            12.gapW,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: D.textSM,
                      fontWeight: isRead ? D.medium : D.bold,
                      color: AppColors.black,
                    ),
                  ),
                  4.gapH,
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: D.textXS,
                      color: AppColors.grey,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  6.gapH,
                  Text(
                    _formatTime(notification.receivedAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.grey.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 8.w,
                height: 8.w,
                margin: EdgeInsets.only(left: 8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}