import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/models/dio/data_state.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../../common/widgets/drop_down.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/secondary_button.dart';
import '../../../../common/widgets/text_input.dart';
import '../../../../common/widgets/upload_image_card.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../auth/notifier/auth_session_notifier.dart';
import '../../models/service_request_model.dart';
import '../../notifier/service_request_notifier.dart';

class ServiceRequestPage extends ConsumerStatefulWidget {
  static const routeName = '/service-request';
  const ServiceRequestPage({super.key});

  @override
  ConsumerState<ServiceRequestPage> createState() => _ServiceRequestPageState();
}

class _ServiceRequestPageState extends ConsumerState<ServiceRequestPage> {
  final _programController = TextEditingController();
  final _reasonController = TextEditingController();
  final _picker = ImagePicker();

  final List<File?> _documents = [null, null, null];

  bool _isSubmitting = false;
  int? _selectedCaseTypeId;

  @override
  void dispose() {
    _programController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, int index) async {
    final XFile? picked = await _picker.pickImage(source: source);
    if (picked == null) return;
    setState(() => _documents[index] = File(picked.path));
  }

  void _removeDocument(int index) => setState(() => _documents[index] = null);

  bool get _hasAllRequiredDocs =>
      _documents.every((doc) => doc != null && doc.path.isNotEmpty);

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccessModal(String requestCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
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
                child: const Icon(Icons.check_circle, size: 50, color: Colors.green),
              ),
              20.gapH,
              Text(
                'Request Submitted!',
                style: TextStyle(
                  fontSize: D.textXL,
                  fontWeight: D.bold,
                  color: AppColors.black,
                ),
              ),
              12.gapH,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(D.radiusMD),
                ),
                child: Text(
                  requestCode,
                  style: TextStyle(
                    fontSize: D.textLG,
                    fontWeight: D.bold,
                    color: AppColors.primary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              12.gapH,
              Text(
                'Your service request has been submitted successfully. We will review your application and notify you of the status.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: D.textSM,
                  color: AppColors.grey,
                  height: 1.5,
                ),
              ),
              24.gapH,
              PrimaryButton(
                text: 'Done',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    final authSession = ref.read(authSessionProvider);

    if (!authSession.isAuthenticated || authSession.userId == null) {
      _showSnackBar('Please log in to request services');
      return;
    }

    if (_selectedCaseTypeId == null) {
      _showSnackBar('Please select a program');
      return;
    }

    if (_reasonController.text.trim().isEmpty) {
      _showSnackBar('Please provide a reason for your request');
      return;
    }

    if (!_hasAllRequiredDocs) {
      _showSnackBar('Please upload all 3 required documents');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      int? barangayId;
      if (authSession.barangayId != null) {
        barangayId = authSession.barangayId is int
            ? authSession.barangayId as int
            : int.tryParse(authSession.barangayId.toString());
      }

      final filePaths = _documents.whereType<File>().map((e) => e.path).toList();

      final request = ServiceRequestModel(
        caseTypeId: _selectedCaseTypeId!,
        description: _reasonController.text.trim(),
        barangayId: barangayId,
        isAnonymous: false,
        isSensitive: false,
        filePaths: filePaths,
      );

      await ref
          .read(submitServiceRequestNotifierProvider.notifier)
          .submitServiceRequest(request);

      if (!mounted) return;

      final state = ref.read(submitServiceRequestNotifierProvider);
      state.whenOrNull(
        success: (response) => _showSuccessModal(response.caseCode),
        error: (error) => _showSnackBar(error ?? 'Failed to submit request'),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authSession = ref.watch(authSessionProvider);
    final caseTypesState = ref.watch(caseTypesNotifierProvider);
    final isLoggedIn = authSession.isAuthenticated && authSession.userId != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Request Service'),
      body: SafeArea(
        child: !isLoggedIn
            ? _buildLoginRequired()
            : caseTypesState.when(
                started: () => const Center(child: CircularProgressIndicator()),
                loading: () => const Center(child: CircularProgressIndicator()),
                success: (caseTypes) => _buildForm(caseTypes),
                error: (error) => _buildError(error),
              ),
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 80, color: AppColors.grey),
            20.gapH,
            Text(
              'Login Required',
              style: TextStyle(
                fontSize: D.textXL,
                fontWeight: D.bold,
                color: AppColors.black,
              ),
            ),
            12.gapH,
            Text(
              'Please log in to request services from welfare programs.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: D.textSM,
                color: AppColors.grey,
                height: 1.5,
              ),
            ),
            32.gapH,
            PrimaryButton(
              text: 'Go to Login',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String? error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            16.gapH,
            Text(
              error ?? 'Failed to load programs',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: D.textSM, color: AppColors.grey),
            ),
            16.gapH,
            SecondaryButton(
              text: 'Retry',
              onPressed: () => ref
                  .read(caseTypesNotifierProvider.notifier)
                  .fetchCaseTypes(forceRefresh: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(List<CaseTypeModel> caseTypes) {
    final programs = caseTypes.map((e) => e.name).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Welfare Program'),
          8.gapH,
          Dropdown(
            controller: _programController,
            hintText: 'Select Program',
            items: programs,
            onChanged: (value) {
              final selected = caseTypes.firstWhere((e) => e.name == value);
              setState(() => _selectedCaseTypeId = selected.id);
            },
          ),
          20.gapH,
          _buildLabel('Reason for Request'),
          8.gapH,
          TextInput(
            controller: _reasonController,
            hintText: 'Please explain why you need this service...',
            maxLines: 6,
          ),
          24.gapH,
          _buildLabel('Upload Documents'),
          4.gapH,
          Text(
            'All 3 documents are required to submit your request.',
            style: TextStyle(fontSize: D.textXS, color: AppColors.grey),
          ),
          16.gapH,
          _buildDocumentSection(title: 'Valid ID', index: 0, uploadTitle: 'Upload Valid ID'),
          20.gapH,
          _buildDocumentSection(
            title: 'Certificate of Indigency',
            index: 1,
            uploadTitle: 'Upload Certificate of Indigency',
          ),
          20.gapH,
          _buildDocumentSection(
            title: 'Proof of Residence',
            index: 2,
            uploadTitle: 'Upload Proof of Residence',
          ),
          28.gapH,
          PrimaryButton(
            text: _isSubmitting ? 'Submitting...' : 'Submit Request',
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? () {} : _handleSubmit,
          ),
          16.gapH,
        ],
      ),
    );
  }

  Widget _buildDocumentSection({
    required String title,
    required int index,
    required String uploadTitle,
  }) {
    final file = _documents[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: D.textSM,
                fontWeight: D.medium,
                color: AppColors.black,
              ),
            ),
            8.gapW,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: file != null
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                file != null ? 'Uploaded' : 'Required',
                style: TextStyle(
                  fontSize: D.textXS,
                  color: file != null ? Colors.green : Colors.red,
                  fontWeight: D.medium,
                ),
              ),
            ),
          ],
        ),
        8.gapH,
        UploadImage(
          image: file,
          title: uploadTitle,
          subtitle: 'Take a photo or upload an image file',
          height: 180.h,
          onRemove: file != null ? () => _removeDocument(index) : null,
          onPickImage: (source) => _pickImage(source, index),
          iconBackgroundColor: AppColors.lightPrimary,
          iconColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: D.textBase,
        fontWeight: D.medium,
        color: AppColors.black,
        fontFamily: 'Segoe UI',
      ),
    );
  }
}