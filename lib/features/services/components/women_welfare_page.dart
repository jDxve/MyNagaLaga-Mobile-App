import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../components/program_list_item.dart';

class WomenWelfarePage extends StatelessWidget {
  final Function(String) onProgramTap;

  const WomenWelfarePage({
    super.key,
    required this.onProgramTap,
  });

  static final List<Map<String, String>> _programs = [
    {
      'title': 'Solo Parent Services',
      'description': 'Issuance of Solo Parent ID, booklets, and monthly financial aid for indigents.',
    },
    {
      'title': 'Sustainable Livelihood (SLP)',
      'description': 'Skills training (e.g., weaving, food processing) and capital assistance for mothers.',
    },
    {
      'title': 'Violence Against Women Help Desk',
      'description': 'Legal assistance, counseling, and rescue for victims of domestic violence.',
    },
    {
      'title': 'Pre-natal & Maternal Care',
      'description': 'Medical assistance and check-ups for pregnant and nursing mothers.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Women Welfare',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support for mothers, solo parents, and women in difficult circumstances.',
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