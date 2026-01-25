import 'package:flutter/material.dart';
import '../resources/colors.dart';
import '../resources/dimensions.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final bool isLoading;
  final bool isDisabled;
  final bool isFilled;
  final IconData? icon;
  final bool iconAtEnd;
  final double? iconSize;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFilled = false,
    this.icon,
    this.iconAtEnd = false,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: D.secondaryButton,
      child: isFilled
          ? ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDisabled
                    ? AppColors.grey.withOpacity(0.3)
                    : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(D.radiusLG),
                ),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: D.w(16)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: isLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null && !iconAtEnd) ...[
                          Icon(
                            icon,
                            size: iconSize ?? D.iconMD,
                            color: Colors.white,
                          ),
                          SizedBox(width: D.w(4)),
                        ],
                        8.gapW,
                        Text(
                          text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: D.textMD,
                            fontWeight: D.semiBold,
                            fontFamily: 'Segoe UI',
                            color: Colors.white,
                          ),
                        ),
                        if (icon != null && iconAtEnd) ...[
                          5.gapW,
                          Icon(
                            icon,
                            size: iconSize ?? D.iconMD,
                            color: Colors.white,
                          ),
                        ],
                      ],
                    ),
            )
          : OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDisabled
                      ? AppColors.grey.withOpacity(0.3)
                      : AppColors.grey,
                  width: 1,
                ),
                foregroundColor: AppColors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(D.radiusLG),
                ),
                padding: EdgeInsets.symmetric(horizontal: D.w(16)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: isLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.grey),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null && !iconAtEnd) ...[
                          Icon(
                            icon,
                            size: iconSize ?? D.iconMD,
                            color: AppColors.grey,
                          ),
                          SizedBox(width: D.w(4)),
                        ],
                        8.gapW,
                        Text(
                          text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: D.textBase,
                            fontWeight: D.semiBold,
                            fontFamily: 'Segoe UI',
                            color: AppColors.grey,
                          ),
                        ),
                        if (icon != null && iconAtEnd) ...[
                          5.gapW,
                          Icon(
                            icon,
                            size: iconSize ?? D.iconMD,
                            color: AppColors.grey,
                          ),
                        ],
                      ],
                    ),
            ),
    );
  }
}