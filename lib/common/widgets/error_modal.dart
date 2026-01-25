import 'package:flutter/material.dart';
import '../resources/colors.dart';
import '../resources/dimensions.dart';
import 'primary_button.dart';

void showErrorModal({
  required BuildContext context,
  required String title,
  required String description,
  String? buttonText,
  VoidCallback? onButtonPressed,
  IconData? icon,
  Color? iconColor,
  bool barrierDismissible = true,
}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(D.radiusXL),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon ?? Icons.error_outline,
                color: iconColor ?? Colors.red,
                size: 48.w,
              ),
              16.gapH,
              Text(
                title,
                style: TextStyle(
                  fontSize: D.textXL,
                  fontWeight: D.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              12.gapH,
              Text(
                description,
                style: TextStyle(
                  fontSize: D.textBase,
                  color: AppColors.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              24.gapH,
              PrimaryButton(
                text: buttonText ?? 'Okay',
                onPressed: () {
                  Navigator.pop(context);
                  if (onButtonPressed != null) {
                    onButtonPressed();
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}