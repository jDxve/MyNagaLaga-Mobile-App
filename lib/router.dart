import 'package:flutter/material.dart';
import 'package:mynagalaga_mobile_app/features/auth/screens/login_screen.dart';
import 'package:mynagalaga_mobile_app/features/auth/screens/signup_screen.dart';
import 'package:mynagalaga_mobile_app/features/services/screens/track_services_screen.dart';
import 'common/gaurd/auth_gaurd.dart';
import 'features/account/screens/account_screen.dart';
import 'features/family/screens/family_ledger_screen.dart';
import 'features/safety/screens/disaster_resilience_screen.dart';

import 'features/services/screens/program_screen.dart';
import 'features/services/screens/services_screen.dart';
import 'features/welcome/screens/onboarding_screen.dart';
import 'features/welcome/screens/splash_screen.dart';
import 'features/welcome/screens/welcome_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/verify_badge/screens/verify_badge_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    // ✅ Public routes (NO AuthGuard)
    case SplashScreen.routeName:
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    case WelcomeScreen.routeName:
      return MaterialPageRoute(builder: (_) => const WelcomeScreen());
    case OnboardingScreen.routeName:
      return MaterialPageRoute(builder: (_) => const OnboardingScreen());
    case SignUpScreen.routeName:
      return MaterialPageRoute(builder: (_) => const SignUpScreen());
    case LogInScreen.routeName:
      return MaterialPageRoute(builder: (_) => const LogInScreen());

    // 🔒 Protected routes (WITH AuthGuard)
    case HomeScreen.routeName:
      return MaterialPageRoute(
        builder: (_) => const AuthGuard(child: HomeScreen()),
      );
    case ServicesScreen.routeName:
      return MaterialPageRoute(
        builder: (_) => const AuthGuard(child: ServicesScreen()),
      );
    case TrackCasesScreen.routeName:
      return MaterialPageRoute(
        builder: (_) => const AuthGuard(child: TrackCasesScreen()),
      );
    case ProgramScreen.routeName:
      final args = settings.arguments as ProgramScreenArgs?;
      if (args == null) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Missing program arguments.')),
          ),
        );
      }
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => AuthGuard(child: ProgramScreen(args: args)),
      );
    case DisasterResilienceScreen.routeName:
      return MaterialPageRoute(
        builder: (_) => const AuthGuard(child: DisasterResilienceScreen()),
      );
    case VerifyBadgeScreen.routeName:
      return MaterialPageRoute(
        builder: (_) => const AuthGuard(child: VerifyBadgeScreen()),
      );
    case AccountScreen.routeName:
      return MaterialPageRoute(
        builder: (_) => const AuthGuard(child: AccountScreen()),
      );
    case FamilyLedgerScreen.routeName:
      return MaterialPageRoute(
        builder: (_) => const AuthGuard(child: FamilyLedgerScreen()),
      );

    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      );
  }
}