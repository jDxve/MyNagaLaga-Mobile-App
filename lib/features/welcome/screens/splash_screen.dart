import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home/screens/home_screen.dart';
import '../../auth/notifier/auth_session_notifier.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/strings.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/assets.dart';
import 'welcome_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const routeName = '/splash';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final session = ref.read(authSessionProvider);
    final prefs = await SharedPreferences.getInstance();
    final isFirstInstall = prefs.getBool('isFirstInstall') ?? true;

    if (!mounted) return;

    if (session.isAuthenticated) {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } else if (isFirstInstall) {
      await prefs.setBool('isFirstInstall', false);
      Navigator.pushReplacementNamed(context, WelcomeScreen.routeName);
    } else {
      Navigator.pushReplacementNamed(context, WelcomeScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);
    return Scaffold(
      body: Stack(
        children: [
          SvgPicture.asset(
            Assets.splash,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(Assets.logo, height: 100.h),
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