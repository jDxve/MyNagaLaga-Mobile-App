import 'package:flutter/material.dart';
import 'package:mynagalaga_mobile_app/features/verify/screens/verify_screen.dart';
import 'features/welcome/screens/onboarding_screen.dart';
import 'features/welcome/screens/splash_screen.dart';
import 'features/welcome/screens/welcome_screen.dart';
import 'features/home/screens/home_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case SplashScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const SplashScreen()),
      );
    case WelcomeScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const WelcomeScreen()),
      );
    case OnboardingScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const OnboardingScreen()),
      );
    case HomeScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const HomeScreen()),
      );
    case VerifyScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const VerifyScreen()),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          //body: ErrorScreen(error: 'Not found'),
        ),
      );
  }
}