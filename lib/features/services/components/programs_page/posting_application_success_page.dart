import 'package:flutter/material.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../../common/widgets/secondary_button.dart';
import '../../models/welfare_program_model.dart';
import '../../models/welfare_request_model.dart';
import '../../../services/screens/services_screen.dart';

class PostingApplicationSuccessPage extends StatefulWidget {
  final WelfarePostingModel posting;
  final WelfareRequestModel result;

  const PostingApplicationSuccessPage({
    super.key,
    required this.posting,
    required this.result,
  });

  @override
  State<PostingApplicationSuccessPage> createState() =>
      _PostingApplicationSuccessPageState();
}

class _PostingApplicationSuccessPageState
    extends State<PostingApplicationSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              const Spacer(flex: 2),

              ScaleTransition(
                scale: _scaleAnim,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(.06),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 76.w,
                      height: 76.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(.12),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 28.r,
                      ),
                    ),
                  ],
                ),
              ),

              28.gapH,

              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      Text(
                        'Application Submitted!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: D.textXL,
                          fontWeight: D.bold,
                          fontFamily: 'Segoe UI',
                          color: AppColors.black,
                          height: 1.2,
                        ),
                      ),
                      12.gapH,
                      Text(
                        'Your application has been received.\nWe\'ll notify you once it\'s reviewed.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: D.textBase,
                          color: AppColors.grey,
                          fontFamily: 'Segoe UI',
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              32.gapH,

              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(D.radiusLG),
                      border: Border.all(
                        color: AppColors.grey.withOpacity(.12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(.05),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(D.radiusLG),
                              topRight: Radius.circular(D.radiusLG),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.receipt_long_rounded,
                                size: 15.r,
                                color: AppColors.primary,
                              ),
                              6.gapW,
                              Text(
                                'Application Summary',
                                style: TextStyle(
                                  fontSize: D.textSM,
                                  fontWeight: D.semiBold,
                                  color: AppColors.primary,
                                  fontFamily: 'Segoe UI',
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6.w,
                                      height: 6.w,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    4.gapW,
                                    Text(
                                      'Submitted',
                                      style: TextStyle(
                                        fontSize: D.textXS,
                                        fontWeight: D.semiBold,
                                        color: Colors.green,
                                        fontFamily: 'Segoe UI',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.posting.title,
                                style: TextStyle(
                                  fontSize: D.textBase,
                                  fontWeight: D.bold,
                                  fontFamily: 'Segoe UI',
                                  color: AppColors.black,
                                  height: 1.3,
                                ),
                              ),
                              if (widget.posting.serviceName != null) ...[
                                6.gapH,
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_city_rounded,
                                      size: 13.r,
                                      color: AppColors.grey,
                                    ),
                                    4.gapW,
                                    Text(
                                      widget.posting.serviceName!,
                                      style: TextStyle(
                                        fontSize: D.textSM,
                                        color: AppColors.grey,
                                        fontFamily: 'Segoe UI',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 3),

              FadeTransition(
                opacity: _fadeAnim,
                child: SizedBox(
                  width: double.infinity,
                  height: D.primaryButton,
                  child: SecondaryButton(
                    text: 'Back to Services',
                    isFilled: true,
                    onPressed: () =>
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          ServicesScreen.routeName,
                          (r) => false,
                        ),
                  ),
                ),
              ),

              24.gapH,
            ],
          ),
        ),
      ),
    );
  }
}
