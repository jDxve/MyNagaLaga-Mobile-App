import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/assets.dart';

class ServicesSection extends StatelessWidget {
  final VoidCallback? onRequestServicesTap;
  final VoidCallback? onComplaintsTap;

  const ServicesSection({
    super.key,
    this.onRequestServicesTap,
    this.onComplaintsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services',
          style: TextStyle(
            fontSize: D.textLG,
            fontWeight: D.bold,
            color: AppColors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        8.gapH,
        Text(
          'Access community services and local programs instantly.',
          style: TextStyle(
            fontSize: D.textSM,
            color: AppColors.grey,
            fontFamily: 'Segoe UI',
          ),
        ),
        16.gapH,
        _ServiceCard(
          iconPath: Assets.reqServiceIcon,
          iconColor: AppColors.primary,
          backgroundColor: AppColors.lightPrimary,
          title: 'Request Services',
          subtitle: 'Skip the line, apply online.',
          onTap: onRequestServicesTap,
        ),
        12.gapH,
        _ServiceCard(
          iconPath: Assets.complaintIcon,
          iconColor: AppColors.red,
          backgroundColor: AppColors.lightPink,
          title: 'Complaints',
          subtitle: 'Help improve our community.',
          onTap: onComplaintsTap,
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String iconPath;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ServiceCard({
    required this.iconPath,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(D.radiusLG),
          border: Border.all(color: AppColors.grey.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: D.iconMD,
                  height: D.iconMD,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
            ),
            16.gapW,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: D.textBase,
                      fontWeight: D.semiBold,
                      color: AppColors.black,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                  4.gapH,
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: D.textSM,
                      color: AppColors.grey,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
