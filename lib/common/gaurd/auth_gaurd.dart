import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynagalaga_mobile_app/features/auth/screens/login_screen.dart';
import 'package:mynagalaga_mobile_app/features/auth/notifier/auth_session_notifier.dart';

/// AuthGuard - Protects routes from unauthenticated access
/// 
/// Wrap any screen that requires authentication:
/// ```dart
/// AuthGuard(child: HomeScreen())
/// ```
class AuthGuard extends ConsumerWidget {
  final Widget child;

  const AuthGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(authSessionProvider);

    if (!isAuthenticated) {
      Future.microtask(() {
        Navigator.of(context).pushNamedAndRemoveUntil(
          LogInScreen.routeName,
          (route) => false,
        );
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return child;
  }
}