import 'package:flutter/material.dart';
import 'package:mynagalaga_mobile_app/common/resources/dimensions.dart';
import 'package:mynagalaga_mobile_app/features/auth/components/login_form.dart';

class LogInScreen extends StatelessWidget {
  static const routeName = '/login';
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    D.init(context);
    return const Scaffold(
      body: LogInForm(),
    );
  }
}