import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home/screens/home_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/notifier/auth_session_notifier.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/strings.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/assets.dart';
import 'onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const routeName = '/splash';
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    await _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    if (_hasNavigated) return;

    final session = ref.read(authSessionProvider);
    if (session.isLoading) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final isFirstInstall = prefs.getBool('isFirstInstall') ?? true;

    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;

    if (session.isAuthenticated) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else if (isFirstInstall) {
      await prefs.setBool('isFirstInstall', false);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LogInScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);

    ref.listen(authSessionProvider, (previous, next) {
      if (!next.isLoading && !_hasNavigated) {
        _checkSessionAndNavigate();
      }
    });

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