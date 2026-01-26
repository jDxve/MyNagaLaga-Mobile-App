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
  final baseBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(D.radiusXXL),
    borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
  );

  return TextField(
    controller: controller,
    onChanged: onChanged,
    onTap: onTap,
    readOnly: readOnly,
    textAlignVertical: TextAlignVertical.center,
    style: TextStyle(fontSize: D.textBase, fontWeight: D.regular),
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: D.textBase),
      prefixIcon:
          prefixIcon ??
          Icon(Icons.search, color: AppColors.grey, size: D.iconMD),
      suffixIcon: suffixIcon,

      // Background styling
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),

      // Border definitions
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
  );
}
