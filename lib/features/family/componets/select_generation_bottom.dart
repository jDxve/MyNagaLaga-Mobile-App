import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';

class SelectGenerationBottomSheet extends StatelessWidget {
  final Function(int) onGenerationSelected;

  const SelectGenerationBottomSheet({
    super.key,
    required this.onGenerationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(D.radiusXL),
          topRight: Radius.circular(D.radiusXL),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 24.h,
        bottom: MediaQuery.of(context).padding.bottom + 20.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          16.gapH,
          Text(
            'Select Generation',
            style: TextStyle(
              fontSize: D.textLG,
              fontWeight: D.bold,
              color: AppColors.textlogo,
            ),
          ),
          6.gapH,
          Text(
            'Choose which generation to add',
            style: TextStyle(
              fontSize: D.textSM,
              color: AppColors.grey,
            ),
          ),
          24.gapH,
          _buildGenerationOption(
            context,
            'Generation 1 (Parents)',
            Icons.family_restroom,
            1,
          ),
          12.gapH,
          _buildGenerationOption(
            context,
            'Generation 2 (Children)',
            Icons.child_care,
            2,
          ),
          12.gapH,
          _buildGenerationOption(
            context,
            'Generation 3 (Grandchildren)',
            Icons.emoji_people,
            3,
          ),
          20.gapH,
        ],
      ),
    );
  }

  Widget _buildGenerationOption(
    BuildContext context,
    String title,
    IconData icon,
    int generation,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onGenerationSelected(generation);
      },
      borderRadius: BorderRadius.circular(D.radiusLG),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(D.radiusLG),
          border: Border.all(
            color: AppColors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(D.radiusMD),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: D.iconSM,
              ),
            ),
            12.gapW,
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: D.textBase,
                  fontWeight: D.medium,
                  color: AppColors.textlogo,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.w,
              color: AppColors.grey.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}