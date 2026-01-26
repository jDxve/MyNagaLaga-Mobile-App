import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/simple_option.dart';
import '../resources/colors.dart';
import '../resources/dimensions.dart';
import '../resources/assets.dart';

class BottomNavigation extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final List<SimpleOption> navItems = [
    SimpleOption(id: 0, icon: Assets.homeIcon, title: 'Home'),
    SimpleOption(id: 1, icon: Assets.familyIcon, title: 'Family'),
    SimpleOption(id: 2, icon: Assets.servicesIcon, title: 'Services'),
    SimpleOption(id: 3, icon: Assets.saftyIcon, title: 'Safety'),
    SimpleOption(id: 4, icon: Assets.acountIcon, title: 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        child: Container(
          height: 60.h,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.map((item) {
              final isSelected = widget.currentIndex == item.id;
              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onTap(item.id!),
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          item.icon!,
                          width: 22.w,
                          height: 22.h,
                          colorFilter: ColorFilter.mode(
                            isSelected ? AppColors.primary : AppColors.grey,
                            BlendMode.srcIn,
                          ),
                        ),
                        2.gapH,
                        Text(
                          item.title!,
                          style: TextStyle(
                            fontSize: D.textXS,
                            fontWeight: isSelected ? D.semiBold : D.regular,
                            color: isSelected ? AppColors.primary : AppColors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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