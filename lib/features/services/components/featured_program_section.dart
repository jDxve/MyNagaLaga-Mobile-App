import 'package:flutter/material.dart';
import 'package:mynagalaga_mobile_app/features/services/screens/women_welfare_screen.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/assets.dart';
import '../../../common/resources/strings.dart';
import '../../services/screens/children_youth_screen.dart';
import 'featured_program_card.dart';

class FeaturedProgramSection extends StatelessWidget {
  final List<FeaturedProgramData>? programs;

  const FeaturedProgramSection({super.key, this.programs});

  List<FeaturedProgramData> _getDefaultPrograms(BuildContext context) {
    return [
      FeaturedProgramData(
        icon: Assets.childrenYouthIcon,
        title: AppString.childrenYouthTitle,
        subtitle: AppString.childrenYouthSubtitle,
        iconBackgroundColor: AppColors.blue,
        onTap: () {
          Navigator.pushNamed(context, ChildrenYouthScreen.routeName);
        },
      ),
      FeaturedProgramData(
        icon: Assets.womenWelfareIcon,
        title: AppString.womenWelfareTitle,
        subtitle: AppString.womenWelfareSubtitle,
        iconBackgroundColor: AppColors.purple,
          onTap: () {
          Navigator.pushNamed(context, WomenWelfareScreen.routeName);
        },
      ),
      FeaturedProgramData(
        icon: Assets.familyCommunityIcon,
        title: AppString.familyCommunityTitle,
        subtitle: AppString.familyCommunitySubtitle,
        iconBackgroundColor: AppColors.teal,
        onTap: () => print('Family & Community tapped'),
      ),
      FeaturedProgramData(
        icon: Assets.crisisInterventionIcon,
        title: AppString.crisisInterventionTitle,
        subtitle: AppString.crisisInterventionSubtitle,
        iconBackgroundColor: AppColors.orange,
        onTap: () => print('Crisis Intervention tapped'),
      ),
      FeaturedProgramData(
        icon: Assets.disasterResponseIcon,
        title: AppString.disasterResponseTitle,
        subtitle: AppString.disasterResponseSubtitle,
        iconBackgroundColor: AppColors.red,
        onTap: () => print('Disaster Response tapped'),
      ),
      FeaturedProgramData(
        icon: Assets.otherServicesIcon,
        title: AppString.otherServicesTitle,
        subtitle: AppString.otherServicesSubtitle,
        iconBackgroundColor: AppColors.lightGrey,
        onTap: () => print('Other Services tapped'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final programList = programs ?? _getDefaultPrograms(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.featuredProgramsTitle,
          style: TextStyle(
            fontFamily: 'Segoe UI',
            fontSize: D.textLG,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        8.gapH,
        Text(
          AppString.featuredProgramsDesc,
          style: TextStyle(
            fontFamily: 'Segoe UI',
            fontSize: D.textBase,
            fontWeight: D.regular,
            color: Colors.grey[600],
          ),
        ),
        16.gapH,
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.5,
          ),
          itemCount: programList.length,
          itemBuilder: (context, index) {
            final program = programList[index];
            return FeaturedProgramCard(
              icon: program.icon,
              title: program.title,
              subtitle: program.subtitle,
              iconBackgroundColor: program.iconBackgroundColor,
              onTap: program.onTap,
            );
          },
        ),
      ],
    );
  }
}

class FeaturedProgramData {
  final String icon;
  final String title;
  final String subtitle;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;

  FeaturedProgramData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBackgroundColor,
    this.onTap,
  });
}