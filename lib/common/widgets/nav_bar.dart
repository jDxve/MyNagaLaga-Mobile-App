import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/simple_option.dart';
import '../resources/colors.dart';
import '../resources/dimensions.dart';
import '../resources/assets.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  List<SimpleOption> get navItems => [
    SimpleOption(id: 0, icon: Assets.homeIcon, title: 'Home'),
    SimpleOption(id: 1, icon: Assets.familyIcon, title: 'Family'),
    SimpleOption(id: 2, icon: Assets.servicesIcon, title: 'Services'),
    SimpleOption(id: 3, icon: Assets.saftyIcon, title: 'Safety'),
    SimpleOption(id: 4, icon: null, title: 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        child: Container(
          height: 64.h,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: navItems.map((item) {
              final isSelected = currentIndex == item.id;
              final color = isSelected ? AppColors.primary : const Color(0xFF637381);

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(item.id!),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (item.id == 4)
                        Icon(
                          Icons.person_rounded,
                          size: 27.w,
                          color: color,
                        )
                      else
                        SvgPicture.asset(
                          item.icon!,
                          width: 24.w,
                          height: 24.h,
                          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                        ),
                      4.gapH,
                      Text(
                        item.title!,
                        style: TextStyle(
                          fontSize: 12.f,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: color,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}