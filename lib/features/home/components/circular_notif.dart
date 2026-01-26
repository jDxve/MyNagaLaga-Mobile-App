import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/assets.dart';

Widget circularNotif({
  VoidCallback? onTap,
  int notificationCount = 0,
  double? size,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: size ?? 40.w,
      height: size ?? 40.h,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: SvgPicture.asset(
              Assets.notifIcon,
              width: D.iconLG,
              height: D.iconLG,
            ),
          ),
          if (notificationCount > 0)
            Positioned(
              top: 6.h,
              right: 6.w,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.h),
                child: Center(
                  child: Text(
                    notificationCount > 99
                        ? '99+'
                        : notificationCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: D.textXS,
                      fontWeight: D.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
