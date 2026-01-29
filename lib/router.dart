import 'package:flutter/material.dart';
import 'package:mynagalaga_mobile_app/features/auth/screens/login_screen.dart';
import 'package:mynagalaga_mobile_app/features/auth/screens/signup_screen.dart';
import 'package:mynagalaga_mobile_app/features/services/screens/programs/track_services_screen.dart';
import 'features/account/screens/account_screen.dart';
import 'features/safety/screens/disaster_resilience_screen.dart';
import 'features/services/screens/services_screen.dart';
import 'features/services/screens/programs/women_welfare_screen.dart';
import 'features/welcome/screens/onboarding_screen.dart';
import 'features/welcome/screens/splash_screen.dart';
import 'features/welcome/screens/welcome_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/verify_badge/screens/verify_badge_screen.dart';
import 'features/services/screens/programs/children_youth_screen.dart';
import 'features/services/screens/programs/family_community_screen.dart';
import 'features/services/screens/programs/crisis_intervention_screen.dart';
import 'features/services/screens/programs/disaster_response_screen.dart';

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
    case SignUpScreen.routeName:
      return MaterialPageRoute(builder: ((context) => const SignUpScreen()));
    case LogInScreen.routeName:
      return MaterialPageRoute(builder: ((context) => const LogInScreen()));
    case HomeScreen.routeName:
      return MaterialPageRoute(builder: ((context) => const HomeScreen()));
    case ServicesScreen.routeName:
      return MaterialPageRoute(builder: ((context) => const ServicesScreen()));
    case TrackCasesScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const TrackCasesScreen()),
      );
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
    case DisasterResilienceScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const DisasterResilienceScreen()),
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