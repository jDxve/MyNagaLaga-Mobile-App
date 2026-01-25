import 'package:flutter/material.dart';
import '../resources/colors.dart';
import '../resources/dimensions.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final bool isLoading;
  final IconData? icon;
  final bool iconAtEnd;
  final double? iconSize;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.isLoading = false,
    this.icon,
    this.iconAtEnd = false,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: D.secondaryButton,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(D.radiusXXL),
          ),
          padding: EdgeInsets.symmetric(horizontal: D.w(16)),
          // Fixes the alignment issue:
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null && !iconAtEnd) ...[
                    Icon(icon, size: iconSize ?? D.iconMD),
                    SizedBox(width: D.w(4)),
                  ],
                  8.gapW,
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: D.textBase,
                      fontWeight: D.semiBold,
                      fontFamily: 'Manrope', // Matches your WelcomeScreen
                    ),
                  ),
                  if (icon != null && iconAtEnd) ...[
                    5.gapW,
                    Icon(icon, size: iconSize ?? D.iconMD),
                  ],
                ],
              ),
      ),
    );
  }
}
