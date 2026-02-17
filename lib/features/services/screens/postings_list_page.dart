import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../common/models/dio/data_state.dart';
import '../components/programs_page/posting_detailed_page.dart';
import '../models/welfare_program_model.dart';
import '../notifier/welfare_program_notifier.dart';

class PostingsListPage extends ConsumerStatefulWidget {
  final String serviceId;
  final String serviceName;

  const PostingsListPage({
    super.key,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  ConsumerState<PostingsListPage> createState() => _PostingsListPageState();
}

class _PostingsListPageState extends ConsumerState<PostingsListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(welfarePostingsNotifierProvider.notifier)
          .fetchPostingsByServiceId(widget.serviceId);
    });
  }

  void _openDetail(WelfarePostingModel posting) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostingDetailPage(posting: posting),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postingsState = ref.watch(welfarePostingsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.black,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.serviceName,
          style: TextStyle(
            fontSize: D.textLG,
            fontWeight: D.bold,
            color: AppColors.black,
          ),
        ),
      ),
      body: postingsState.when(
        started: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (message) => Center(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Text(
              message ?? 'Failed to load postings.',
              style: TextStyle(color: AppColors.red, fontSize: D.textSM),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        success: (postings) {
          if (postings.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 48.w, color: AppColors.grey),
                  12.gapH,
                  Text(
                    'No postings available yet.',
                    style:
                        TextStyle(color: AppColors.grey, fontSize: D.textSM),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(20.w),
            itemCount: postings.length,
            separatorBuilder: (_, __) => 12.gapH,
            itemBuilder: (context, index) {
              final posting = postings[index];
              return _PostingItem(
                posting: posting,
                onTap: () => _openDetail(posting),
              );
            },
          );
        },
      ),
    );
  }
}

class _PostingItem extends StatelessWidget {
  final WelfarePostingModel posting;
  final VoidCallback? onTap;

  const _PostingItem({required this.posting, this.onTap});

  bool get _isUrgent {
    if (posting.endAt == null) return false;
    return posting.endAt!.difference(DateTime.now()).inDays <= 7;
  }

  String get _slotsText {
    if (posting.slotsRemaining == null) return 'Open slots';
    if (posting.slotsRemaining! <= 0) return 'Full';
    return '${posting.slotsRemaining} slots left';
  }

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
            color: _isUrgent
                ? AppColors.red.withOpacity(0.3)
                : AppColors.grey.withOpacity(0.2),
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
                      Icon(Icons.people_outline_rounded,
                          size: 13.w, color: AppColors.grey),
                      4.gapW,
                      Text(
                        _slotsText,
                        style: TextStyle(
                            fontSize: D.textXS, color: AppColors.grey),
                      ),
                      if (_isUrgent) ...[
                        12.gapW,
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
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
            Icon(Icons.chevron_right, color: AppColors.grey, size: 24.w),
          ],
        ),
      ),
    );
  }
}