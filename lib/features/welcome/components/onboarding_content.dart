import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';

Widget buildOnboardingContent({
  required String title,
  required String description,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 24.w),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.secondary,
            fontFamily: 'Manrope',
            fontSize: D.textXL,
            fontWeight: D.semiBold,
          ),
          textAlign: TextAlign.center,
        ),
        12.gapH,
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.grey,
            fontFamily: 'Manrope',
            fontSize: D.textBase,
            fontWeight: D.medium,
          ),
        ),
        30.gapH,
      ],
    ),
  );
}
