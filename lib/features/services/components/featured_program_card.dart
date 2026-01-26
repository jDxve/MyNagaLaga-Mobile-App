import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';

class FeaturedProgramCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;

  const FeaturedProgramCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBackgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(D.radiusLG),
      child: Container(
        padding: EdgeInsets.all(12.w), 
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(D.radiusLG),
          border: Border.all(color: AppColors.grey.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, 
          children: [
            Container(
              width: 40.w, 
              height: 40.h, 
              decoration: BoxDecoration(
                color: iconBackgroundColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(D.radiusMD),
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: 20.w, 
                  height: 20.h,
                  colorFilter: ColorFilter.mode(
                    iconBackgroundColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            10.gapH,
            Text(
              title,
              style: TextStyle(
                fontSize: 13.5.h,
                fontWeight: D.semiBold,
                color: AppColors.black,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            5.gapH,
            Text(
              subtitle,
              style: TextStyle(
                fontSize: D.textXS,
                fontWeight: D.regular,
                color: AppColors.grey,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
