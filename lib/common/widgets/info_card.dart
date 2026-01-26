import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';

class InfoCard extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final List<InfoCardItem> items;

  const InfoCard({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(D.radiusLG),
        border: Border.all(color: AppColors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: iconColor ?? AppColors.lightYellow,
                    borderRadius: BorderRadius.circular(D.radiusMD),
                  ),
                  child: Icon(icon, color: Colors.black, size: 20.w),
                ),
                12.gapW,
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: D.textBase,
                  fontWeight: D.semiBold,
                  color: Colors.black,
                  fontFamily: 'Segoe UI',
                ),
              ),
            ],
          ),
          16.gapH,
          ...items.map((item) => _buildItem(item)),
        ],
      ),
    );
  }

  Widget _buildItem(InfoCardItem item) {
    if (item.customWidget != null) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: item.customWidget!,
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: D.textSM,
                color: AppColors.grey,
                fontFamily: 'Segoe UI',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.value,
              style: TextStyle(
                fontSize: D.textSM,
                fontWeight: D.medium,
                color: Colors.black,
                fontFamily: 'Segoe UI',
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCardItem {
  final String label;
  final String value;
  final Widget? customWidget;

  InfoCardItem({
    this.label = '',
    this.value = '',
    this.customWidget,
  });
}