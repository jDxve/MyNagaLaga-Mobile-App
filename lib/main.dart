import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynagalaga_mobile_app/common/firebase/firebase_config.dart';
import 'package:mynagalaga_mobile_app/core/config/app_config.dart';
import 'package:mynagalaga_mobile_app/core/observability/error_reporter.dart';
import 'package:mynagalaga_mobile_app/features/welcome/screens/splash_screen.dart';
import 'package:mynagalaga_mobile_app/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  AppConfig.assertSecureBaseUrl();

  final container = ProviderContainer();
  final reporter = container.read(errorReporterProvider);

  // Two OS-level catch-alls installed before runApp so no uncaught error is
  // invisible in production - neither substitutes the user-facing toast/
  // ErrorView shown at the DataState edge, they exist so *we* see the
  // failures too, not just the ones a repository routed through DataState.
  FlutterError.onError = (details) {
    FlutterError.presentError(details); // keep the red screen in debug
    reporter.reportFlutterError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    reporter.reportError(error, stack, context: 'PlatformDispatcher');
    return true; // handled - don't let it crash silently
  };

  await FirebaseConfig.initialize();
  FirebaseConfig.setContainer(container);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
      initialRoute: SplashScreen.routeName,
    );
  }
}