import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';

class FamilyLedgerBanner extends StatelessWidget {
  const FamilyLedgerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Banner
        Container(
          width: double.infinity,
          height: 140.h,
          decoration: BoxDecoration(
            color: AppColors.lightPrimary,
            borderRadius: BorderRadius.circular(D.radiusLG),
          ),
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Keep your family\ndetails organized\nin one place',
                      style: TextStyle(
                        fontSize: D.textBase,
                        fontWeight: D.bold,
                        color: AppColors.textlogo,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              8.gapW,
              // Placeholder for illustration
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(D.radiusMD),
                ),
                child: Icon(
                  Icons.family_restroom,
                  size: 60.w,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        20.gapH,

        // About Section
        Text(
          'About Family Ledger',
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.bold,
            color: AppColors.textlogo,
          ),
        ),
        8.gapH,
        Text(
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
          style: TextStyle(
            fontSize: D.textSM,
            color: AppColors.grey,
            height: 1.5,
          ),
        ),
        24.gapH,
      ],
    );
  }
}