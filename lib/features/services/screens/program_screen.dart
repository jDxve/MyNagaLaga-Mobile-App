import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynagalaga_mobile_app/common/resources/colors.dart';
import 'package:mynagalaga_mobile_app/common/resources/dimensions.dart';
import 'package:mynagalaga_mobile_app/common/widgets/custom_app_bar.dart';
import 'package:mynagalaga_mobile_app/core/network/data_state.dart';
import 'package:mynagalaga_mobile_app/features/services/components/posting_list_item.dart';
import 'package:mynagalaga_mobile_app/features/services/components/programs_page/posting_detailed_page.dart';
import 'package:mynagalaga_mobile_app/features/services/notifier/welfare_program_notifier.dart';

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

  @override
  Widget build(BuildContext context) {
    final postingsState = ref.watch(welfarePostingsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: widget.args.title,
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

                final grouped = groupPostingsByService(postings);
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
                        ...sectionPostings.asMap().entries.map((entry) {
                          final i = entry.key;
                          final posting = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    i < sectionPostings.length - 1 ? 10.h : 0),
                            child: PostingListItem(
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
