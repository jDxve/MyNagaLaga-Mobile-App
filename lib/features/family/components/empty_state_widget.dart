import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            32.gapH,
            _buildTitle(),
            12.gapH,
            _buildMessage(),
            if (primaryButtonText != null && onPrimaryPressed != null) ...[
              40.gapH,
              _buildPrimaryButton(),
            ],
            if (secondaryButtonText != null && onSecondaryPressed != null) ...[
              16.gapH,
              _buildSecondaryButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 64.w,
        color: AppColors.primary.withOpacity(0.6),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: TextStyle(
        fontSize: D.textXL,
        fontWeight: D.bold,
        color: AppColors.textlogo,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage() {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: D.textSM,
        color: AppColors.grey,
        height: 1.5,
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPrimaryPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(D.radiusLG),
          ),
          elevation: 0,
        ),
        child: Text(
          primaryButtonText!,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onSecondaryPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(D.radiusLG),
          ),
          side: BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        child: Text(
          secondaryButtonText!,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}