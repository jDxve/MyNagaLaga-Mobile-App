import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/resources/assets.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/text_input.dart';
import '../../../common/utils/ui_utils.dart';
import '../../../common/widgets/error_modal.dart';
import '../notifier/auth_notifier.dart';
import 'otp_verification_form.dart';

class LogInForm extends ConsumerStatefulWidget {
  const LogInForm({super.key});

  @override
  ConsumerState<LogInForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LogInForm> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    final emailError = UIUtils.validateEmail(emailController.text);
    if (emailError != null) {
      showErrorModal(
        context: context,
        title: 'Invalid Email',
        description: emailError,
        icon: Icons.email_outlined,
        iconColor: Colors.orange,
      );
      return false;
    }
    return true;
  }

  void _handleLogin() async {
    if (!_validateForm()) return;

    final loginNotifier = ref.read(loginNotifierProvider.notifier);
    await loginNotifier.requestLoginOtp(
      email: emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginNotifierProvider);

    ref.listen(loginNotifierProvider, (previous, next) {
      next.when(
        started: () {},
        loading: () {},
        success: (data) {
          if (data.sent) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerificationForm(
                  email: emailController.text.trim(),
                  isSignup: false,
                ),
              ),
            );
          }
        },
        error: (error) {
          showErrorModal(
            context: context,
            title: 'Login Failed',
            description: error ?? 'Failed to send OTP. Please try again.',
            icon: Icons.error_outline,
            iconColor: Colors.red,
          );
        },
      );
    });

    final isLoading = loginState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

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
              AbsorbPointer(
                absorbing: isLoading,
                child: Opacity(
                  opacity: isLoading ? 0.5 : 1.0,
                  child: TextInput(
                    controller: emailController,
                    hintText: 'Enter your email address',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.grey),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ),
              40.gapH,
              PrimaryButton(
                text: isLoading ? 'Sending OTP...' : 'Sign In',
                onPressed: isLoading ? () {} : _handleLogin,
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
                    onTap: isLoading
                        ? null
                        : () {
                            Navigator.pushNamed(context, '/signup');
                          },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: D.textSM,
                        fontWeight: D.semiBold,
                        color: isLoading ? AppColors.grey : AppColors.primary,
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