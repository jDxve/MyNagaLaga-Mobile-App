import 'package:flutter/material.dart';
import '../resources/colors.dart';
import '../resources/assets.dart';

Widget gradientBackground({required Widget child}) {
  return Container(
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary,
          AppColors.primary,
          AppColors.primary.withOpacity(0.5),
          AppColors.primary.withOpacity(0.0),
          Colors.white,
          Colors.white,
        ],
        stops: const [0.0, 0.1, 0.25, 0.70, 0.4, 1.0],
      ),
    ),
    child: Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,

          child: Image.asset(
            Assets.homeBG,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        child,
      ],
    ),
  );
}
