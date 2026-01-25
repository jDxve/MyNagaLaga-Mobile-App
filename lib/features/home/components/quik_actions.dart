import 'package:flutter/material.dart';
import '../../../common/models/simple_option.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/images_icons.dart';
import '../../verify_badge/screens/verify_badge_screen.dart';

Widget quickActions(BuildContext context) {
  final List<SimpleOption> actions = [
    SimpleOption(
      id: 1,
      icon: AppImages.verifyIcon,
      title: 'Verify',
    ),
    SimpleOption(
      id: 2,
      icon: AppImages.requestIcon,
      title: 'Request',
    ),
    SimpleOption(
      id: 3,
      icon: AppImages.addFamilyIcon,
      title: 'Add Family',
    ),
    SimpleOption(
      id: 4,
      icon: AppImages.shelterIcon,
      title: 'Find Shelter',
    ),
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
                if (action.id == 1) {
                  Navigator.pushNamed(context, VerifyBadgeScreen.routeName);
                }
                // Add other navigation here
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 60.w,
                    height: 50.h,
                    child: Center(
                      child: Image.asset(
                        action.icon!,
                        width: 30.w,
                        height: 30.h,
                      ),
                    ),
                  ),
                  Text(
                    action.title!,
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