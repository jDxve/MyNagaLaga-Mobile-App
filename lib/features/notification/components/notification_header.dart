import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';

class NotificationHeader extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onMarkAllRead;
  final VoidCallback onClearAll;

  const NotificationHeader({
    super.key,
    required this.unreadCount,
    required this.onMarkAllRead,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: D.textXL,
                    fontWeight: D.bold,
                    color: Colors.black87,
                  ),
                ),
                if (unreadCount > 0)
                  Text(
                    '$unreadCount unread',
                    style: TextStyle(
                      fontSize: D.textXS,
                      color: AppColors.primary,
                      fontWeight: D.medium,
                    ),
                  ),
              ],
            ),
          ),
          if (unreadCount > 0)
            TextButton(
              onPressed: onMarkAllRead,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                backgroundColor: AppColors.primary.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Mark all read',
                style: TextStyle(
                  fontSize: D.textXS,
                  color: AppColors.primary,
                  fontWeight: D.semiBold,
                ),
              ),
            ),
          8.gapW,
          IconButton(
            onPressed: onClearAll,
            icon: Icon(Icons.delete_outline_rounded, color: Colors.grey[400]),
            tooltip: 'Clear all',
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}