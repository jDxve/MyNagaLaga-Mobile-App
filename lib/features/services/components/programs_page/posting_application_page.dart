import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/models/dio/data_state.dart';
import '../../../../common/resources/assets.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../common/widgets/error_modal.dart';
import '../../../../common/widgets/text_input.dart';
import '../../../home/notifier/user_badge_notifier.dart';
import '../../models/welfare_request_model.dart';
import '../../models/welfare_program_model.dart';
import '../../notifier/request_welfare_notifier.dart';
import 'posting_application_review_page.dart';
import 'posting_application_widgets.dart';

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
  final Set<String> _selectedOptionalBadgeTypeIds = {};

  WelfareRequestModel? _pendingPrefill;
  WelfareRequestModel? _prefillModel;
  bool _prefillApplied = false;
  Set<String> _autoAttachedRequirementIds = {};

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _triggerPrefill());
  }

  @override
  void dispose() {
    _reasonController.dispose();
    for (final c in _textControllers.values) c.dispose();
    super.dispose();
  }

  List<String> get _allAttachedBadgeTypeIds => {
    ...widget.posting.requiredBadges.map((b) => b.id),
    ..._selectedOptionalBadgeTypeIds,
  }.toList();

  void _triggerPrefill() {
    if (_allAttachedBadgeTypeIds.isEmpty) return;
    _prefillApplied = false;
    _pendingPrefill = null;
    ref
        .read(welfareServiceNotifierProvider.notifier)
        .fetchPrefill(
          postingId: widget.posting.id,
          attachedBadgeTypeIds: _allAttachedBadgeTypeIds,
          posting: widget.posting,
        );
  }

  void _onControllerCreated(String key, TextEditingController ctrl) {
    ctrl.addListener(() => setState(() {}));
    if (_pendingPrefill != null) {
      final val = _buildAutoTexts(_pendingPrefill!)[key];
      if (val != null && ctrl.text.isEmpty) {
        ctrl.text = val;
      }
    }
  }

  Map<String, String> _buildAutoTexts(WelfareRequestModel prefill) {
    final autoTexts = <String, String>{};

    for (final badge in prefill.prefillBadges) {
      final common = badge.formCommon;
      final extra = badge.formExtraNonNull;

      void put(String key, String? val) {
        if (val != null && val.isNotEmpty) autoTexts[key] = val;
      }

      put('full_name', common['fullName']);
      put('home_address', common['homeAddress']);
      put('mobile_number', common['contactNumber']);
      put('contact_number', common['contactNumber']);
      put('sex', common['gender']);
      put('gender', common['gender']);
      put('type_of_id', common['typeOfId']);

      final birthdate = common['birthdate'];
      if (birthdate != null && birthdate.isNotEmpty) {
        final dt = DateTime.tryParse(birthdate);
        if (dt != null) {
          put(
            'birthdate',
            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}',
          );
          int age = DateTime.now().year - dt.year;
          if (DateTime.now().month < dt.month ||
              (DateTime.now().month == dt.month &&
                  DateTime.now().day < dt.day)) {
            age--;
          }
          put('age', age.toString());
        }
      }

      extra.forEach((k, v) {
        put(_camelToSnake(k), v);
        put(k, v);
      });
    }

    return autoTexts;
  }

  String _camelToSnake(String key) {
    return key
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (m) => '_${m.group(0)!.toLowerCase()}',
        )
        .replaceFirst(RegExp(r'^_'), '');
  }

  void _applyPrefill(WelfareRequestModel prefill) {
    if (_prefillApplied) return;
    _prefillApplied = true;
    _pendingPrefill = prefill;

    setState(() {
      _prefillModel = prefill;
      _autoAttachedRequirementIds = prefill.autoAttachedRequirements
          .map((r) => r.requirementId)
          .toSet();
    });

    if (prefill.prefillBadges.isEmpty) return;

    final autoTexts = _buildAutoTexts(prefill);

    setState(() {
      for (final entry in autoTexts.entries) {
        final ctrl = _textControllers[entry.key];
        if (ctrl != null && ctrl.text.isEmpty) {
          ctrl.text = entry.value;
        }
      }
    });
  }

  void _toggleOptionalBadge(String badgeTypeId) {
    setState(() {
      if (_selectedOptionalBadgeTypeIds.contains(badgeTypeId)) {
        _selectedOptionalBadgeTypeIds.remove(badgeTypeId);
      } else {
        _selectedOptionalBadgeTypeIds.add(badgeTypeId);
      }
      _autoAttachedRequirementIds = {};
      _prefillModel = null;
    });

    _prefillApplied = false;
    _pendingPrefill = null;

    for (final ctrl in _textControllers.values) {
      ctrl.text = '';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _triggerPrefill());
  }

  void _setFile(String key, File file) =>
      setState(() => _fileUploads[key] = file);

  void _removeFile(String key) => setState(() => _fileUploads[key] = null);

  void _goToReview() {
    if (_reasonController.text.trim().length < 20) {
      showErrorModal(
        context: context,
        title: 'Reason Too Short',
        description: 'Please provide a reason with at least 20 characters.',
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
          attachedBadgeTypeIds: _allAttachedBadgeTypeIds,
        ),
      ),
    );
  }

  String _getBadgeImage(String name) {
    final n = name.toLowerCase();
    if (n.contains('senior')) return Assets.seniorCitizenBadge;
    if (n.contains('pwd') || n.contains('disab')) return Assets.pwdBadge;
    if (n.contains('solo') || n.contains('parent')) return Assets.soloParentBadge;
    if (n.contains('student')) return Assets.studentBadge;
    if (n.contains('indigent') || n.contains('family')) return Assets.indigentFamilyBadge;
    return Assets.studentBadge;
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);

    final prefillState = ref.watch(welfareServiceNotifierProvider);
    prefillState.whenOrNull(success: (data) => _applyPrefill(data));

    final isPrefilling = prefillState.when(
      started: () => false,
      loading: () => true,
      error: (_) => false,
      success: (_) => false,
    );

    prefillState.whenOrNull(
      error: (msg) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && msg != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not load badge data: $msg'),
                backgroundColor: AppColors.red,
              ),
            );
          }
        });
      },
    );

    final userBadges = ref
        .watch(badgesNotifierProvider)
        .when(
          started: () => [],
          loading: () => [],
          error: (_) => [],
          success: (data) => data.badges,
        );

    final requiredBadgeIds = widget.posting.requiredBadges
        .map((b) => b.id)
        .toSet();

    final optionalBadges = userBadges
        .where(
          (b) =>
              b.status.toLowerCase() == 'active' &&
              !requiredBadgeIds.contains(b.badgeTypeId.toString()),
        )
        .toList();



    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'Apply for Assistance'),
      bottomNavigationBar: PostingBottomBar(
        label: 'Review Application',
        onSubmit: _goToReview,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        children: [
          PostingHeaderCard(posting: widget.posting),
          28.gapH,

          if (widget.posting.requiredBadges.isNotEmpty) ...[
            PostingSectionHeader(title: 'Your Eligible Badge'),
            8.gapH,
            PostingSubtitleText(
              text: isPrefilling
                  ? 'Loading your badge data to pre-fill this form...'
                  : 'Your badge data has been used to pre-fill fields below.',
            ),
            16.gapH,
            ...widget.posting.requiredBadges.map(
              (badge) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _BadgeTile(
                  name: badge.name,
                  image: _getBadgeImage(badge.name),
                  isRequired: true,
                  isSelected: true,
                  isLoading: isPrefilling,
                  onToggle: null,
                ),
              ),
            ),
            2.gapH,
          ],

          if (optionalBadges.isNotEmpty) ...[
            PostingSectionHeader(title: 'Attach Additional Badges'),
            8.gapH,
            PostingSubtitleText(
              text: 'Select more badges to auto-fill additional fields.',
            ),
            16.gapH,
            ...optionalBadges.map((badge) {
              final id = badge.badgeTypeId.toString();
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _BadgeTile(
                  name: badge.badgeTypeName,
                  image: _getBadgeImage(badge.badgeTypeName),
                  isRequired: false,
                  isSelected: _selectedOptionalBadgeTypeIds.contains(id),
                  isLoading: false,
                  onToggle: () => _toggleOptionalBadge(id),
                ),
              );
            }),
            24.gapH,
          ],

          PostingSectionHeader(title: 'Reason for Request'),
          8.gapH,
          TextInput(
            controller: _reasonController,
            hintText: 'Please explain why you need this assistance',
            maxLines: 5,
          ),
          6.gapH,
          PostingCharCounter(
            current: _reasonController.text.length,
            minimum: 20,
          ),
          24.gapH,

          if (widget.posting.requirements.isNotEmpty) ...[
            PostingSectionHeader(title: 'Requirements'),
            8.gapH,
            PostingSubtitleText(
              text: isPrefilling
                  ? 'Loading...'
                  : _prefillModel != null || _autoAttachedRequirementIds.isNotEmpty
                  ? 'Fields and files have been auto-filled from your badge.'
                  : 'Fill in the required fields below.',
            ),
            20.gapH,
            ...widget.posting.requirements.map(
              (group) => PostingRequirementGroup(
                group: group,
                textControllers: _textControllers,
                fileUploads: _fileUploads,
                onPickFile: _setFile,
                onRemoveFile: _removeFile,
                onControllerCreated: _onControllerCreated,
                prefillModel: _prefillModel,
              ),
            ),
          ],
          100.gapH,
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final String name;
  final String image;
  final bool isRequired;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback? onToggle;

  const _BadgeTile({
    required this.name,
    required this.image,
    required this.isRequired,
    required this.isSelected,
    required this.isLoading,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Stack(
        children: [
          Image.asset(
            image,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            color: isSelected ? null : Colors.grey.withOpacity(0.4),
            colorBlendMode: isSelected ? null : BlendMode.saturation,
          ),
          if (isLoading)
            Positioned(
              top: 10.h,
              right: 10.w,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.85),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 14.w,
                  height: 14.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          else if (!isRequired)
            Positioned(
              top: 10.h,
              right: 10.w,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.white.withOpacity(.85),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.grey.withOpacity(.4),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check_rounded, size: 13.r, color: Colors.white)
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}