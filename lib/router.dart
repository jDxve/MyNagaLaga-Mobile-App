import 'package:flutter/material.dart';
import 'features/account/screens/account_screen.dart';
import 'features/services/screens/services_screen.dart';
import 'features/services/screens/women_welfare_screen.dart';
import 'features/welcome/screens/onboarding_screen.dart';
import 'features/welcome/screens/splash_screen.dart';
import 'features/welcome/screens/welcome_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/verify_badge/screens/verify_badge_screen.dart';
import 'features/services/screens/children_youth_screen.dart';
import 'features/services/screens/family_community_screen.dart';
import 'features/services/screens/crisis_intervention_screen.dart';
import 'features/services/screens/disaster_response_screen.dart';

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
    case ServicesScreen.routeName:
      return MaterialPageRoute(builder: ((context) => const ServicesScreen()));
    case ChildrenYouthScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const ChildrenYouthScreen()),
      );
    case WomenWelfareScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const WomenWelfareScreen()),
      );
    case FamilyCommunityScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const FamilyCommunityScreen()),
      );
    case CrisisInterventionScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const CrisisInterventionScreen()),
      );
    case DisasterResponseScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const DisasterResponseScreen()),
      );
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
