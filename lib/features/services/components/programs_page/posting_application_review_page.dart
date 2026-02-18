import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/models/dio/data_state.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../common/widgets/error_modal.dart';
import '../../../auth/notifier/auth_session_notifier.dart';
import '../../models/welfare_program_model.dart';
import '../../notifier/request_welfare_notifier.dart';
import 'posting_application_success_page.dart';
import 'posting_application_widgets.dart';

class PostingApplicationReviewPage extends ConsumerStatefulWidget {
  final WelfarePostingModel posting;
  final String reason;
  final Map<String, String> textFields;
  final Map<String, File?> fileUploads;
  final List<String> attachedBadgeTypeIds;

  const PostingApplicationReviewPage({
    super.key,
    required this.posting,
    required this.reason,
    required this.textFields,
    required this.fileUploads,
    required this.attachedBadgeTypeIds,
  });

  @override
  ConsumerState<PostingApplicationReviewPage> createState() =>
      _PostingApplicationReviewPageState();
}

class _PostingApplicationReviewPageState
    extends ConsumerState<PostingApplicationReviewPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(welfareServiceNotifierProvider.notifier)
          .reset(widget.posting.id);
    });
  }

  Future<void> _submit() async {
    final userId = ref.read(authSessionProvider).userId;
    if (userId == null) {
      showErrorModal(
        context: context,
        title: 'Not Authenticated',
        description: 'Your session has expired. Please log in again.',
      );
      return;
    }

    await ref.read(welfareServiceNotifierProvider.notifier).submitApplication(
          postingId: widget.posting.id,
          mobileUserId: userId,
          description: widget.reason,
          textFields: widget.textFields,
          files: widget.fileUploads,
          posting: widget.posting,
          attachedBadgeTypeIds: widget.attachedBadgeTypeIds,
        );
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);

    // Handle navigation and errors via ref.listen
    ref.listen<DataState<dynamic>>(welfareServiceNotifierProvider, (_, next) {
      next.whenOrNull(
        success: (data) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PostingApplicationSuccessPage(
                posting: widget.posting,
                result: data,
              ),
            ),
          );
        },
        error: (msg) {
          if (!mounted) return;
          showErrorModal(
            context: context,
            title: 'Submission Failed',
            description: msg ?? 'Something went wrong. Please try again.',
          );
        },
      );
    });

    final appState = ref.watch(welfareServiceNotifierProvider);

    final isSubmitting = appState.when(
      started: () => false,
      loading: () => true,
      error: (_) => false,
      success: (_) => false,
    );

    final preFilledData = appState.whenOrNull(success: (data) => data);
    final hasPreFilledText =
        (preFilledData?.autoFilledTextByCategory ?? []).isNotEmpty;
    final hasAutoAttached =
        (preFilledData?.autoAttachedByCategory ?? []).isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'Review Application'),
      bottomNavigationBar: PostingBottomBar(
        label: 'Submit Application',
        isLoading: isSubmitting,
        onSubmit: isSubmitting ? () {} : _submit,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        children: [
          PostingHeaderCard(posting: widget.posting),
          24.gapH,

          // Auto-filled summary (shown after submit returns, before navigation)
          if (hasPreFilledText) ...[
            PostingSectionHeader(title: 'Auto-filled from Your Badges'),
            8.gapH,
            PostingSubtitleText(
              text:
                  'The following information was pre-filled from your verified badges.',
            ),
            12.gapH,
            ...preFilledData!.autoFilledTextByCategory.map(
              (c) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: PostingAutoFilledCategoryCard(category: c),
              ),
            ),
            24.gapH,
          ],
          if (hasAutoAttached) ...[
            PostingSectionHeader(title: 'Auto-attached Documents'),
            8.gapH,
            PostingSubtitleText(
              text:
                  'The following documents were automatically attached from your badge records.',
            ),
            12.gapH,
            ...preFilledData!.autoAttachedByCategory.map(
              (c) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: PostingAutoAttachedCategoryCard(category: c),
              ),
            ),
            24.gapH,
          ],

          PostingReviewSectionCard(
            icon: Icons.edit_note_rounded,
            title: 'Reason for Request',
            child: Text(
              widget.reason,
              style: TextStyle(
                fontSize: D.textBase,
                fontFamily: 'Segoe UI',
                color: AppColors.black,
                height: 1.6,
              ),
            ),
          ),
          16.gapH,

          ...widget.posting.requirements.map((group) {
            final groupTextItems = group.items
                .where((item) =>
                    item.type == 'text' &&
                    (widget.textFields[item.key] ?? '').isNotEmpty)
                .toList();
            final groupFileItems = group.items
                .where((item) =>
                    item.type != 'text' &&
                    widget.fileUploads[item.key] != null)
                .toList();

            if (groupTextItems.isEmpty && groupFileItems.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: PostingReviewGroupCard(
                category: group.category,
                textItems: groupTextItems,
                fileItems: groupFileItems,
                textFields: widget.textFields,
                fileUploads: widget.fileUploads,
              ),
            );
          }),

          100.gapH,
        ],
      ),
    );
  }
}