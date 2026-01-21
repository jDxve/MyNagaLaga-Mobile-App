import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/secondary_button.dart';

Widget buildOnboardingBottomSection({
  required int currentPage,
  required int totalPages,
  required VoidCallback onNextPressed,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            totalPages,
            (index) => buildPageIndicatorDot(isActive: index == currentPage),
          ),
        ),
        SecondaryButton(
          text: 'Next',
          onPressed: onNextPressed,
          icon: Icons.arrow_forward_ios,
          iconAtEnd: true,
          iconSize: D.iconXS,
          width: 100.w,
        ),
      ],
    ),
  );
}

Widget buildPageIndicatorDot({
  required bool isActive,
  double height = 7,
  double activeWidth = 35,
  double inactiveWidth = 7,
  Color? activeColor,
  Color? inactiveColor,
}) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    margin: EdgeInsets.symmetric(horizontal: 3.w),
    height: height.h,
    width: (isActive ? activeWidth : inactiveWidth).w,
    decoration: BoxDecoration(
      color: isActive
          ? (activeColor ?? AppColors.primary)
          : (inactiveColor ?? AppColors.grey.withOpacity(0.3)),
      borderRadius: BorderRadius.circular(12.r),
    ),
  );
}
