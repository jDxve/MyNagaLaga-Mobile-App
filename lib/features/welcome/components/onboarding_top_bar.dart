import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';

Widget buildOnboardingTopBar({
  required int currentPage,
  required VoidCallback onBackPressed,
  required VoidCallback onSkipPressed,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: 30.w,
      vertical: 15.h,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onBackPressed,
          child: Container(
            width: 35.w,
            height: 35.h,
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: D.iconSM,
              color: AppColors.primary,
            ),
          ),
        ),
        GestureDetector(
          onTap: onSkipPressed,
          child: Text(
            'Skip',
            style: TextStyle(
              color: AppColors.primary,
              fontFamily: 'Manrope',
              fontSize: D.textBase,
              fontWeight: D.medium,
            ),
          ),
        ),
      ],
    ),
  );
}