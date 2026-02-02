import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/secondary_button.dart';

class AccessibilitySettingsDialog extends StatefulWidget {
  const AccessibilitySettingsDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AccessibilitySettingsDialog(),
    );
  }

  @override
  State<AccessibilitySettingsDialog> createState() =>
      _AccessibilitySettingsDialogState();
}

class _AccessibilitySettingsDialogState
    extends State<AccessibilitySettingsDialog> {
  String _selectedLanguage = 'English';
  double _textSize = 0.5;
  bool _voiceNarration = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.accessibility_new,
                        size: D.iconLG,
                        color: AppColors.primary,
                      ),
                      12.gapW,
                      Text(
                        'Accessibility Settings',
                        style: TextStyle(
                          fontSize: D.textXL,
                          fontWeight: D.bold,
                          color: AppColors.textlogo,
                        ),
                      ),
                    ],
                  ),
                  32.gapH,

                  // Language Section
                  Text(
                    'Language',
                    style: TextStyle(
                      fontSize: D.textMD,
                      fontWeight: D.semiBold,
                      color: AppColors.textlogo,
                    ),
                  ),
                  12.gapH,
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: 'English',
                          onPressed: () {
                            setState(() => _selectedLanguage = 'English');
                          },
                          isFilled: _selectedLanguage == 'English',
                        ),
                      ),
                      12.gapW,
                      Expanded(
                        child: SecondaryButton(
                          text: 'Tagalog',
                          onPressed: () {
                            setState(() => _selectedLanguage = 'Tagalog');
                          },
                          isFilled: _selectedLanguage == 'Tagalog',
                        ),
                      ),
                    ],
                  ),
                  12.gapH,
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: 'Bikol',
                          onPressed: () {
                            setState(() => _selectedLanguage = 'Bikol');
                          },
                          isFilled: _selectedLanguage == 'Bikol',
                        ),
                      ),
                      12.gapW,
                      Expanded(
                        child: SecondaryButton(
                          text: 'Naga',
                          onPressed: () {
                            setState(() => _selectedLanguage = 'Naga');
                          },
                          isFilled: _selectedLanguage == 'Naga',
                        ),
                      ),
                    ],
                  ),
                  32.gapH,

                  // Text Size Section
                  Text(
                    'Text Size',
                    style: TextStyle(
                      fontSize: D.textMD,
                      fontWeight: D.semiBold,
                      color: AppColors.textlogo,
                    ),
                  ),
                  12.gapH,
                  Row(
                    children: [
                      Text(
                        'A',
                        style: TextStyle(
                          fontSize: D.textSM,
                          fontWeight: D.medium,
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor:
                                AppColors.lightGrey.withOpacity(0.3),
                            thumbColor: AppColors.primary,
                            overlayColor: AppColors.primary.withOpacity(0.2),
                            trackHeight: 8.h,
                          ),
                          child: Slider(
                            value: _textSize,
                            onChanged: (value) {
                              setState(() => _textSize = value);
                            },
                          ),
                        ),
                      ),
                      Text(
                        'A',
                        style: TextStyle(
                          fontSize: D.textXL,
                          fontWeight: D.medium,
                        ),
                      ),
                    ],
                  ),
                  32.gapH,

                  // Assistance Section
                  Text(
                    'Assistance',
                    style: TextStyle(
                      fontSize: D.textMD,
                      fontWeight: D.semiBold,
                      color: AppColors.textlogo,
                    ),
                  ),
                  12.gapH,
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(D.radiusLG),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(D.radiusLG),
                          ),
                          child: Icon(
                            Icons.volume_up,
                            color: AppColors.primary,
                            size: D.iconLG,
                          ),
                        ),
                        16.gapW,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Voice Narration/',
                                style: TextStyle(
                                  fontSize: D.textBase,
                                  fontWeight: D.medium,
                                  color: AppColors.textlogo,
                                ),
                              ),
                              Text(
                                'Read Aloud',
                                style: TextStyle(
                                  fontSize: D.textBase,
                                  fontWeight: D.medium,
                                  color: AppColors.textlogo,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _voiceNarration,
                          onChanged: (value) {
                            setState(() => _voiceNarration = value);
                          },
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  24.gapH,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}