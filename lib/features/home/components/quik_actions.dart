import 'package:flutter/material.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/images_icons.dart';

Widget quickActions() {
  final List<Map<String, String>> actions = [
    {
      'icon': AppImages.verifyIcon,
      'title': 'Verify',
    },
    {
      'icon': AppImages.requestIcon,
      'title': 'Request',
    },
    {
      'icon': AppImages.addFamilyIcon,
      'title': 'Add Family',
    },
    {
      'icon': AppImages.shelterIcon,
      'title': 'Find Shelter',
    },
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.bold,
          ),
        ),
      ),
      6.gapH,
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((action) {
            return GestureDetector(
              onTap: () {
                // Handle tap
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 60.w,
                    height: 50.h,
                    child: Center(
                      child: Image.asset(
                        action['icon']!,
                        width: 30.w,
                        height: 30.h,
                      
                      ),
                    ),
                  ),
       
                  Text(
                    action['title']!,
                    style: TextStyle(
                      fontSize: D.textSM,
                      fontWeight: D.medium,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}