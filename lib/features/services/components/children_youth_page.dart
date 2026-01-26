import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../components/program_list_item.dart';

class ChildrenYouthPage extends StatelessWidget {
  final Function(String) onProgramTap;

  const ChildrenYouthPage({
    super.key,
    required this.onProgramTap,
  });

  static final List<Map<String, String>> _programs = [
    {
      'title': AppString.sanggawadanTitle,
      'description': AppString.sanggawadanDesc,
    },
    {
      'title': AppString.educareTitle,
      'description': AppString.educareDesc,
    },
    {
      'title': AppString.feedingProgramTitle,
      'description': AppString.feedingProgramDesc,
    },
    {
      'title': AppString.pagAsaTitle,
      'description': AppString.pagAsaDesc,
    },
    {
      'title': AppString.yakapYouthTitle,
      'description': AppString.yakapYouthDesc,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: AppString.childrenYouthWelfare,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppString.childrenYouthSubTitle,
                  style: TextStyle(
                    fontSize: D.textBase,
                    fontWeight: D.regular,
                    color: AppColors.grey,
                    fontFamily: 'Segoe UI',
                  ),
                ),
                20.gapH,
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _programs.length,
                  separatorBuilder: (context, index) => 12.gapH,
                  itemBuilder: (context, index) {
                    final program = _programs[index];
                    return ProgramListItem(
                      title: program['title']!,
                      description: program['description']!,
                      onTap: () => onProgramTap(program['title']!),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}