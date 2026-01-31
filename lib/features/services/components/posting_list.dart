import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/models/dio/data_state.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/utils/constant.dart';

import '../notifier/welfare_program_notifier.dart';
import '../models/welfare_program_model.dart';

class PostingHorizontalList extends ConsumerWidget {
  final void Function(WelfarePostingModel posting)? onTap;

  const PostingHorizontalList({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(welfarePostingsNotifierProvider);

    return state.when(
      started: () => const SizedBox(),

      loading: () => SizedBox(
        height: 200.h,
        child: const Center(child: CircularProgressIndicator()),
      ),

      error: (err) => Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Text(
          "❌ $err",
          style: TextStyle(color: Colors.red, fontSize: 14.f),
        ),
      ),

      success: (postings) {
        if (postings.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Text(
              "No available postings yet.",
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 14.f,
              ),
            ),
          );
        }

        return SizedBox(
          height: 200.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(right: 6.w),
            itemCount: postings.length,
            separatorBuilder: (_, __) => 16.gapW,
            itemBuilder: (context, index) {
              final post = postings[index];

              return _PostingCard(
                posting: post,
                onTap: () => onTap?.call(post),
              );
            },
          ),
        );
      },
    );
  }
}

class _PostingCard extends StatelessWidget {
  final WelfarePostingModel posting;
  final VoidCallback? onTap;

  const _PostingCard({
    required this.posting,
    this.onTap,
  });

  Color _getProgramColor(String? programName) {
    if (programName == null) return AppColors.lightGrey;

    final lowerName = programName.toLowerCase();

    if (lowerName.contains('children') || lowerName.contains('youth')) {
      return AppColors.blue;
    } else if (lowerName.contains('women')) {
      return AppColors.purple;
    } else if (lowerName.contains('family') || lowerName.contains('community')) {
      return AppColors.teal;
    } else if (lowerName.contains('crisis') || lowerName.contains('intervention')) {
      return AppColors.orange;
    } else if (lowerName.contains('disaster') || lowerName.contains('response')) {
      return AppColors.red;
    }

    return AppColors.lightGrey;
  }

  @override
  Widget build(BuildContext context) {
    final programColor = _getProgramColor(posting.programName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 320.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              programColor.withOpacity(0.12),
              programColor.withOpacity(0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(D.radiusLG),
          border: Border.all(
            color: programColor.withOpacity(0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: programColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                posting.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.f,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: AppColors.black,
                ),
              ),

              10.gapH,

              // Program Name Badge with WHITE background
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(D.radiusSM),
                  border: Border.all(
                    color: programColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  posting.programName ?? "Welfare Program",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.f,
                    fontWeight: FontWeight.w600,
                    color: programColor,
                  ),
                ),
              ),

              const Spacer(),

              // Date Range
              if (posting.endAt != null)
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14.w,
                      color: programColor,
                    ),
                    6.gapW,
                    Expanded(
                      child: Text(
                        Constant.formatDateRange(posting.startAt, posting.endAt!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.f,
                          color: AppColors.grey.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}