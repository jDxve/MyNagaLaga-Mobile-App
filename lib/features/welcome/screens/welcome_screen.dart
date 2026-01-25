import 'package:flutter/material.dart';
import 'package:mynagalaga_mobile_app/features/welcome/components/onboarding_button.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/images_icons.dart';
import '../../../common/resources/strings.dart';
import '../../../common/resources/dimensions.dart';
import 'onboarding_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const routeName = '/welcome';
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreen();
}

class _WelcomeScreen extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    D.init(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          50.gapH,
          Image.asset(
            AppImages.getStarted,
            width: double.infinity,
            height: 400.h,
          ),
          30.gapH,
          Text(
            AppString.appName,
            style: TextStyle(
              color: AppColors.secondary,
              fontFamily: 'Manrope',
              fontSize: D.textXL,
              fontWeight: D.semiBold,
            ),
          ),
          12.gapH,
          Center(
            child: Text(
              AppString.welcomeMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.grey,
                fontFamily: 'Manrope',
                fontSize: D.textBase,
                fontWeight: D.medium,
              ),
            ),
          ),
          35.gapH,
          OnboardingButton(
            text: AppString.letsGetStarted,
            width: 210.w,
            icon: Icons.chevron_right,

            iconAtEnd: true,
            onPressed: () {
              Navigator.pushNamed(context, OnboardingScreen.routeName);
            },
          ),
          10.gapH,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppString.alreadyHaveAccount,
                style: TextStyle(
                  color: AppColors.grey,
                  fontFamily: 'Manrope',
                  fontSize: D.textXS,
                  fontWeight: D.medium,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to sign-in screen
                },
                child: Text(
                  AppString.signIn,
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontFamily: 'Manrope',
                    fontSize: D.textXS,
                    fontWeight: D.medium,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
