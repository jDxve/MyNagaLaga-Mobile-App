import 'package:flutter/material.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../accessibility_setting.dart';
import '../program_list_item.dart';


class ProgramListPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function(String) onProgramTap;
  final List<Map<String, String>> programs;

  const ProgramListPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onProgramTap,
    required this.programs,
  });

void _showAccessibilitySettings(BuildContext context) {
  AccessibilitySettingsDialog.show(context);
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: title,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
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
                  itemCount: programs.length,
                  separatorBuilder: (context, index) => 12.gapH,
                  itemBuilder: (context, index) {
                    final program = programs[index];
                    return ProgramListItem(
                      title: program['title']!,
                      description: program['description']!,
                      onTap: () => onProgramTap(program['title']!),
                    );
                  },
                ),
                80.gapH, // Extra space for FAB
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAccessibilitySettings(context),
        backgroundColor: AppColors.primary,
        child: Icon(
          Icons.accessibility_new,
          color: AppColors.white,
          size: D.iconMD,
        ),
      ),
    );
  }
}