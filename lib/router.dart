import 'package:flutter/material.dart';
import 'features/welcome/screens/onboarding_screen.dart';
import 'features/welcome/screens/welcome_screen.dart';

import 'features/welcome/screens/splash_screen.dart';

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
    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          //body: ErrorScreen(error: 'Not found'),
        ),
      );
  }
}