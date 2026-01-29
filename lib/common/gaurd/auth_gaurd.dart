import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynagalaga_mobile_app/features/auth/screens/login_screen.dart';
import 'package:mynagalaga_mobile_app/features/auth/notifier/auth_session_notifier.dart';

class AuthGuard extends ConsumerWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);

    if (!session.isAuthenticated) {
      // Use microtask to avoid building during state transition
      Future.microtask(() {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(LogInScreen.routeName, (route) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return child;
  }
}
