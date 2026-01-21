import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/strings.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/images_icons.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';
  
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToWelcome();
  }

  Future<void> _navigateToWelcome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const WelcomeScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);
    return Scaffold(
      body: Stack(
        children: [
          SvgPicture.asset(
            AppImages.splash,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AppImages.logo, height: 100.h),
                11.gapH,
                Text(
                  AppString.appName,
                  style: TextStyle(
                    fontSize: D.textXL,
                    fontFamily: 'Segoe UI',
                    fontWeight: D.extraBold,
                    color: AppColors.textlogo,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}