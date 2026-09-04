import 'package:shared_preferences/shared_preferences.dart';

const _kIsFirstInstallKey = 'isFirstInstall';

/// True until [markInstalled] is called once - drives whether the
/// onboarding flow shows on the very first launch after install.
Future<bool> isFirstInstall() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kIsFirstInstallKey) ?? true;
}

Future<void> markInstalled() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kIsFirstInstallKey, false);
}
