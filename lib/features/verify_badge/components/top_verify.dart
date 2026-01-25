import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';

Widget topVerify({
  required int currentStep,
  required int totalSteps,
}) {
  String getStepTitle() {
    switch (currentStep) {
      case 1:
        return AppString.step1Title;
      case 2:
        return AppString.step2Title;
      case 3:
        return AppString.step3Title;
      case 4:
        return AppString.step4Title;
      case 5:
        return AppString.step5Title;
      default:
        return AppString.step1Title;
    }
  }

  String getStepDescription() {
    switch (currentStep) {
      case 1:
        return AppString.step1Description;
      case 2:
        return AppString.step2Description;
      case 3:
        return AppString.step3Description;
      case 4:
        return AppString.step4Description;
      case 5:
        return AppString.step5Description;
      default:
        return AppString.step1Description;
    }
  }

  return Column(
    children: [
      Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: TextStyle(
                fontFamily: 'Segoe UI',
                fontSize: D.textSM,
                color: AppColors.grey,
                fontWeight: D.regular,
              ),
            ),
            8.gapH,
            Text(
              getStepTitle(),
              style: TextStyle(
                fontFamily: 'Segoe UI',
                fontSize: D.textLG,
                fontWeight: D.bold,
                color: Colors.black,
              ),
            ),
            16.gapH,
            Stack(
              children: [
                // Lines connecting circles
                Positioned.fill(
                  child: Row(
                    children: List.generate(totalSteps - 1, (index) {
                      final isCompleted = index < currentStep - 1;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 12.w),
                          height: 2.h,
                          color: isCompleted
                              ? AppColors.primary
                              : AppColors.grey.withOpacity(0.3),
                        ),
                      );
                    }),
                  ),
                ),
                // Circles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(totalSteps, (index) {
                    final isCompleted = index < currentStep;
                    final isCurrent = index == currentStep - 1;
                    return Container(
                      width: 12.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted || isCurrent
                            ? AppColors.primary
                            : AppColors.grey.withOpacity(0.3),
                      ),
                    );
                  }),
                ),
              ],
            ),
            16.gapH,
            Text(
              getStepDescription(),
              style: TextStyle(
                fontSize: D.textSM,
                color: AppColors.grey,
                fontWeight: D.medium,
                fontFamily: 'Segoe UI',
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
      Divider(color: AppColors.grey.withOpacity(0.2), thickness: 1, height: 1),
    ],
  );
}