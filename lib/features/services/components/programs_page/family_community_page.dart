import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/models/dio/data_state.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../../common/resources/assets.dart';
import '../../../../common/resources/strings.dart';
import '../../../../common/utils/constant.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../common/widgets/drop_down.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/info_card.dart';
import '../../../../common/widgets/toggle.dart';
import '../../../../common/widgets/text_input.dart';
import '../../../../common/widgets/upload_image_card.dart';
import '../../../auth/notifier/auth_session_notifier.dart';
import '../../models/welfare_request_model.dart';
import '../../models/posting_requirement_model.dart';
import '../../notifier/request_welfare_notifier.dart';

class FamilyCommunityPage extends ConsumerStatefulWidget {
  final String postingId;
  final String postingTitle;
  final String userName;
  final String userAge;
  final String? userBadgeType;
  final int? userBadgeId;
  final List<int>? requirementIds;
  final List<PostingRequirement>? requirements;

  const FamilyCommunityPage({
    super.key,
    required this.postingId,
    required this.postingTitle,
    required this.userName,
    required this.userAge,
    this.userBadgeType,
    this.userBadgeId,
    this.requirementIds,
    this.requirements,
  });

  @override
  ConsumerState<FamilyCommunityPage> createState() =>
      _FamilyCommunityPageState();
}

class _FamilyCommunityPageState extends ConsumerState<FamilyCommunityPage> {
  String? selectedRecipient = Constant.forMe;
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController familyMemberController = TextEditingController();
  final Map<int, File?> uploadedFiles = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    reasonController.addListener(() => setState(() {}));
    if (widget.requirements != null) {
      for (var req in widget.requirements!) {
        uploadedFiles[req.id] = null;
      }
    }
  }

  @override
  void dispose() {
    reasonController.dispose();
    familyMemberController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(int requirementId, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          uploadedFiles[requirementId] = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: $e')),
        );
      }
    }
  }

  String _getBadgeImage(String? badgeType) {
    if (badgeType == null) return Assets.seniorCitizenBadge;
    switch (badgeType.toLowerCase()) {
      case 'student':
        return Assets.studentBadge;
      case 'senior citizen':
        return Assets.seniorCitizenBadge;
      case 'pwd':
        return Assets.pwdBadge;
      case 'solo parent':
        return Assets.soloParentBadge;
      case 'indigent family':
        return Assets.indigentFamilyBadge;
      default:
        return Assets.seniorCitizenBadge;
    }
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(D.radiusXL),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 50,
                    color: Colors.green,
                  ),
                ),
                20.gapH,
                Text(
                  'Success!',
                  style: TextStyle(
                    fontSize: D.textXL,
                    fontWeight: D.bold,
                    color: AppColors.black,
                  ),
                ),
                12.gapH,
                Text(
                  'Your request has been submitted successfully. You will be notified once it has been reviewed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: D.textSM,
                    color: AppColors.grey,
                    height: 1.5,
                  ),
                ),
                24.gapH,
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Done',
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    if (reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a reason for your request'),
        ),
      );
      return;
    }

    final List<String> filePaths = [];
    final List<String> missingRequirements = [];

    if (widget.requirementIds != null && widget.requirements != null) {
      for (int i = 0; i < widget.requirementIds!.length; i++) {
        final requirementId = widget.requirementIds![i];
        final file = uploadedFiles[requirementId];

        final requirement = widget.requirements!.firstWhere(
          (req) => req.id == requirementId,
          orElse: () => PostingRequirement(
            id: requirementId,
            label: 'Requirement $requirementId',
            category: '',
            type: 'file',
            required: true,
            order: i + 1,
          ),
        );

        if (file != null) {
          filePaths.add(file.path);
        } else if (requirement.required) {
          missingRequirements.add('${requirement.order}. ${requirement.label}');
        }
      }
    }

    if (missingRequirements.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please upload the following required documents:\n${missingRequirements.join("\n")}',
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authSession = ref.read(authSessionProvider);
      if (!authSession.isAuthenticated || authSession.userId == null) {
        throw Exception('User not authenticated');
      }

      final request = WelfareRequestModel(
        postingId: widget.postingId,
        mobileUserId: authSession.userId!,
        reason: reasonController.text.trim(),
        requirementIds: widget.requirementIds!,
        badgeId: widget.userBadgeId?.toString(),
        filePaths: filePaths,
      );

      final success = await ref
          .read(requestWelfareNotifierProvider.notifier)
          .submitRequest(request);

      if (!mounted) return;

      if (success) {
        _showSuccessModal();
      } else {
        final state = ref.read(requestWelfareNotifierProvider);
        final errorMessage = state.when(
          started: () => 'Failed to submit request',
          loading: () => 'Failed to submit request',
          success: (data) => 'Failed to submit request',
          error: (error) => error ?? 'Failed to submit request',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: widget.postingTitle,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Toggle(
                selectedValue: selectedRecipient,
                onChanged: (value) => setState(() => selectedRecipient = value),
                firstLabel: AppString.forMe,
                firstValue: Constant.forMe,
                secondLabel: AppString.forFamilyMember,
                secondValue: Constant.forFamily,
              ),
              20.gapH,
              if (selectedRecipient == Constant.forMe) ...[
                InfoCard(
                  title: AppString.applicantDetails,
                  items: [
                    InfoCardItem(
                      label: AppString.fullName,
                      value: widget.userName,
                    ),
                    InfoCardItem(label: AppString.age, value: widget.userAge),
                  ],
                ),
                20.gapH,
                _buildReasonSection(),
                20.gapH,
                _buildAttachedBadge(),
                20.gapH,
                _buildRequirementsSection(),
                24.gapH,
              ] else ...[
                _buildFamilyMemberForm(),
              ],
              PrimaryButton(
                text: _isSubmitting ? 'Submitting...' : AppString.submitRequest,
                onPressed: _isSubmitting ? () {} : _handleSubmit,
              ),
              20.gapH,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyMemberForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(AppString.familyMember),
        8.gapH,
        Dropdown(
          controller: familyMemberController,
          hintText: AppString.selectFamilyMember,
          items: const [
            'Juan Dela Cruz (Father)',
            'Maria Santos (Mother)',
            'Jose Rizal (Grandfather)',
            'Rosa Cruz (Grandmother)',
          ],
        ),
        20.gapH,
        _buildReasonSection(),
        20.gapH,
        _buildAttachedBadge(),
        20.gapH,
        _buildRequirementsSection(),
        24.gapH,
      ],
    );
  }

  Widget _buildRequirementsSection() {
    if (widget.requirements == null || widget.requirements!.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedRequirements = List<PostingRequirement>.from(
      widget.requirements!,
    )..sort((a, b) => a.order.compareTo(b.order));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Required Documents'),
        8.gapH,
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(D.radiusLG),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.primary),
              8.gapW,
              Expanded(
                child: Text(
                  'Please upload all required documents to complete your request',
                  style: TextStyle(
                    fontSize: D.textXS,
                    color: AppColors.primary,
                    fontWeight: D.medium,
                  ),
                ),
              ),
            ],
          ),
        ),
        16.gapH,
        ...sortedRequirements.map(
          (requirement) => Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _buildRequirementUpload(requirement),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementUpload(PostingRequirement requirement) {
    final isUploaded = uploadedFiles[requirement.id] != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(D.radiusLG),
        border: Border.all(
          color: requirement.required && !isUploaded
              ? Colors.red.withOpacity(0.3)
              : AppColors.grey.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isUploaded
                  ? Colors.green.withOpacity(0.05)
                  : AppColors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(D.radiusLG),
                topRight: Radius.circular(D.radiusLG),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: isUploaded ? Colors.green : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isUploaded
                        ? Icon(Icons.check, color: AppColors.white, size: 18)
                        : Text(
                            '${requirement.order}',
                            style: TextStyle(
                              fontSize: D.textSM,
                              fontWeight: D.bold,
                              color: AppColors.white,
                            ),
                          ),
                  ),
                ),
                12.gapW,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              requirement.label,
                              style: TextStyle(
                                fontSize: D.textSM,
                                fontWeight: D.semiBold,
                                color: AppColors.black,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (requirement.required) ...[
                            4.gapW,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Required',
                                style: TextStyle(
                                  fontSize: D.textXS,
                                  fontWeight: D.medium,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (requirement.notes != null) ...[
                        4.gapH,
                        Text(
                          requirement.notes!,
                          style: TextStyle(
                            fontSize: D.textXS,
                            color: AppColors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: UploadImage(
              image: uploadedFiles[requirement.id],
              title: isUploaded
                  ? 'Document uploaded'
                  : 'Upload document ${requirement.order}',
              subtitle:
                  isUploaded ? 'Tap to change' : 'Take photo or choose file',
              height: 120.h,
              showActions: true,
              onPickImage: (source) => _pickFile(requirement.id, source),
              onRemove: () =>
                  setState(() => uploadedFiles[requirement.id] = null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: D.textBase,
        fontWeight: D.semiBold,
        fontFamily: 'Segoe UI',
        color: AppColors.black,
      ),
    );
  }

  Widget _buildAttachedBadge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(AppString.attachedBadge),
        12.gapH,
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(D.radiusLG),
            border: Border.all(color: AppColors.grey.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(D.radiusLG),
                child: Image.asset(
                  _getBadgeImage(widget.userBadgeType),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (widget.userBadgeType != null) ...[
                16.gapH,
                Row(
                  children: [
                    Icon(Icons.verified, color: AppColors.primary, size: 20),
                    8.gapH,
                    Expanded(
                      child: Text(
                        widget.userBadgeType!,
                        style: TextStyle(
                          fontSize: D.textSM,
                          fontWeight: D.semiBold,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(AppString.reasonForRequest),
        8.gapH,
        TextInput(
          controller: reasonController,
          hintText: AppString.reasonHint,
          maxLines: 4,
        ),
        4.gapH,
        Text(
          '${reasonController.text.length}/20 ${AppString.charactersMinimum}',
          style: TextStyle(
            fontSize: D.textXS,
            color: AppColors.grey,
            fontFamily: 'Segoe UI',
          ),
        ),
      ],
    );
  }
}