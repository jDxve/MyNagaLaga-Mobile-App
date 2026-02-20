import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';

class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 48.w,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          20.gapH,
          Text(
            'No Notifications Yet',
            style: TextStyle(
              fontSize: D.textLG,
              fontWeight: D.bold,
              color: Colors.black87,
            ),
          ),
          8.gapH,
          Text(
            'You\'re all caught up!\nWe\'ll notify you when something arrives.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: D.textSM,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}