import 'package:flutter/material.dart';
import 'package:mynagalaga_mobile_app/common/resources/colors.dart';
import 'package:mynagalaga_mobile_app/common/resources/dimensions.dart';
import 'package:mynagalaga_mobile_app/common/utils/ui_utils.dart';
import 'package:mynagalaga_mobile_app/features/services/models/welfare_program_model.dart';

/// A single posting row within a program's grouped listing — urgency,
/// days-left, and slots-remaining copy come from UIUtils so this stays in
/// sync with every other place that renders the same posting data.
class PostingListItem extends StatelessWidget {
  final WelfarePostingModel posting;
  final VoidCallback? onTap;

  const PostingListItem({super.key, required this.posting, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUrgent = UIUtils.isUrgent(posting.endAt);
    final daysLeft = UIUtils.daysLeft(posting.endAt);
    final slotsText = UIUtils.slotsText(posting.slotsRemaining);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(D.radiusLG),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(D.radiusLG),
          border: Border.all(
            color: isUrgent
                ? AppColors.red.withValues(alpha: 0.25)
                : AppColors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    posting.title,
                    style: TextStyle(
                      fontSize: D.textBase,
                      fontWeight: D.semiBold,
                      color: AppColors.black,
                    ),
                  ),
                  if (posting.description != null) ...[
                    4.gapH,
                    Text(
                      posting.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: D.textSM,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                  8.gapH,
                  Row(
                    children: [
                      if (daysLeft.isNotEmpty) ...[
                        Icon(
                          Icons.access_time_rounded,
                          size: 12.w,
                          color: isUrgent ? AppColors.red : AppColors.grey,
                        ),
                        4.gapW,
                        Text(
                          daysLeft,
                          style: TextStyle(
                            fontSize: D.textXS,
                            color: isUrgent ? AppColors.red : AppColors.grey,
                            fontWeight: isUrgent ? D.semiBold : D.regular,
                          ),
                        ),
                      ],
                      if (slotsText.isNotEmpty && daysLeft.isNotEmpty)
                        Container(
                          width: 3,
                          height: 3,
                          margin: EdgeInsets.symmetric(horizontal: 6.w),
                          decoration: const BoxDecoration(
                            color: AppColors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (slotsText.isNotEmpty) ...[
                        Icon(
                          Icons.people_outline_rounded,
                          size: 12.w,
                          color: AppColors.grey,
                        ),
                        4.gapW,
                        Text(
                          slotsText,
                          style: TextStyle(
                            fontSize: D.textXS,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                      if (isUrgent) ...[
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.lightPink,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Urgent',
                            style: TextStyle(
                              fontSize: D.textXS,
                              fontWeight: D.semiBold,
                              color: AppColors.red,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            12.gapW,
            Icon(Icons.chevron_right, color: AppColors.grey, size: 22.w),
          ],
        ),
      ),
    );
  }
}
