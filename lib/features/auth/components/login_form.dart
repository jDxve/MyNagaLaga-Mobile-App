import 'package:flutter/material.dart';
import '../../../common/resources/assets.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/text_input.dart';

class LogInForm extends StatefulWidget {
  const LogInForm({super.key});

  @override
  State<LogInForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LogInForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Colors.white],
          stops: const [0.0, 0.45],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              70.gapH,
              Image.asset(
                Assets.logo,
                width: 120.w,
                height: 100.h,
                fit: BoxFit.contain,
              ),
              20.gapH,
              Text(
                'Welcome back to MyNaga',
                style: TextStyle(
                  fontSize: D.textLG,
                  fontWeight: D.bold,
                  color: AppColors.black,
                  fontFamily: 'Segoe UI',
                ),
              ),
              4.gapH,
              Text(
                'Sign in to your account',
                style: TextStyle(
                  fontSize: D.textBase,
                  fontWeight: D.semiBold,
                  color: AppColors.grey,
                  fontFamily: 'Segoe UI',
                ),
              ),
              30.gapH,
              _buildLabel('Email Address'),
              8.gapH,
              TextInput(
                controller: emailController,
                hintText: 'Enter your email address',
                prefixIcon: Icon(Icons.email_outlined, color: AppColors.grey),
                keyboardType: TextInputType.emailAddress,
              ),
              15.gapH,
              _buildLabel('Password'),
              8.gapH,
              TextInput(
                controller: passwordController,
                hintText: 'Enter your password',
                prefixIcon: Icon(Icons.lock_outline, color: AppColors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                obscureText: _obscurePassword,
              ),
              12.gapH,
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: D.textSM,
                      fontWeight: D.medium,
                      color: AppColors.primary,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                ),
              ),
              40.gapH,
              PrimaryButton(
                text: 'Sign In',
                onPressed: () {},
              ),
              20.gapH,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: TextStyle(
                      fontSize: D.textSM,
                      color: AppColors.black,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: D.textSM,
                        fontWeight: D.semiBold,
                        color: AppColors.primary,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: D.textBase,
        fontWeight: D.medium,
        color: AppColors.black,
        fontFamily: 'Segoe UI',
      ),
    );
  }
}