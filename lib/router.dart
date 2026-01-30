import 'package:flutter/material.dart';
import 'package:mynagalaga_mobile_app/features/auth/screens/login_screen.dart';
import 'package:mynagalaga_mobile_app/features/auth/screens/signup_screen.dart';
import 'package:mynagalaga_mobile_app/features/services/screens/programs/track_services_screen.dart';
import 'common/gaurd/auth_gaurd.dart';
import 'features/account/screens/account_screen.dart';
import 'features/family/screens/family_ledger_screen.dart';
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
    // ✅ Public routes (NO AuthGuard)
    case SplashScreen.routeName:
      return MaterialPageRoute(builder: ((context) => const SplashScreen()));
    case WelcomeScreen.routeName:
      return MaterialPageRoute(builder: ((context) => const WelcomeScreen()));
    case OnboardingScreen.routeName:
      return MaterialPageRoute(builder: ((context) => const OnboardingScreen()));
    case SignUpScreen.routeName:
      return MaterialPageRoute(builder: ((context) => const SignUpScreen()));
    case LogInScreen.routeName:
      return MaterialPageRoute(builder: ((context) => const LogInScreen()));

    // 🔒 Protected routes (WITH AuthGuard)
    case HomeScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const AuthGuard(child: HomeScreen())),
      );
    case ServicesScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const AuthGuard(child: ServicesScreen())),
      );
    case TrackCasesScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const AuthGuard(child: TrackCasesScreen())),
      );
    case ChildrenYouthScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const AuthGuard(child: ChildrenYouthScreen())),
      );
    case WomenWelfareScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const AuthGuard(child: WomenWelfareScreen())),
      );
    case FamilyCommunityScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const AuthGuard(child: FamilyCommunityScreen())),
      );
    case CrisisInterventionScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const AuthGuard(child: CrisisInterventionScreen())),
      );
    case DisasterResponseScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const AuthGuard(child: DisasterResponseScreen())),
      );
    case DisasterResilienceScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const AuthGuard(child: DisasterResilienceScreen())),
      );
    case VerifyBadgeScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const AuthGuard(child: VerifyBadgeScreen())),
      );
    case AccountScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const AuthGuard(child: AccountScreen())),
      );
    case FamilyLedgerScreen.routeName:
      return MaterialPageRoute(
        builder: ((context) => const AuthGuard(child: FamilyLedgerScreen())),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      );
  }
}