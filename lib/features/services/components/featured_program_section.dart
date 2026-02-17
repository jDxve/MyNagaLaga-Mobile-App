import 'package:flutter/material.dart';
import '../../../common/resources/assets.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';
import '../screens/program_screen.dart';
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
        onTap: () => Navigator.pushNamed(
          context,
          ProgramScreen.routeName,
          arguments: const ProgramScreenArgs(
            programName: 'Children and Youth Welfare Program',
            title: 'Children & Youth Welfare',
            subtitle: 'Programs for children and young adults.',
          ),
        ),
      ),
      FeaturedProgramData(
        icon: Assets.womenWelfareIcon,
        title: AppString.womenWelfareTitle,
        subtitle: AppString.womenWelfareSubtitle,
        iconBackgroundColor: AppColors.purple,
        onTap: () => Navigator.pushNamed(
          context,
          ProgramScreen.routeName,
          arguments: const ProgramScreenArgs(
            programName: 'Women Welfare Program',
            title: 'Women Welfare',
            subtitle:
                'Support for mothers, solo parents, and women in difficult circumstances.',
          ),
        ),
      ),
      FeaturedProgramData(
        icon: Assets.familyCommunityIcon,
        title: AppString.familyCommunityTitle,
        subtitle: AppString.familyCommunitySubtitle,
        iconBackgroundColor: AppColors.teal,
        onTap: () => Navigator.pushNamed(
          context,
          ProgramScreen.routeName,
          arguments: const ProgramScreenArgs(
            programName: 'Family and Community Welfare Program',
            title: 'Family & Community Welfare',
            subtitle:
                'Strengthening family bonds and supporting vulnerable adults.',
          ),
        ),
      ),
      FeaturedProgramData(
        icon: Assets.crisisInterventionIcon,
        title: AppString.crisisInterventionTitle,
        subtitle: AppString.crisisInterventionSubtitle,
        iconBackgroundColor: AppColors.orange,
        onTap: () => Navigator.pushNamed(
          context,
          ProgramScreen.routeName,
          arguments: const ProgramScreenArgs(
            programName: 'Crisis Intervention Program',
            title: 'Crisis Intervention Program (AICS)',
            subtitle:
                'Immediate financial or material help for individuals in crisis.',
          ),
        ),
      ),
      FeaturedProgramData(
        icon: Assets.disasterResponseIcon,
        title: AppString.disasterResponseTitle,
        subtitle: AppString.disasterResponseSubtitle,
        iconBackgroundColor: AppColors.red,
        onTap: () => Navigator.pushNamed(
          context,
          ProgramScreen.routeName,
          arguments: const ProgramScreenArgs(
            programName: 'Disaster Response Program',
            title: 'Disaster Response',
            subtitle:
                'Management of safety and relief during typhoons or emergencies.',
          ),
        ),
      ),
      FeaturedProgramData(
        icon: Assets.otherServicesIcon,
        title: AppString.otherServicesTitle,
        subtitle: AppString.otherServicesSubtitle,
        iconBackgroundColor: AppColors.lightGrey,
        onTap: () => Navigator.pushNamed(
          context,
          ProgramScreen.routeName,
          arguments: const ProgramScreenArgs(
            programName: 'Other Services',
            title: 'Other Services',
            subtitle: 'Additional welfare services and assistance.',
          ),
        ),
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
            fontWeight: D.bold,
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