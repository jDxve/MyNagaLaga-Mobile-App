import 'dart:async';
import 'package:flutter/material.dart';
import '../../../common/resources/assets.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/otp_input.dart';

class OtpVerificationForm extends StatefulWidget {
  final String email;

  const OtpVerificationForm({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationForm> createState() => _OtpVerificationFormState();
}

class _OtpVerificationFormState extends State<OtpVerificationForm> {
  int _remainingSeconds = 300;
  Timer? _timer;

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

  void _resendCode() {
    setState(() {
      _remainingSeconds = 300;
    });
    _startTimer();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _handleOtpCompleted(String otp) {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              Colors.white,
            ],
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
                    onTap: () => Navigator.pop(context),
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
                      OtpInput(
                        onCompleted: _handleOtpCompleted,
                        length: 6,
                      ),
               
                      _remainingSeconds > 0
                          ? Text(
                              'Resend code in ${_formatTime(_remainingSeconds)} seconds',
                              style: TextStyle(
                                fontSize: D.textSM,
                                fontWeight: D.medium,
                                color: AppColors.grey,
                                fontFamily: 'Segoe UI',
                              ),
                            )
                          : GestureDetector(
                              onTap: _resendCode,
                              child: Text(
                                'Resend code',
                                style: TextStyle(
                                  fontSize: D.textSM,
                                  fontWeight: D.medium,
                                  color: AppColors.primary,
                                  fontFamily: 'Segoe UI',
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                      55.gapH,
                      PrimaryButton(
                        text: 'Verify & Continue',
                        onPressed: () {},
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