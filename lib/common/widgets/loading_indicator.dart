import 'package:flutter/material.dart';
import '../resources/colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double? size;
  final Color? color;
  final double? strokeWidth;

  const LoadingIndicator({
    super.key,
    this.size,
    this.color,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 40,
      height: size ?? 40,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth ?? 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
      ),
    );
  }
}