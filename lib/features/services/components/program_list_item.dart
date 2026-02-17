import 'package:flutter/material.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';

class ProgramListItem extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;

  const ProgramListItem({
    super.key,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(D.radiusLG),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(D.radiusLG),
          border: Border.all(
            color: AppColors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: D.textBase,
                      fontWeight: D.semiBold,
                      color: AppColors.black,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    4.gapH,
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: D.textSM,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            12.gapW,
            Icon(Icons.chevron_right, color: AppColors.grey, size: 24.w),
          ],
        ),
      ),
    );
  }
}