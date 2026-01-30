import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/resources/assets.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/otp_input.dart';
import '../../../common/widgets/error_modal.dart';
import '../../../common/utils/ui_utils.dart';
import '../notifier/otp_verification_notifier.dart';
import '../notifier/auth_notifier.dart';
import '../../home/screens/home_screen.dart';

class OtpVerificationForm extends ConsumerStatefulWidget {
  final String email;
  final bool isSignup;

  const OtpVerificationForm({
    super.key,
    required this.email,
    this.isSignup = false,
  });

  @override
  ConsumerState<OtpVerificationForm> createState() =>
      _OtpVerificationFormState();
}

class _OtpVerificationFormState extends ConsumerState<OtpVerificationForm> {
  int _remainingSeconds = 300;
  Timer? _timer;
  String _otpCode = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _resendCode() async {
    setState(() {
      _remainingSeconds = 300;
    });
    _startTimer();

    if (widget.isSignup) {
      // Resend OTP for signup
      final signupNotifier = ref.read(signupNotifierProvider.notifier);
      await signupNotifier.requestSignupOtp(
        email: widget.email,
        fullName: '', // These will be ignored by backend for resend
        sex: 'Male',
        address: '',
      );
      
      showErrorModal(
        context: context,
        title: 'OTP Resent',
        description: 'A new OTP code has been sent to ${widget.email}',
        icon: Icons.check_circle_outline,
        iconColor: Colors.green,
      );
    } else {
      final loginNotifier = ref.read(loginNotifierProvider.notifier);
      await loginNotifier.requestLoginOtp(email: widget.email);
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _handleOtpCompleted(String otp) {
    setState(() {
      _otpCode = otp;
    });
  }

  void _handleVerifyOtp() async {
    final otpError = UIUtils.validateOtp(_otpCode);
    if (otpError != null) {
      showErrorModal(
        context: context,
        title: 'Invalid OTP',
        description: otpError,
        icon: Icons.password,
        iconColor: Colors.orange,
      );
      return;
    }

    if (widget.isSignup) {
      final signupOtpNotifier = ref.read(
        signupOtpVerificationNotifierProvider.notifier,
      );
      await signupOtpNotifier.verifySignupOtp(
        email: widget.email,
        token: _otpCode,
      );
    } else {
      final loginOtpNotifier = ref.read(
        loginOtpVerificationNotifierProvider.notifier,
      );
      await loginOtpNotifier.verifyLoginOtp(
        email: widget.email,
        token: _otpCode,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final otpState = widget.isSignup
        ? ref.watch(signupOtpVerificationNotifierProvider)
        : ref.watch(loginOtpVerificationNotifierProvider);

    ref.listen(
      widget.isSignup
          ? signupOtpVerificationNotifierProvider
          : loginOtpVerificationNotifierProvider,
      (previous, next) {
        next.when(
          started: () {},
          loading: () {},
          success: (data) {
            // Session is already saved by the notifier
            showErrorModal(
              context: context,
              title: 'Verification Successful',
              description: 'Your account has been verified successfully!',
              icon: Icons.check_circle_outline,
              iconColor: Colors.green,
              barrierDismissible: false,
              onButtonPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  HomeScreen.routeName,
                  (route) => false,
                );
              },
            );
          },
          error: (error) {
            showErrorModal(
              context: context,
              title: 'Verification Failed',
              description: error ?? 'Invalid OTP code. Please try again.',
              icon: Icons.error_outline,
              iconColor: Colors.red,
            );
          },
        );
      },
    );

    final isLoading = otpState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Scaffold(
      body: Container(
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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: isLoading ? null : () => Navigator.pop(context),
                    child: Container(
                      height: 40.h,
                      width: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18.f,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                        'Input the 6-digit code',
                        style: TextStyle(
                          fontSize: D.textLG,
                          fontWeight: D.bold,
                          color: AppColors.black,
                          fontFamily: 'Segoe UI',
                        ),
                      ),
                      4.gapH,
                      Text(
                        'We sent a 6 digit code to ${widget.email}',
                        style: TextStyle(
                          fontSize: D.textSM,
                          fontWeight: D.semiBold,
                          color: AppColors.grey,
                          fontFamily: 'Segoe UI',
                        ),
                      ),
                      32.gapH,
                      AbsorbPointer(
                        absorbing: isLoading,
                        child: Opacity(
                          opacity: isLoading ? 0.5 : 1.0,
                          child: OtpInput(
                            onCompleted: _handleOtpCompleted,
                            length: 6,
                          ),
                        ),
                      ),
                      24.gapH,
                      _remainingSeconds > 0
                          ? Text(
                              'Resend code in ${_formatTime(_remainingSeconds)}',
                              style: TextStyle(
                                fontSize: D.textSM,
                                fontWeight: D.medium,
                                color: AppColors.grey,
                                fontFamily: 'Segoe UI',
                              ),
                            )
                          : GestureDetector(
                              onTap: isLoading ? null : _resendCode,
                              child: Text(
                                'Resend code',
                                style: TextStyle(
                                  fontSize: D.textSM,
                                  fontWeight: D.medium,
                                  color: isLoading
                                      ? AppColors.grey
                                      : AppColors.primary,
                                  fontFamily: 'Segoe UI',
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                      40.gapH,
                      PrimaryButton(
                        text: isLoading ? 'Verifying...' : 'Verify & Continue',
                        onPressed: isLoading ? () {} : _handleVerifyOtp,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}