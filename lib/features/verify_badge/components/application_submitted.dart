import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';
import '../../../common/widgets/secondary_button.dart';

Widget applicationSubmitted({
  required BuildContext context,
  String? referenceNumber,
  VoidCallback? onStartNewApplication,
  VoidCallback? onBackToHome,
}) {
  return _ApplicationSubmittedWidget(
    referenceNumber: referenceNumber,
    onStartNewApplication: onStartNewApplication,
    onBackToHome: onBackToHome,
  );
}

class _ApplicationSubmittedWidget extends StatefulWidget {
  final String? referenceNumber;
  final VoidCallback? onStartNewApplication;
  final VoidCallback? onBackToHome;

  const _ApplicationSubmittedWidget({
    this.referenceNumber,
    this.onStartNewApplication,
    this.onBackToHome,
  });

  @override
  State<_ApplicationSubmittedWidget> createState() =>
      _ApplicationSubmittedWidgetState();
}

class _ApplicationSubmittedWidgetState
    extends State<_ApplicationSubmittedWidget> {
  late ConfettiController _confettiController;
  late String _referenceNumber;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _referenceNumber = widget.referenceNumber ?? _generateReferenceNumber();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _confettiController.play();
      }
    });
  }

  String _generateReferenceNumber() {
    final now = DateTime.now();
    final random = Random();
    final datePart =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomPart = (10000 + random.nextInt(90000)).toString();
    return 'MNA-$datePart-$randomPart';
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);

    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 50.w,
                    color: Colors.white,
                  ),
                ),
                24.gapH,

                Text(
                  AppString.applicationSubmittedTitle,
                  style: TextStyle(
                    fontSize: D.textXL,
                    fontWeight: D.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                12.gapH,

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    AppString.applicationSubmittedDescription,
                    style: TextStyle(
                      fontSize: D.textBase,
                      color: AppColors.grey,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                32.gapH,

                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(D.radiusLG),
                    border: Border.all(
                      color: AppColors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppString.referenceNumberLabel,
                        style: TextStyle(
                          fontSize: D.textSM,
                          color: AppColors.grey,
                        ),
                      ),
                      8.gapH,
                      SelectableText(
                        _referenceNumber,
                        style: TextStyle(
                          fontSize: D.textLG,
                          fontWeight: D.bold,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                40.gapH,

                SecondaryButton(
                  text: AppString.startNewApplication,
                  onPressed: widget.onStartNewApplication ?? () {},
                  isFilled: false,
                ),
                12.gapH,
                SecondaryButton(
                  text: AppString.backToHome,
                  onPressed: widget.onBackToHome ?? () {},
                  isFilled: true,
                ),
              ],
            ),
          ),
        ),

        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            maxBlastForce: 20,
            minBlastForce: 5,
            gravity: 0.3,
            colors: [
              AppColors.primary,
              AppColors.secondary,
              Colors.green,
              Colors.orange,
              Colors.pink,
              Colors.blue,
            ],
          ),
        ),
      ],
    );
  }
}
