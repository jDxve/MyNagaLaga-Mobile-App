import 'package:flutter/material.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';
import '../../../common/widgets/secondary_button.dart';

Widget previousNextButton({
  required VoidCallback onPrevious,
  required VoidCallback onNext,
  bool isDisabled = false,
}) {
  return Container(
    padding: EdgeInsets.all(20.w),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          offset: Offset(0, -2),
          blurRadius: 8,
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: SecondaryButton(
            text: AppString.previous,
            onPressed: onPrevious,
          ),
        ),
        12.gapW,
        Expanded(
          child: SecondaryButton(
            text: AppString.next,
            isFilled: true,
            isDisabled: isDisabled,
            onPressed: onNext,
          ),
        ),
      ],
    ),
  );
}