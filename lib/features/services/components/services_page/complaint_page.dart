// lib/features/services/components/services_page/complaint_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/models/dio/data_state.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../../common/widgets/drop_down.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/text_input.dart';
import '../../../../common/widgets/upload_image_card.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../auth/notifier/auth_session_notifier.dart';
import '../../models/complaint_model.dart';
import '../../notifier/complaint_notifier.dart';
import 'map_location_picker.dart';

class ComplaintPage extends ConsumerStatefulWidget {
  const ComplaintPage({super.key});

  @override
  ConsumerState<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends ConsumerState<ComplaintPage> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  double? _latitude;
  double? _longitude;
  bool _isSubmitting = false;
  bool _isAnonymous = false;

  List<ComplaintTypeModel> _complaintTypes = [];
  int? _selectedComplaintTypeId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(complaintTypesNotifierProvider.notifier).fetchComplaintTypes();
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _openMapPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPicker(
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

  void _showSuccessModal(String complaintCode) {
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
                  child: Icon(
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

    if (_selectedComplaintTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a complaint category')),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your problem')),
      );
      return;
    }

    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on map')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in or submit anonymously'),
          ),
        );
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
        state.when(
          started: () {},
          loading: () {},
          success: (data) {
            _showSuccessModal(data.complaintCode);
          },
          error: (error) {},
        );
      } else {
        final state = ref.read(submitComplaintNotifierProvider);
        final errorMessage = state.when(
          started: () => 'Failed to submit complaint',
          loading: () => 'Failed to submit complaint',
          success: (data) => 'Failed to submit complaint',
          error: (error) => error ?? 'Failed to submit complaint',
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
    ref.listen<DataState<List<ComplaintTypeModel>>>(
      complaintTypesNotifierProvider,
      (previous, next) {
        next.when(
          started: () {},
          loading: () {},
          success: (types) {
            setState(() {
              _complaintTypes = types;
            });
          },
          error: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading complaint types: $error')),
            );
          },
        );
      },
    );

    final complaintTypesState = ref.watch(complaintTypesNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'File a Complaint'),
      body: SafeArea(
        child: complaintTypesState.when(
          started: () => const Center(child: Text('Getting started...')),
          loading: () => const Center(child: CircularProgressIndicator()),
          success: (types) => _buildForm(),
          error: (error) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(complaintTypesNotifierProvider.notifier)
                        .fetchComplaintTypes();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    final authSession = ref.watch(authSessionProvider);
    final isLoggedIn = authSession.isAuthenticated && authSession.userId != null;

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
            items: _complaintTypes.map((type) => type.name).toList(),
            onChanged: (value) {
              final selectedType = _complaintTypes.firstWhere(
                (type) => type.name == value,
              );
              setState(() {
                _selectedComplaintTypeId = selectedType.id;
              });
            },
          ),
          20.gapH,
          _buildLabel('Describe Your Problem'),
          8.gapH,
          TextInput(
            controller: _descriptionController,
            hintText: 'Please describe the issue you\'re experiencing in detail...',
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
                suffixIcon: const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          20.gapH,
          _buildLabel('Upload Image (Optional)'),
          8.gapH,
          UploadImage(
            image: _selectedImage,
            title: 'Add Photo',
            subtitle: 'Tap to take or upload photo',
            height: 180.h,
            onRemove: _removeImage,
            onPickImage: _pickImage,
           // showActions: true,
            iconBackgroundColor: AppColors.lightPrimary,
            iconColor: AppColors.primary,
          ),
          20.gapH,
          
          if (isLoggedIn) ...[
            Row(
              children: [
                Checkbox(
                  value: _isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      _isAnonymous = value ?? false;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                Expanded(
                  child: Text(
                    'Submit anonymously',
                    style: TextStyle(
                      fontSize: D.textSM,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(D.radiusMD),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  8.gapW,
                  Expanded(
                    child: Text(
                      'Your complaint will be submitted anonymously',
                      style: TextStyle(
                        fontSize: D.textXS,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          40.gapH,
          PrimaryButton(
            text: _isSubmitting ? 'Submitting...' : 'Submit Complaint',
            onPressed: _isSubmitting ? () {} : _handleSubmit,
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