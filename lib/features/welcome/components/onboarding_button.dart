import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';

class OnboardingButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final bool isLoading;
  final IconData? icon;
  final bool iconAtEnd;
  final double? iconSize;

  const OnboardingButton({
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
            borderRadius: BorderRadius.circular(100),
          ),
          padding: EdgeInsets.symmetric(horizontal: D.w(20)),
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
                    Icon(icon, size: iconSize ?? D.iconMD, color: Colors.white),
                    SizedBox(width: D.w(8)),
                  ],
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: D.textBase,
                      fontWeight: D.semiBold,
                      fontFamily: 'Manrope',
                      color: Colors.white,
                    ),
                  ),
                  if (icon != null && iconAtEnd) ...[
                    SizedBox(width: D.w(8)),
                    Icon(icon, size: iconSize ?? D.iconMD, color: Colors.white),
                  ],
                ],
              ),
      ),
    );
  }
}