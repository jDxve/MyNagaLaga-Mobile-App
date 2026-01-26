import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/assets.dart';

class ServicesHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;

  const ServicesHeader({
    super.key,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Services',
          style: TextStyle(
            fontFamily: 'Segoe UI',
            fontSize: D.textXXL,
            fontWeight: D.bold,
            color: Colors.black,
          ),
        ),
        InkWell(
          onTap: onNotificationTap,
          borderRadius: BorderRadius.circular(D.radiusXXL),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.grey.withOpacity(0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(D.radiusXXL),
            ),
            child: SvgPicture.asset(
              Assets.notifIcon,
              width: 24.w,
              height: 24.h,
            ),
          ),
        ),
      ],
    );
  }
}