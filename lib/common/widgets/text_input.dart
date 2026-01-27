import 'package:flutter/material.dart';
import '../resources/colors.dart';
import '../resources/dimensions.dart';

class TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;

  const TextInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: maxLines == 1 ? 45.h : null,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        obscureText: obscureText,
        style: TextStyle(
          fontSize: D.textBase,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: D.textBase,
            color: AppColors.grey.withOpacity(0.5),
          ),
          prefixIcon: prefixIcon ??
              (prefixText != null
                  ? Padding(
                      padding: EdgeInsets.only(left: 16.w, right: 8.w),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            prefixText!,
                            style: TextStyle(
                              fontSize: D.textBase,
                              color: AppColors.grey.withOpacity(0.5),
                              fontWeight: D.medium,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null),
          prefixIconConstraints: prefixText != null
              ? BoxConstraints(minWidth: 0, minHeight: 0)
              : null,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: prefixText != null ? 0 : 16.w,
            vertical: maxLines == 1 ? 0 : 14.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(D.radiusLG),
            borderSide: BorderSide(
              color: AppColors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(D.radiusLG),
            borderSide: BorderSide(
              color: AppColors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(D.radiusLG),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}