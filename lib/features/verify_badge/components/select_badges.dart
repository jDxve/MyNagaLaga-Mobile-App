import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/assets.dart';
import '../../../common/resources/strings.dart';
import '../../../common/widgets/secondary_button.dart';
import '../../../common/widgets/error_modal.dart';

Widget badgeSelectionCards({
  required BuildContext context,
  required Function(String) onBadgeSelected,
  String? selectedBadge,
  required VoidCallback onNext,
}) {
  final List<Map<String, dynamic>> badges = [
    {
      'id': 'senior_citizen',
      'title': AppString.seniorCitizenTitle,
      'description': AppString.seniorCitizenDescription,
      'icon': Assets.seniorCitizenIcon,
      'lightColor': AppColors.lightYellow,
      'darkColor': AppColors.darkYellow,
    },
    {
      'id': 'pwd',
      'title': AppString.pwdTitle,
      'description': AppString.pwdDescription,
      'icon': Assets.pwdIcon,
      'lightColor': AppColors.lightPink,
      'darkColor': AppColors.darkPink,
    },
    {
      'id': 'solo_parent',
      'title': AppString.soloParentTitle,
      'description': AppString.soloParentDescription,
      'icon': Assets.soloParentIcon,
      'lightColor': AppColors.lightPurple,
      'darkColor': AppColors.darkPurple,
    },
    {
      'id': 'indigent',
      'title': AppString.indigentTitle,
      'description': AppString.indigentDescription,
      'icon': Assets.indigentFamilyIcon,
      'lightColor': AppColors.lightPrimary,
      'darkColor': AppColors.darkPrimary,
    },
    {
      'id': 'student',
      'title': AppString.studentTitle,
      'description': AppString.studentDescription,
      'icon': Assets.studentIcon,
      'lightColor': AppColors.lightBlue,
      'darkColor': AppColors.darkBlue,
    },
  ];

  return Column(
    children: [
      ...badges.map(
        (badge) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _BadgeCard(
            id: badge['id'],
            title: badge['title'],
            description: badge['description'],
            icon: badge['icon'],
            lightColor: badge['lightColor'],
            darkColor: badge['darkColor'],
            isSelected: selectedBadge == badge['id'],
            onTap: () => onBadgeSelected(badge['id']),
          ),
        ),
      ),
      16.gapH,
      _InfoCard(),
      16.gapH,
      SecondaryButton(
        text: AppString.next,
        isFilled: true,
        isDisabled: selectedBadge == null,
        onPressed: selectedBadge != null
            ? onNext
            : () {
                showErrorModal(
                  context: context,
                  title: AppString.noBadgeSelectedTitle,
                  description: AppString.noBadgeSelectedDescription,
                  icon: Icons.warning_amber_outlined,
                  iconColor: Colors.orange,
                  buttonText: AppString.gotIt,
                );
              },
      ),
    ],
  );
}

class _BadgeCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String icon;
  final Color lightColor;
  final Color darkColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _BadgeCard({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.lightColor,
    required this.darkColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isSelected ? lightColor : Colors.white,
              borderRadius: BorderRadius.circular(D.radiusLG),
              border: Border.all(
                color: isSelected ? darkColor : Colors.grey.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.circular(D.radiusMD),
                  ),
                  padding: EdgeInsets.all(8.w),
                  child: SvgPicture.asset(
                    icon,
                    colorFilter: ColorFilter.mode(
                      isSelected ? darkColor : Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                12.gapW,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: D.textBase,
                          fontWeight: D.semiBold,
                          color: Colors.black,
                        ),
                      ),
                      4.gapH,
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: D.textSM,
                          color: AppColors.grey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 12.h,
              right: 12.w,
              child: Icon(Icons.check_circle, color: darkColor, size: 20.w),
            ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.lightPrimary,
        borderRadius: BorderRadius.circular(D.radiusLG),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppString.whyApplyTitle,
            style: TextStyle(
              fontSize: D.textBase,
              fontWeight: D.semiBold,
              color: AppColors.primary,
            ),
          ),
          12.gapH,
          _InfoItem(text: AppString.whyApply1),
          _InfoItem(text: AppString.whyApply2),
          _InfoItem(text: AppString.whyApply3),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String text;

  const _InfoItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: D.textSM,
                color: AppColors.grey,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
