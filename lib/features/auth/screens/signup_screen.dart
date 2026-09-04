import 'package:flutter/material.dart';
import 'package:mynagalaga_mobile_app/common/resources/dimensions.dart';
import 'package:mynagalaga_mobile_app/features/auth/components/signup_form.dart';

class SignUpScreen extends StatelessWidget {
  static const routeName = '/signup';
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    D.init(context);
    return const Scaffold(
      body: SignUpForm(),
    );
  }
}