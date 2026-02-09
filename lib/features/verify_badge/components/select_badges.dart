import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/assets.dart';
import '../../../common/resources/strings.dart';
import '../../../common/widgets/secondary_button.dart';
import '../../../common/widgets/error_modal.dart';
import '../models/badge_type_model.dart';

Widget badgeSelectionCards({
  required BuildContext context,
  required List<BadgeType> badgeTypes,
  required Function(BadgeType) onBadgeSelected,
  BadgeType? selectedBadge,
  required VoidCallback onNext,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ...badgeTypes.map((apiBadge) {
        final isSelected = selectedBadge?.id == apiBadge.id;
        final localMetadata = _getBadgeLocalMetadata(apiBadge.badgeKey);

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _BadgeCard(
            title: apiBadge.name,
            description: localMetadata['description'],
            styleInfo: localMetadata,
            isSelected: isSelected,
            onTap: () => onBadgeSelected(apiBadge),
          ),
        );
      }),
      16.gapH,
      const _InfoCard(),
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

Map<String, dynamic> _getBadgeLocalMetadata(String badgeKey) {
  switch (badgeKey) {
    case 'senior_citizen':
      return {
        'description': AppString.seniorCitizenDescription,
        'icon': Assets.seniorCitizenIcon,
        'useIconData': false,
        'lightColor': AppColors.lightYellow,
        'darkColor': AppColors.darkYellow,
      };
    case 'pwd':
      return {
        'description': AppString.pwdDescription,
        'icon': Assets.pwdIcon,
        'useIconData': false,
        'lightColor': AppColors.lightPink,
        'darkColor': AppColors.darkPink,
      };
    case 'solo_parent':
      return {
        'description': AppString.soloParentDescription,
        'icon': Assets.soloParentIcon,
        'useIconData': false,
        'lightColor': AppColors.lightPurple,
        'darkColor': AppColors.darkPurple,
      };
    case 'indigent':
      return {
        'description': AppString.indigentDescription,
        'icon': Assets.indigentFamilyIcon,
        'useIconData': false,
        'lightColor': AppColors.lightPrimary,
        'darkColor': AppColors.darkPrimary,
      };
    case 'student':
      return {
        'description': AppString.studentDescription,
        'icon': Assets.studentIcon,
        'useIconData': false,
        'lightColor': AppColors.lightBlue,
        'darkColor': AppColors.darkBlue,
      };
    case 'citizen':
      return {
        'description': 'For all registered citizens and residents of Naga City',
        'useIconData': true,
        'iconData': Icons.person_outline,
        'lightColor': AppColors.lightCitizen,
        'darkColor': AppColors.darkCitizen,
      };
    default:
      return {
        'description': 'Verification badge for eligible residents',
        'icon': Assets.studentIcon,
        'useIconData': false,
        'lightColor': AppColors.lightGrey,
        'darkColor': AppColors.grey,
      };
  }
}

class _BadgeCard extends StatelessWidget {
  final String title;
  final String description;
  final Map<String, dynamic> styleInfo;
  final bool isSelected;
  final VoidCallback onTap;

  const _BadgeCard({
    required this.title,
    required this.description,
    required this.styleInfo,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color lightColor = styleInfo['lightColor'];
    final Color darkColor = styleInfo['darkColor'];

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
                  child: styleInfo['useIconData']
                      ? Icon(
                          styleInfo['iconData'],
                          color: isSelected ? darkColor : Colors.black,
                          size: 24.w,
                        )
                      : SvgPicture.asset(
                          styleInfo['icon'],
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
  const _InfoCard();
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
          const _InfoItem(text: AppString.whyApply1),
          const _InfoItem(text: AppString.whyApply2),
          const _InfoItem(text: AppString.whyApply3),
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
      child: Text(
        text,
        style: TextStyle(
          fontSize: D.textSM,
          color: AppColors.grey,
          height: 1.4,
        ),
      ),
    );
  }
}
