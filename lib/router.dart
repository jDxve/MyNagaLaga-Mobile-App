import 'package:flutter/material.dart';
import 'features/welcome/screens/onboarding_screen.dart';
import 'features/welcome/screens/splash_screen.dart';
import 'features/welcome/screens/welcome_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/verify_badge/screens/verify_badge_screen.dart';
import 'features/account/screens/account_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case SplashScreen.routeName:
      return MaterialPageRoute(builder: ((context) => const SplashScreen()));
    case WelcomeScreen.routeName:
      return MaterialPageRoute(builder: ((context) => const WelcomeScreen()));
    case OnboardingScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const OnboardingScreen()),
      );
    case HomeScreen.routeName:
      return MaterialPageRoute(builder: ((context) => const HomeScreen()));
    case VerifyBadgeScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const VerifyBadgeScreen()),
      );
    case AccountScreen.routeName:
      return MaterialPageRoute(builder: ((context) => const AccountScreen()));
    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          //body: ErrorScreen(error: 'Not found'),
        ),
      );
  }
}
