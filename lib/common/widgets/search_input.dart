import 'package:flutter/material.dart';
import '../resources/colors.dart';
import '../resources/dimensions.dart';

Widget searchInput({
  String hintText = 'Search...',
  TextEditingController? controller,
  ValueChanged<String>? onChanged,
  VoidCallback? onTap,
  bool readOnly = false,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return Container(
    height: 40.h,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(D.radiusXXL),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(
        fontSize: D.textBase,
        fontWeight: D.regular,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: D.textBase,
          fontWeight: D.regular,
        ),
        prefixIcon: prefixIcon ??
            Icon(
              Icons.search,
              color: AppColors.grey,
              size: D.iconMD,
            ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(D.radiusXXL),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(D.radiusXXL),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(D.radiusXXL),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 0,
        ),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
      ),
    ),
  );
}