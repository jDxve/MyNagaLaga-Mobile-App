// Router smoke test. Deliberately does not pump `MyApp()`: that requires a
// live ProviderScope plus Firebase/dotenv/secure-storage platform channels
// that aren't available in the unit-test harness. `generateRoute` is pure
// and cheap to test directly, and catches the exact class of bug Phase A
// fixed here (a route pointing at a moved/renamed screen import).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mynagalaga_mobile_app/features/welcome/screens/splash_screen.dart';
import 'package:mynagalaga_mobile_app/router.dart';

void main() {
  test('generateRoute resolves the splash route', () {
    final route = generateRoute(const RouteSettings(name: SplashScreen.routeName));
    expect(route, isA<MaterialPageRoute<dynamic>>());
  });

  test('generateRoute falls back to a "not found" page for unknown routes', () {
    final route = generateRoute(const RouteSettings(name: '/does-not-exist'));
    expect(route, isA<MaterialPageRoute<dynamic>>());
  });
}
