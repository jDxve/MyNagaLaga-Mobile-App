import 'package:flutter/material.dart';
import '../../../common/resources/dimensions.dart';
import '../components/signup_form.dart';

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