import 'package:flutter/material.dart';
import '../../../common/resources/dimensions.dart';
import '../components/login_form.dart';

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