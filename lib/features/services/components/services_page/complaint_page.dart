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
import '../../models/complaint_model.dart';
import '../../notifier/complaint_notifier.dart';
import 'map_location_picker.dart';

class ComplaintPage extends ConsumerStatefulWidget {
  static const routeName = '/complaint';
  const ComplaintPage({super.key});

  @override
  ConsumerState<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends ConsumerState<ComplaintPage> {
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _picker = ImagePicker();

  File? _selectedImage;
  double? _latitude;
  double? _longitude;
  bool _isSubmitting = false;
  bool _isAnonymous = false;
  int? _selectedComplaintTypeId;

  @override
  void dispose() {
    _categoryController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source);
    if (picked == null) return;
    setState(() => _selectedImage = File(picked.path));
  }

  void _removeImage() => setState(() => _selectedImage = null);

  void _openMapPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapLocationPicker(
          onLocationSelected: (address, lat, lng) {
            setState(() {
              _addressController.text = address;
              _latitude = lat;
              _longitude = lng;
            });
          },
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccessModal(String complaintCode) {
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
                'Complaint Submitted!',
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
                  complaintCode,
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
                'Your complaint has been submitted successfully. Please save your complaint code for tracking.',
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

    if (_selectedComplaintTypeId == null) {
      _showSnackBar('Please select a complaint category');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showSnackBar('Please describe your problem');
      return;
    }

    if (_addressController.text.isEmpty) {
      _showSnackBar('Please select a location on map');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authSession = ref.read(authSessionProvider);
      int? complainantMobileUserId;

      if (_isAnonymous) {
        complainantMobileUserId = null;
      } else if (authSession.isAuthenticated && authSession.userId != null) {
        complainantMobileUserId = int.tryParse(authSession.userId!);
      } else {
        _showSnackBar('Please log in or submit anonymously');
        setState(() => _isSubmitting = false);
        return;
      }

      final complaint = ComplaintModel(
        complaintTypeId: _selectedComplaintTypeId!,
        complainantMobileUserId: complainantMobileUserId,
        description: _descriptionController.text.trim(),
        isAnonymous: _isAnonymous,
        isSensitive: false,
        latitude: _latitude,
        longitude: _longitude,
        filePaths: _selectedImage != null ? [_selectedImage!.path] : null,
      );

      final success = await ref
          .read(submitComplaintNotifierProvider.notifier)
          .submitComplaint(complaint);

      if (!mounted) return;

      if (success) {
        final state = ref.read(submitComplaintNotifierProvider);
        state.whenOrNull(success: (data) => _showSuccessModal(data.complaintCode));
      } else {
        final state = ref.read(submitComplaintNotifierProvider);
        final error = state.whenOrNull(error: (e) => e) ?? 'Failed to submit complaint';
        _showSnackBar(error);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final complaintTypesState = ref.watch(complaintTypesNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'File a Complaint'),
      body: SafeArea(
        child: complaintTypesState.when(
          started: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          success: (types) => _buildForm(types),
          error: (error) => _buildError(error),
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
              error ?? 'Failed to load categories',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: D.textSM, color: AppColors.grey),
            ),
            16.gapH,
            SecondaryButton(
              text: 'Retry',
              onPressed: () => ref
                  .read(complaintTypesNotifierProvider.notifier)
                  .fetchComplaintTypes(forceRefresh: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(List<ComplaintTypeModel> complaintTypes) {
    final authSession = ref.watch(authSessionProvider);
    final isLoggedIn = authSession.isAuthenticated && authSession.userId != null;
    final items = complaintTypes.map((t) => t.name).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Complaint Category'),
          8.gapH,
          Dropdown(
            controller: _categoryController,
            hintText: 'Select Category',
            items: items,
            onChanged: (value) {
              final selected = complaintTypes.firstWhere((t) => t.name == value);
              setState(() => _selectedComplaintTypeId = selected.id);
            },
          ),
          20.gapH,
          _buildLabel('Describe Your Problem'),
          8.gapH,
          TextInput(
            controller: _descriptionController,
            hintText: 'Please describe the issue in detail...',
            maxLines: 6,
          ),
          20.gapH,
          _buildLabel('Address / Nearest Landmark'),
          8.gapH,
          GestureDetector(
            onTap: _openMapPicker,
            child: AbsorbPointer(
              child: TextInput(
                controller: _addressController,
                hintText: 'Tap to select location on map',
                suffixIcon: Icon(
                  _latitude != null ? Icons.location_on : Icons.location_on_outlined,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          if (_latitude != null && _longitude != null) ...[
            6.gapH,
            Row(
              children: [
                const Icon(Icons.check_circle, size: 14, color: Colors.green),
                6.gapW,
                Text(
                  'Location selected',
                  style: TextStyle(fontSize: D.textXS, color: Colors.green),
                ),
              ],
            ),
          ],
          20.gapH,
          _buildLabel('Attach Photo (Optional)'),
          8.gapH,
          UploadImage(
            image: _selectedImage,
            title: 'Add Photo',
            subtitle: 'Take a photo or upload an image file',
            height: 180.h,
            onRemove: _selectedImage != null ? _removeImage : null,
            onPickImage: _pickImage,
            iconBackgroundColor: AppColors.lightPrimary,
            iconColor: AppColors.primary,
          ),
          20.gapH,
          if (isLoggedIn) _buildAnonymousToggle() else _buildAnonymousNotice(),
          32.gapH,
          PrimaryButton(
            text: _isSubmitting ? 'Submitting...' : 'Submit Complaint',
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? () {} : _handleSubmit,
          ),
          16.gapH,
        ],
      ),
    );
  }

  Widget _buildAnonymousToggle() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(D.radiusMD),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submit Anonymously',
                    style: TextStyle(
                      fontSize: D.textSM,
                      fontWeight: D.medium,
                      color: AppColors.black,
                    ),
                  ),
                  4.gapH,
                  Text(
                    'Your identity will not be revealed',
                    style: TextStyle(fontSize: D.textXS, color: AppColors.grey),
                  ),
                ],
              ),
            ),
          ),
          Switch(
            value: _isAnonymous,
            onChanged: (value) => setState(() => _isAnonymous = value),
            activeColor: AppColors.primary,
          ),
          12.gapW,
        ],
      ),
    );
  }

  Widget _buildAnonymousNotice() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(D.radiusMD),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: AppColors.primary),
          8.gapW,
          Expanded(
            child: Text(
              'You are not logged in. Your complaint will be submitted anonymously.',
              style: TextStyle(
                fontSize: D.textXS,
                color: AppColors.primary,
                height: 1.4,
              ),
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
        fontWeight: D.medium,
        color: AppColors.black,
        fontFamily: 'Segoe UI',
      ),
    );
  }
}