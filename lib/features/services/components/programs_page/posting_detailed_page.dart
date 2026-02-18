import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/models/dio/data_state.dart';
import '../../../../common/resources/assets.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../common/widgets/secondary_button.dart';
import '../../../auth/notifier/auth_session_notifier.dart';
import '../../../home/notifier/user_badge_notifier.dart';
import '../../models/welfare_program_model.dart';
import '../../notifier/welfare_program_notifier.dart';
import 'posting_application_page.dart';

class PostingDetailPage extends ConsumerStatefulWidget {
  final WelfarePostingModel posting;
  const PostingDetailPage({super.key, required this.posting});

  @override
  ConsumerState<PostingDetailPage> createState() => _PostingDetailPageState();
}

class _PostingDetailPageState extends ConsumerState<PostingDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(postingDetailNotifierProvider.notifier)
          .fetchPosting(widget.posting.id);
      final userId = ref.read(authSessionProvider).userId;
      if (userId != null) {
        ref
            .read(badgesNotifierProvider.notifier)
            .fetchBadges(mobileUserId: userId);
      }
    });
  }

  String _getBadgeImage(String badgeName) {
    final n = badgeName.toLowerCase();
    if (n.contains('senior')) return Assets.seniorCitizenBadge;
    if (n.contains('pwd') || n.contains('disab')) return Assets.pwdBadge;
    if (n.contains('solo') || n.contains('parent')) return Assets.soloParentBadge;
    if (n.contains('student')) return Assets.studentBadge;
    if (n.contains('indigent') || n.contains('family')) return Assets.indigentFamilyBadge;
    return Assets.studentBadge;
  }

  void _navigateToApplication(WelfarePostingModel posting) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostingApplicationPage(posting: posting),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);

    final detailState = ref.watch(postingDetailNotifierProvider);
    final badgesState = ref.watch(badgesNotifierProvider);

    final posting = detailState.when(
      started: () => widget.posting,
      loading: () => widget.posting,
      error: (_) => widget.posting,
      success: (p) => p,
    );

    final isLoadingDetail = detailState.when(
      started: () => false,
      loading: () => true,
      error: (_) => false,
      success: (_) => false,
    );

    final userBadgeIds = badgesState.when(
      started: () => <String>[],
      loading: () => <String>[],
      error: (_) => <String>[],
      success: (data) => data.badges.map((e) => e.badgeTypeId).toList(),
    );

    final isEligible = posting.isEligible(userBadgeIds);
    final isFull = (posting.slotsRemaining ?? 1) <= 0;
    final canApply = isEligible && !isFull;

    String daysLeft(DateTime endAt) {
      final diff = endAt.difference(DateTime.now()).inDays;
      if (diff <= 0) return 'Ends today';
      if (diff == 1) return '1 day left';
      return '$diff days left';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: posting.serviceName ?? 'Program Details',
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 50.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.grey.withOpacity(.15)),
          ),
        ),
        child: SizedBox(
          height: D.primaryButton,
          child: SecondaryButton(
            text: isFull
                ? 'Slots Full'
                : !isEligible
                    ? 'Not Eligible'
                    : 'Apply Now',
            onPressed: canApply
                ? () => _navigateToApplication(posting) // 👈 Navigate here
                : () {},
            isDisabled: !canApply,
            isFilled: true,
          ),
        ),
      ),
      body: isLoadingDetail
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
              children: [
                Text(
                  posting.title,
                  style: TextStyle(
                    fontSize: D.textXL,
                    fontWeight: D.bold,
                    fontFamily: 'Segoe UI',
                    color: AppColors.black,
                    height: 1.2,
                  ),
                ),
                12.gapH,
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _chip(
                      isFull
                          ? 'Full'
                          : posting.slotsRemaining != null
                              ? '${posting.slotsRemaining} slots left'
                              : 'Open slots',
                      isFull ? AppColors.red : AppColors.grey,
                      Icons.people_outline_rounded,
                    ),
                    if (posting.endAt != null)
                      _chip(
                        daysLeft(posting.endAt!),
                        AppColors.grey,
                        Icons.access_time_rounded,
                      ),
                    if (posting.intakeMode != null)
                      _chip(
                        posting.intakeMode!,
                        AppColors.grey,
                        Icons.inbox_outlined,
                      ),
                    if (posting.barangayName != null)
                      _chip(
                        posting.barangayName!,
                        AppColors.grey,
                        Icons.location_on_outlined,
                      ),
                  ],
                ),
                20.gapH,
                const Divider(),
                5.gapH,
                if (posting.description != null) ...[
                  Text(
                    'About this posting',
                    style: TextStyle(
                      fontSize: D.textMD,
                      fontWeight: D.bold,
                      fontFamily: 'Segoe UI',
                      color: AppColors.black,
                    ),
                  ),
                  8.gapH,
                  Text(
                    posting.description!,
                    style: TextStyle(
                      fontSize: D.textBase,
                      fontFamily: 'Segoe UI',
                      fontWeight: D.semiBold,
                      color: AppColors.grey,
                      height: 1.6,
                    ),
                  ),
                  24.gapH,
                ],
                Text(
                  'Badge Requirement',
                  style: TextStyle(
                    fontSize: D.textMD,
                    fontWeight: D.bold,
                    fontFamily: 'Segoe UI',
                    color: AppColors.black,
                  ),
                ),
                16.gapH,
                if (posting.requiredBadges.isEmpty)
                  Text(
                    'No badge required.',
                    style: TextStyle(
                      fontSize: D.textMD,
                      fontFamily: 'Segoe UI',
                      color: AppColors.grey,
                    ),
                  )
                else
                  Column(
                    children: posting.requiredBadges.map((badge) {
                      final bool held = userBadgeIds.contains(badge.id);
                      return Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  held
                                      ? Icons.verified_rounded
                                      : Icons.lock_outline_rounded,
                                  size: D.iconSM,
                                  color: held
                                      ? AppColors.primary
                                      : AppColors.grey,
                                ),
                                6.gapW,
                                Text(
                                  held ? 'Eligible' : 'Not Eligible',
                                  style: TextStyle(
                                    fontSize: D.textMD,
                                    fontFamily: 'Segoe UI',
                                    fontWeight: D.bold,
                                    color: held
                                        ? AppColors.primary
                                        : AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                            8.gapH,
                            Image.asset(
                              _getBadgeImage(badge.name),
                              width: double.infinity,
                              fit: BoxFit.fitWidth,
                              color: held
                                  ? null
                                  : Colors.grey.withOpacity(0.5),
                              colorBlendMode:
                                  held ? null : BlendMode.saturation,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                100.gapH,
              ],
            ),
    );
  }

  Widget _chip(String text, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(D.radiusLG),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: D.iconXS, color: color),
          6.gapW,
          Text(
            text,
            style: TextStyle(
              fontSize: D.textXS,
              fontFamily: 'Segoe UI',
              color: color,
              fontWeight: D.medium,
            ),
          ),
        ],
      ),
    );
  }
}