import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';

import '../../../common/models/dio/data_state.dart';
import '../components/programs_page/posting_detailed_page.dart';
import '../models/welfare_program_model.dart';
import '../notifier/welfare_program_notifier.dart';

class ProgramScreenArgs {
  final String programName;
  final String title;
  final String subtitle;

  const ProgramScreenArgs({
    required this.programName,
    required this.title,
    required this.subtitle,
  });
}

class ProgramScreen extends ConsumerStatefulWidget {
  static const routeName = '/program';

  final ProgramScreenArgs args;

  const ProgramScreen({super.key, required this.args});

  @override
  ConsumerState<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends ConsumerState<ProgramScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(welfareProgramsNotifierProvider.notifier)
          .fetchPrograms();
      await ref
          .read(welfarePostingsNotifierProvider.notifier)
          .fetchPostingsByProgramName(widget.args.programName);
    });
  }

  /// Groups postings by serviceName, preserving insertion order.
  Map<String, List<WelfarePostingModel>> _groupByService(
      List<WelfarePostingModel> postings) {
    final map = <String, List<WelfarePostingModel>>{};
    for (final p in postings) {
      final key = p.serviceName ?? 'Other';
      map.putIfAbsent(key, () => []).add(p);
    }
    return map;
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
          widget.args.title,
          style: TextStyle(
            fontSize: D.textLG,
            fontWeight: D.bold,
            color: AppColors.black,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: AppColors.white,
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
            child: Text(
              widget.args.subtitle,
              style: TextStyle(fontSize: D.textSM, color: AppColors.grey),
            ),
          ),
          Expanded(
            child: postingsState.when(
              started: () => const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (message) => Center(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Text(
                    message ?? 'Failed to load postings.',
                    style:
                        TextStyle(color: AppColors.red, fontSize: D.textSM),
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
                          'No active postings available.',
                          style: TextStyle(
                              color: AppColors.grey, fontSize: D.textSM),
                        ),
                      ],
                    ),
                  );
                }

                final grouped = _groupByService(postings);
                final serviceNames = grouped.keys.toList();

                return ListView.builder(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  itemCount: serviceNames.length,
                  itemBuilder: (context, sectionIndex) {
                    final serviceName = serviceNames[sectionIndex];
                    final sectionPostings = grouped[serviceName]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (sectionIndex > 0) 20.gapH,
                        // Service section header
                        Row(
                          children: [
                            Container(
                              width: 3,
                              height: 16.h,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            8.gapW,
                            Expanded(
                              child: Text(
                                serviceName,
                                style: TextStyle(
                                  fontSize: D.textSM,
                                  fontWeight: D.semiBold,
                                  color: AppColors.primary,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        10.gapH,
                        // Postings under this service
                        ...sectionPostings.asMap().entries.map((entry) {
                          final i = entry.key;
                          final posting = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    i < sectionPostings.length - 1 ? 10.h : 0),
                            child: _PostingItem(
                      posting: posting,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PostingDetailPage(posting: posting),
                        ),
                      ),
                    ),
                          );
                        }),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
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

  String get _daysLeft {
    if (posting.endAt == null) return '';
    final diff = posting.endAt!.difference(DateTime.now()).inDays;
    if (diff <= 0) return 'Ends today';
    if (diff == 1) return '1 day left';
    return '$diff days left';
  }

  String get _slotsText {
    if (posting.slotsRemaining == null) return '';
    if (posting.slotsRemaining! <= 0) return 'Full';
    return '${posting.slotsRemaining} slots left';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(D.radiusLG),
      child: Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(D.radiusLG),
        border: Border.all(
          color: _isUrgent
              ? AppColors.red.withOpacity(0.25)
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
                    if (_daysLeft.isNotEmpty) ...[
                      Icon(
                        Icons.access_time_rounded,
                        size: 12.w,
                        color: _isUrgent ? AppColors.red : AppColors.grey,
                      ),
                      4.gapW,
                      Text(
                        _daysLeft,
                        style: TextStyle(
                          fontSize: D.textXS,
                          color: _isUrgent ? AppColors.red : AppColors.grey,
                          fontWeight: _isUrgent ? D.semiBold : D.regular,
                        ),
                      ),
                    ],
                    if (_slotsText.isNotEmpty && _daysLeft.isNotEmpty)
                      Container(
                        width: 3,
                        height: 3,
                        margin: EdgeInsets.symmetric(horizontal: 6.w),
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (_slotsText.isNotEmpty) ...[
                      Icon(
                        Icons.people_outline_rounded,
                        size: 12.w,
                        color: AppColors.grey,
                      ),
                      4.gapW,
                      Text(
                        _slotsText,
                        style: TextStyle(
                          fontSize: D.textXS,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                    if (_isUrgent) ...[
                      const Spacer(),
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
          Icon(Icons.chevron_right, color: AppColors.grey, size: 22.w),
        ],
      ),
    ), // Container
    ); // InkWell
  }
}