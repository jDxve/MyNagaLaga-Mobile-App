import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/models/dio/data_state.dart';
import '../../../../common/resources/assets.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../common/widgets/secondary_button.dart';
import '../../../../common/widgets/text_input.dart';
import '../../../../common/widgets/upload_image_card.dart';
import '../../../auth/notifier/auth_session_notifier.dart';
import '../../../home/notifier/user_badge_notifier.dart';
import '../../models/welfare_program_model.dart';
import '../../models/welfare_request_model.dart';
import '../../notifier/request_welfare_notifier.dart';

// ─── Application Page ─────────────────────────────────────────────────────────

class PostingApplicationPage extends ConsumerStatefulWidget {
  final WelfarePostingModel posting;
  const PostingApplicationPage({super.key, required this.posting});

  @override
  ConsumerState<PostingApplicationPage> createState() =>
      _PostingApplicationPageState();
}

class _PostingApplicationPageState
    extends ConsumerState<PostingApplicationPage> {
  final _reasonController = TextEditingController();
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, File?> _fileUploads = {};

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _reasonController.dispose();
    for (final c in _textControllers.values) c.dispose();
    super.dispose();
  }

  void _setFile(String key, File file) =>
      setState(() => _fileUploads[key] = file);

  void _removeFile(String key) => setState(() => _fileUploads[key] = null);

  void _goToReview() {
    if (_reasonController.text.trim().length < 20) {
      _showSnack(
        'Please provide a reason (minimum 20 characters)',
        isError: true,
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostingApplicationReviewPage(
          posting: widget.posting,
          reason: _reasonController.text.trim(),
          textFields: Map.from(
            _textControllers.map((k, c) => MapEntry(k, c.text.trim())),
          ),
          fileUploads: Map.from(_fileUploads),
        ),
      ),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Segoe UI')),
        backgroundColor: isError ? AppColors.red : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  String _getBadgeImage(String badgeName) {
    final n = badgeName.toLowerCase();
    if (n.contains('senior')) return Assets.seniorCitizenBadge;
    if (n.contains('pwd') || n.contains('disab')) return Assets.pwdBadge;
    if (n.contains('solo') || n.contains('parent'))
      return Assets.soloParentBadge;
    if (n.contains('student')) return Assets.studentBadge;
    if (n.contains('indigent') || n.contains('family'))
      return Assets.indigentFamilyBadge;
    return Assets.studentBadge;
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);

    final userBadgeIds = ref
        .watch(badgesNotifierProvider)
        .when(
          started: () => <String>[],
          loading: () => <String>[],
          error: (_) => <String>[],
          success: (data) => data.badges
              .map((e) => e.badgeTypeId.toString())
              .where((id) => id.isNotEmpty)
              .toList(),
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'Apply for Assistance'),
      bottomNavigationBar: _BottomBar(
        label: 'Review Application',
        onSubmit: _goToReview,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        children: [
          _HeaderCard(posting: widget.posting),
          24.gapH,
          _SectionHeader(title: 'Reason for Request'),
          8.gapH,
          TextInput(
            controller: _reasonController,
            hintText: 'Please explain why you need this assistance',
            maxLines: 5,
          ),
          6.gapH,
          _CharCounter(current: _reasonController.text.length, minimum: 20),
          24.gapH,
          if (widget.posting.requirements.isNotEmpty) ...[
            _SectionHeader(title: 'Requirements'),
            8.gapH,
            _SubtitleText(
              text:
                  'Please fill in all required fields and upload the necessary documents.',
            ),
            20.gapH,
            ...widget.posting.requirements.map(
              (group) => _RequirementGroup(
                group: group,
                textControllers: _textControllers,
                fileUploads: _fileUploads,
                onPickFile: _setFile,
                onRemoveFile: _removeFile,
                onControllerCreated: (key, ctrl) {
                  ctrl.addListener(() => setState(() {}));
                },
              ),
            ),
          ],
          if (widget.posting.requiredBadges.isNotEmpty) ...[
            _SectionHeader(title: 'Badge Requirement'),
            8.gapH,
            _SubtitleText(
              text: 'You must hold one of the following badges to be eligible.',
            ),
            16.gapH,
            ...widget.posting.requiredBadges.map((badge) {
              final held = userBadgeIds.contains(badge.id);
              return Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Image.asset(
                  _getBadgeImage(badge.name),
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  color: held ? null : Colors.grey.withOpacity(0.5),
                  colorBlendMode: held ? null : BlendMode.saturation,
                ),
              );
            }),
          ],
          100.gapH,
        ],
      ),
    );
  }
}

// ─── Review Page ──────────────────────────────────────────────────────────────

class PostingApplicationReviewPage extends ConsumerStatefulWidget {
  final WelfarePostingModel posting;
  final String reason;
  final Map<String, String> textFields;
  final Map<String, File?> fileUploads;

  const PostingApplicationReviewPage({
    super.key,
    required this.posting,
    required this.reason,
    required this.textFields,
    required this.fileUploads,
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
      _showSnack('User not authenticated', isError: true);
      return;
    }

    await ref
        .read(welfareServiceNotifierProvider.notifier)
        .submitApplication(
          postingId: widget.posting.id,
          mobileUserId: userId,
          description: widget.reason,
          textFields: widget.textFields,
          files: widget.fileUploads,
          posting: widget.posting,
        );

    if (!mounted) return;

    final state = ref.read(welfareServiceNotifierProvider);
    state.when(
      started: () {},
      loading: () {},
      success: (data) {
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
      error: (msg) => _showSnack(msg ?? 'Failed to submit', isError: true),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Segoe UI')),
        backgroundColor: isError ? AppColors.red : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  /// Build a lookup map from item.key → item (for label resolution)
  Map<String, WelfareRequirementItem> get _itemByKey {
    final map = <String, WelfareRequirementItem>{};
    for (final group in widget.posting.requirements) {
      for (final item in group.items) {
        map[item.key] = item;
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);

    final appState = ref.watch(welfareServiceNotifierProvider);
    final isSubmitting = appState.when(
      started: () => false,
      loading: () => true,
      error: (_) => false,
      success: (_) => false,
    );

    final preFilledData = appState.when(
      started: () => null,
      loading: () => null,
      error: (_) => null,
      success: (data) => data,
    );

    final hasPreFilledText =
        (preFilledData?.autoFilledTextByCategory ?? []).isNotEmpty;
    final hasAutoAttached =
        (preFilledData?.autoAttachedByCategory ?? []).isNotEmpty;

    final itemByKey = _itemByKey;

    // Build filled text entries with proper labels
    widget.textFields.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => (label: itemByKey[e.key]?.label ?? e.key, value: e.value))
        .toList();

    // Build file entries with proper labels
    widget.fileUploads.entries
        .where((e) => e.value != null)
        .map((e) => (label: itemByKey[e.key]?.label ?? e.key, file: e.value!))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'Review Application'),
      bottomNavigationBar: _BottomBar(
        label: 'Submit Application',
        isLoading: isSubmitting,
        onSubmit: isSubmitting ? () {} : _submit,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        children: [
          // ── Posting header ──────────────────────────────────────────
          _HeaderCard(posting: widget.posting),
          24.gapH,

          // ── Auto-filled badge data (shown after first submit) ───────
          if (hasPreFilledText) ...[
            _SectionHeader(title: 'Auto-filled from Your Badges'),
            8.gapH,
            _SubtitleText(
              text:
                  'The following information was pre-filled from your verified badges.',
            ),
            12.gapH,
            ...preFilledData!.autoFilledTextByCategory.map(
              (c) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _AutoFilledCategoryCard(category: c),
              ),
            ),
            24.gapH,
          ],

          if (hasAutoAttached) ...[
            _SectionHeader(title: 'Auto-attached Documents'),
            8.gapH,
            _SubtitleText(
              text:
                  'The following documents were automatically attached from your badge records.',
            ),
            12.gapH,
            ...preFilledData!.autoAttachedByCategory.map(
              (c) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _AutoAttachedCategoryCard(category: c),
              ),
            ),
            24.gapH,
          ],

          // ── Reason ──────────────────────────────────────────────────
          _ReviewSectionCard(
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

          // ── Requirements by group ────────────────────────────────────
          if (widget.posting.requirements.isNotEmpty) ...[
            ...widget.posting.requirements.map((group) {
              // Only show groups that have filled text or uploaded files
              final groupTextItems = group.items
                  .where(
                    (item) =>
                        item.type == 'text' &&
                        (widget.textFields[item.key] ?? '').isNotEmpty,
                  )
                  .toList();

              final groupFileItems = group.items
                  .where(
                    (item) =>
                        item.type != 'text' &&
                        widget.fileUploads[item.key] != null,
                  )
                  .toList();

              if (groupTextItems.isEmpty && groupFileItems.isEmpty) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _ReviewGroupCard(
                  category: group.category,
                  textItems: groupTextItems,
                  fileItems: groupFileItems,
                  textFields: widget.textFields,
                  fileUploads: widget.fileUploads,
                ),
              );
            }),
          ],

          100.gapH,
        ],
      ),
    );
  }
}

// ─── Review Group Card ────────────────────────────────────────────────────────
// Shows text fields and file uploads for one requirement group, with the
// category name as a header — matching the same card style as the form page.

class _ReviewGroupCard extends StatelessWidget {
  final String category;
  final List<WelfareRequirementItem> textItems;
  final List<WelfareRequirementItem> fileItems;
  final Map<String, String> textFields;
  final Map<String, File?> fileUploads;

  const _ReviewGroupCard({
    required this.category,
    required this.textItems,
    required this.fileItems,
    required this.textFields,
    required this.fileUploads,
  });

  @override
  Widget build(BuildContext context) {
    final allItems = [...textItems, ...fileItems];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(D.radiusLG),
        border: Border.all(color: AppColors.grey.withOpacity(.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category header — same style as form page ──────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(D.radiusLG),
                topRight: Radius.circular(D.radiusLG),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 16.r,
                  color: AppColors.primary,
                ),
                8.gapW,
                Text(
                  category,
                  style: TextStyle(
                    fontSize: D.textSM,
                    fontWeight: D.semiBold,
                    color: AppColors.primary,
                    fontFamily: 'Segoe UI',
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${allItems.length} item${allItems.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: D.textXS,
                      color: AppColors.primary,
                      fontFamily: 'Segoe UI',
                      fontWeight: D.semiBold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Items ──────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text items
                ...textItems.asMap().entries.map((entry) {
                  final item = entry.value;
                  final value = textFields[item.key] ?? '';
                  final isLastInSection =
                      entry.key == textItems.length - 1 && fileItems.isEmpty;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ReviewFieldRow(
                        label: item.label,
                        icon: Icons.text_fields_rounded,
                        iconColor: AppColors.primary,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: D.textBase,
                            fontFamily: 'Segoe UI',
                            color: AppColors.black,
                            fontWeight: D.medium,
                          ),
                        ),
                      ),
                      if (!isLastInSection) ...[
                        10.gapH,
                        Divider(
                          height: 1,
                          color: AppColors.grey.withOpacity(.1),
                        ),
                        10.gapH,
                      ],
                    ],
                  );
                }),

                // Divider between text and file sections
                if (textItems.isNotEmpty && fileItems.isNotEmpty) ...[
                  10.gapH,
                  Divider(height: 1, color: AppColors.grey.withOpacity(.1)),
                  10.gapH,
                ],

                // File items
                ...fileItems.asMap().entries.map((entry) {
                  final item = entry.value;
                  final file = fileUploads[item.key]!;
                  final isLast = entry.key == fileItems.length - 1;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ReviewFieldRow(
                        label: item.label,
                        icon: Icons.insert_drive_file_rounded,
                        iconColor: Colors.teal,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(D.radiusMD),
                          child: Image.file(
                            file,
                            width: double.infinity,
                            height: 160.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (!isLast) ...[
                        10.gapH,
                        Divider(
                          height: 1,
                          color: AppColors.grey.withOpacity(.1),
                        ),
                        10.gapH,
                      ],
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Review Field Row ─────────────────────────────────────────────────────────
// Label + icon above content — consistent HCI pattern.

class _ReviewFieldRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _ReviewFieldRow({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Icon(icon, size: 15.r, color: iconColor.withOpacity(.8)),
            ),
            6.gapW,
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: D.textSM,
                  color: AppColors.grey,
                  fontFamily: 'Segoe UI',
                  fontWeight: D.medium,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        8.gapH,
        child,
      ],
    );
  }
}

// ─── Review Section Card ──────────────────────────────────────────────────────
// Generic titled card used for "Reason for Request" section.

class _ReviewSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _ReviewSectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(D.radiusLG),
        border: Border.all(color: AppColors.grey.withOpacity(.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(D.radiusLG),
                topRight: Radius.circular(D.radiusLG),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16.r, color: AppColors.primary),
                8.gapW,
                Text(
                  title,
                  style: TextStyle(
                    fontSize: D.textSM,
                    fontWeight: D.semiBold,
                    color: AppColors.primary,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(16.w), child: child),
        ],
      ),
    );
  }
}

// ─── Success Page ─────────────────────────────────────────────────────────────

class PostingApplicationSuccessPage extends StatelessWidget {
  final WelfarePostingModel posting;
  final WelfareRequestModel result;

  const PostingApplicationSuccessPage({
    super.key,
    required this.posting,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    D.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              const Spacer(),

              // ── Check icon ────────────────────────────────────────
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: 40.r,
                ),
              ),
              24.gapH,

              Text(
                'Application Submitted!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: D.textXL,
                  fontWeight: D.bold,
                  fontFamily: 'Segoe UI',
                  color: AppColors.black,
                ),
              ),
              12.gapH,
              Text(
                'Your application for ${posting.title} has been submitted successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: D.textBase,
                  color: AppColors.grey,
                  fontFamily: 'Segoe UI',
                  height: 1.6,
                ),
              ),
              32.gapH,

              // ── Summary card ──────────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(D.radiusLG),
                  border: Border.all(color: AppColors.grey.withOpacity(.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Posting title
                    Text(
                      posting.title,
                      style: TextStyle(
                        fontSize: D.textBase,
                        fontWeight: D.bold,
                        fontFamily: 'Segoe UI',
                        color: AppColors.black,
                      ),
                    ),
                    if (posting.serviceName != null) ...[
                      4.gapH,
                      Text(
                        posting.serviceName!,
                        style: TextStyle(
                          fontSize: D.textSM,
                          color: AppColors.grey,
                          fontFamily: 'Segoe UI',
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Spacer(),

              // ── Back to Services (not just "Home") ────────────────
              SizedBox(
                width: double.infinity,
                height: D.primaryButton,
                child: SecondaryButton(
                  text: 'Back to Services',
                  isFilled: true,
                  onPressed: () => Navigator.of(context).popUntil(
                    (r) => r.settings.name == '/services' || r.isFirst,
                  ),
                ),
              ),
              24.gapH,
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final WelfarePostingModel posting;
  const _HeaderCard({required this.posting});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          posting.title,
          style: TextStyle(
            fontSize: D.textXL,
            fontWeight: D.bold,
            fontFamily: 'Segoe UI',
            color: AppColors.black,
            height: 1.3,
          ),
        ),
        if (posting.serviceName != null) ...[
          4.gapH,
          Text(
            posting.serviceName!,
            style: TextStyle(
              fontSize: D.textSM,
              color: AppColors.grey,
              fontFamily: 'Segoe UI',
            ),
          ),
        ],
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onSubmit;
  const _BottomBar({
    required this.label,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 50.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        height: D.primaryButton,
        child: SecondaryButton(
          text: label,
          onPressed: onSubmit,
          isLoading: isLoading,
          isFilled: true,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: D.textLG,
        fontWeight: D.bold,
        fontFamily: 'Segoe UI',
        color: AppColors.black,
      ),
    );
  }
}

class _SubtitleText extends StatelessWidget {
  final String text;
  const _SubtitleText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: D.textSM,
        color: AppColors.grey,
        fontFamily: 'Segoe UI',
        height: 1.5,
      ),
    );
  }
}

class _CharCounter extends StatelessWidget {
  final int current;
  final int minimum;
  const _CharCounter({required this.current, required this.minimum});

  @override
  Widget build(BuildContext context) {
    final met = current >= minimum;
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.info_outline_rounded,
          size: 13.r,
          color: met ? AppColors.primary : AppColors.grey,
        ),
        4.gapW,
        Text(
          met
              ? '$current characters'
              : '$current / $minimum characters minimum',
          style: TextStyle(
            fontSize: D.textXS,
            color: met ? AppColors.primary : AppColors.grey,
            fontFamily: 'Segoe UI',
          ),
        ),
      ],
    );
  }
}

class _MatchScorePill extends StatelessWidget {
  final double score;
  final Color? color;
  const _MatchScorePill({required this.score, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: c.withOpacity(.08),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        '${(score * 100).toStringAsFixed(0)}% match',
        style: TextStyle(
          fontSize: D.textXS,
          fontWeight: D.semiBold,
          color: c,
          fontFamily: 'Segoe UI',
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, required this.required});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: D.textSM,
          fontWeight: D.medium,
          color: AppColors.black,
          fontFamily: 'Segoe UI',
        ),
        children: required
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.red, fontSize: D.textSM),
                ),
              ]
            : [],
      ),
    );
  }
}

class _VerifiedChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 10.r, color: AppColors.primary),
          3.gapW,
          Text(
            'Verified',
            style: TextStyle(
              fontSize: D.textXS,
              fontWeight: D.semiBold,
              color: AppColors.primary,
              fontFamily: 'Segoe UI',
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachedChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(.08),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attach_file_rounded, size: 10.r, color: Colors.teal),
          3.gapW,
          Text(
            'Attached',
            style: TextStyle(
              fontSize: D.textXS,
              fontWeight: D.semiBold,
              color: Colors.teal,
              fontFamily: 'Segoe UI',
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Auto-filled Category Card ────────────────────────────────────────────────

class _AutoFilledCategoryCard extends StatefulWidget {
  final WelfareAutoFilledCategory category;
  const _AutoFilledCategoryCard({required this.category});

  @override
  State<_AutoFilledCategoryCard> createState() =>
      _AutoFilledCategoryCardState();
}

class _AutoFilledCategoryCardState extends State<_AutoFilledCategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(D.radiusLG),
        border: Border.all(
          color: _expanded
              ? AppColors.primary.withOpacity(.4)
              : AppColors.primary.withOpacity(.2),
        ),
        boxShadow: _expanded
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(D.radiusLG),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.1),
                      borderRadius: BorderRadius.circular(D.radiusMD),
                    ),
                    child: Icon(
                      Icons.auto_fix_high_rounded,
                      color: AppColors.primary,
                      size: 20.r,
                    ),
                  ),
                  12.gapW,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.category,
                          style: TextStyle(
                            fontSize: D.textBase,
                            fontWeight: D.semiBold,
                            fontFamily: 'Segoe UI',
                            color: AppColors.black,
                          ),
                        ),
                        3.gapH,
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 12.r,
                              color: AppColors.primary,
                            ),
                            4.gapW,
                            Text(
                              '${widget.category.items.length} field${widget.category.items.length == 1 ? '' : 's'} auto-filled',
                              style: TextStyle(
                                fontSize: D.textXS,
                                color: AppColors.primary,
                                fontFamily: 'Segoe UI',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _VerifiedChip(),
                  8.gapW,
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.grey,
                      size: 20.r,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(height: 1, color: AppColors.primary.withOpacity(.12)),
                Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    children: widget.category.items.map((item) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14.r,
                              color: AppColors.primary,
                            ),
                            6.gapW,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: D.textSM,
                                      color: AppColors.grey,
                                      fontFamily: 'Segoe UI',
                                    ),
                                  ),
                                  2.gapH,
                                  Text(
                                    'from ${item.badgeTypeName}',
                                    style: TextStyle(
                                      fontSize: D.textXS,
                                      color: AppColors.primary.withOpacity(.6),
                                      fontFamily: 'Segoe UI',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            8.gapW,
                            _MatchScorePill(score: item.matchScore),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

// ─── Auto-attached Category Card ──────────────────────────────────────────────

class _AutoAttachedCategoryCard extends StatefulWidget {
  final WelfareAutoAttachedCategory category;
  const _AutoAttachedCategoryCard({required this.category});

  @override
  State<_AutoAttachedCategoryCard> createState() =>
      _AutoAttachedCategoryCardState();
}

class _AutoAttachedCategoryCardState extends State<_AutoAttachedCategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(D.radiusLG),
        border: Border.all(
          color: _expanded
              ? Colors.teal.withOpacity(.4)
              : Colors.teal.withOpacity(.2),
        ),
        boxShadow: _expanded
            ? [
                BoxShadow(
                  color: Colors.teal.withOpacity(.07),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(D.radiusLG),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(.1),
                      borderRadius: BorderRadius.circular(D.radiusMD),
                    ),
                    child: Icon(
                      Icons.attach_file_rounded,
                      color: Colors.teal,
                      size: 20.r,
                    ),
                  ),
                  12.gapW,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.category,
                          style: TextStyle(
                            fontSize: D.textBase,
                            fontWeight: D.semiBold,
                            fontFamily: 'Segoe UI',
                            color: AppColors.black,
                          ),
                        ),
                        3.gapH,
                        Row(
                          children: [
                            Icon(
                              Icons.file_present_rounded,
                              size: 12.r,
                              color: Colors.teal,
                            ),
                            4.gapW,
                            Text(
                              '${widget.category.items.length} document${widget.category.items.length == 1 ? '' : 's'} attached',
                              style: TextStyle(
                                fontSize: D.textXS,
                                color: Colors.teal,
                                fontFamily: 'Segoe UI',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _AttachedChip(),
                  8.gapW,
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.grey,
                      size: 20.r,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(height: 1, color: Colors.teal.withOpacity(.12)),
                Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    children: widget.category.items.map((item) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.insert_drive_file_outlined,
                              size: 14.r,
                              color: Colors.teal,
                            ),
                            6.gapW,
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: D.textSM,
                                  color: AppColors.black,
                                  fontFamily: 'Segoe UI',
                                  fontWeight: D.medium,
                                ),
                              ),
                            ),
                            _MatchScorePill(
                              score: item.matchScore,
                              color: Colors.teal,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

// ─── Requirement Group (Form Page) ───────────────────────────────────────────

class _RequirementGroup extends StatelessWidget {
  final WelfareRequirementGroup group;
  final Map<String, TextEditingController> textControllers;
  final Map<String, File?> fileUploads;
  final void Function(String key, File file) onPickFile;
  final void Function(String key) onRemoveFile;
  final void Function(String key, TextEditingController controller)
  onControllerCreated;

  const _RequirementGroup({
    required this.group,
    required this.textControllers,
    required this.fileUploads,
    required this.onPickFile,
    required this.onRemoveFile,
    required this.onControllerCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(D.radiusLG),
        border: Border.all(color: AppColors.grey.withOpacity(.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(D.radiusLG),
                topRight: Radius.circular(D.radiusLG),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 16.r,
                  color: AppColors.primary,
                ),
                8.gapW,
                Text(
                  group.category,
                  style: TextStyle(
                    fontSize: D.textSM,
                    fontWeight: D.semiBold,
                    color: AppColors.primary,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (group.description != null) ...[
                  Text(
                    group.description!,
                    style: TextStyle(
                      fontSize: D.textXS,
                      color: AppColors.grey,
                      fontFamily: 'Segoe UI',
                      height: 1.5,
                    ),
                  ),
                  12.gapH,
                ],
                ...group.items.asMap().entries.map((entry) {
                  final isLast = entry.key == group.items.length - 1;
                  return Column(
                    children: [
                      entry.value.type == 'text'
                          ? _TextRequirementField(
                              item: entry.value,
                              controllers: textControllers,
                              onControllerCreated: onControllerCreated,
                            )
                          : _FileRequirementField(
                              item: entry.value,
                              fileUploads: fileUploads,
                              onPick: onPickFile,
                              onRemove: onRemoveFile,
                            ),
                      if (!isLast) ...[
                        12.gapH,
                        Divider(
                          height: 1,
                          color: AppColors.grey.withOpacity(.1),
                        ),
                        12.gapH,
                      ],
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextRequirementField extends StatefulWidget {
  final WelfareRequirementItem item;
  final Map<String, TextEditingController> controllers;
  final void Function(String key, TextEditingController controller)
  onControllerCreated;

  const _TextRequirementField({
    required this.item,
    required this.controllers,
    required this.onControllerCreated,
  });

  @override
  State<_TextRequirementField> createState() => _TextRequirementFieldState();
}

class _TextRequirementFieldState extends State<_TextRequirementField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    if (!widget.controllers.containsKey(widget.item.key)) {
      _controller = TextEditingController();
      widget.controllers[widget.item.key] = _controller;
      widget.onControllerCreated(widget.item.key, _controller);
    } else {
      _controller = widget.controllers[widget.item.key]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: widget.item.label, required: widget.item.required),
        8.gapH,
        TextInput(
          controller: _controller,
          hintText:
              widget.item.notes ?? 'Enter ${widget.item.label.toLowerCase()}',
        ),
      ],
    );
  }
}

class _FileRequirementField extends StatelessWidget {
  final WelfareRequirementItem item;
  final Map<String, File?> fileUploads;
  final void Function(String key, File file) onPick;
  final void Function(String key) onRemove;

  const _FileRequirementField({
    required this.item,
    required this.fileUploads,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final file = fileUploads[item.key];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: item.label, required: item.required),
        if (item.notes != null) ...[
          4.gapH,
          Text(
            item.notes!,
            style: TextStyle(
              fontSize: D.textXS,
              color: AppColors.grey,
              fontFamily: 'Segoe UI',
            ),
          ),
        ],
        10.gapH,
        UploadImage(
          image: file,
          subtitle: 'Take a photo or upload a file',
          height: 160.h,
          onPickImage: (source) async {
            final picked = await ImagePicker().pickImage(
              source: source,
              imageQuality: 85,
            );
            if (picked != null) onPick(item.key, File(picked.path));
          },
          onRemove: () => onRemove(item.key),
        ),
      ],
    );
  }
}
