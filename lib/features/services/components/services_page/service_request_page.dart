// lib/features/services/components/services_page/service_request_page.dart

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
import '../../models/service_request_model.dart';
import '../../notifier/service_request_notifier.dart';

class ServiceRequestPage extends ConsumerStatefulWidget {
  static const routeName = '/service-request';
  const ServiceRequestPage({super.key});

  @override
  ConsumerState<ServiceRequestPage> createState() =>
      _ServiceRequestPageState();
}

class _ServiceRequestPageState extends ConsumerState<ServiceRequestPage> {
  final TextEditingController _programController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<File> _uploadedDocuments = [];
  bool _isSubmitting = false;
  static const int maxDocuments = 3;

  // Maps to store case types data from backend
  Map<String, dynamic> _programToCaseTypeId = {};  // ✅ Changed to dynamic to handle both int and String
  List<String> _programs = [];

  String? _selectedProgram;

  @override
  void initState() {
    super.initState();
    // Fetch case types from backend
    Future.microtask(() {
      ref.read(caseTypesNotifierProvider.notifier).fetchCaseTypes();
    });
  }

  @override
  void dispose() {
    _programController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, int slotIndex) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        // Ensure the list is large enough
        while (_uploadedDocuments.length <= slotIndex) {
          _uploadedDocuments.add(File(''));
        }
        // Replace or add the file at the specific index
        _uploadedDocuments[slotIndex] = File(pickedFile.path);
      });
    }
  }

  void _removeDocument(int index) {
    setState(() {
      if (index < _uploadedDocuments.length) {
        _uploadedDocuments[index] =
            File(''); // Mark as empty instead of removing
      }
    });
  }

  void _showSuccessModal(String requestCode) {
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
                  'Request Submitted!',
                  style: TextStyle(
                    fontSize: D.textXL,
                    fontWeight: D.bold,
                    color: AppColors.black,
                  ),
                ),
                12.gapH,
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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

    final authSession = ref.read(authSessionProvider);
    if (!authSession.isAuthenticated || authSession.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to request services')),
      );
      return;
    }

    if (_selectedProgram == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a program')),
      );
      return;
    }

    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason for your request')),
      );
      return;
    }

    if (_uploadedDocuments.isEmpty ||
        _uploadedDocuments.length < 3 ||
        _uploadedDocuments.any((doc) => doc.path.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all 3 required documents')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Get the case type ID for the selected program
      final caseTypeIdValue = _programToCaseTypeId[_selectedProgram];
      if (caseTypeIdValue == null) {
        throw Exception('Invalid program selected');
      }

      // ✅ Convert to int regardless of backend type
      final caseTypeId = caseTypeIdValue is int 
          ? caseTypeIdValue 
          : int.parse(caseTypeIdValue.toString());

      // Filter out empty documents and get their paths
      final validFilePaths = _uploadedDocuments
          .where((doc) => doc.path.isNotEmpty)
          .map((doc) => doc.path)
          .toList();

      // ✅ Parse barangayId properly
      int? barangayId;
      if (authSession.barangayId != null) {
        barangayId = authSession.barangayId is int
            ? authSession.barangayId as int
            : int.tryParse(authSession.barangayId.toString());
      }

      // Create request model
      final request = ServiceRequestModel(
        caseTypeId: caseTypeId,
        description: _reasonController.text.trim(),
        barangayId: barangayId,
        isAnonymous: false,
        isSensitive: false,
        filePaths: validFilePaths,
      );

      // Submit request
      final success = await ref
          .read(submitServiceRequestNotifierProvider.notifier)
          .submitServiceRequest(request);

      if (!mounted) return;

      if (success) {
        // Get the response data
        final state = ref.read(submitServiceRequestNotifierProvider);
        state.when(
          started: () {},
          loading: () {},
          success: (response) {
            _showSuccessModal(response.caseCode);
          },
          error: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $error')),
            );
          },
        );
      } else {
        final state = ref.read(submitServiceRequestNotifierProvider);
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
    final authSession = ref.watch(authSessionProvider);
    final isLoggedIn =
        authSession.isAuthenticated && authSession.userId != null;

    // Listen to case types provider
    ref.listen<DataState<List<CaseTypeModel>>>(
      caseTypesNotifierProvider,
      (previous, next) {
        next.when(
          started: () {},
          loading: () {},
          success: (caseTypes) {
            setState(() {
              _programs = caseTypes.map((ct) => ct.name).toList();
              // ✅ Store the id as-is (whether it's int or String)
              _programToCaseTypeId = {
                for (var ct in caseTypes) ct.name: ct.id
              };
              
              debugPrint('📋 Loaded ${caseTypes.length} case types');
              debugPrint('📋 Sample: ${caseTypes.first.name} -> ${caseTypes.first.id} (${caseTypes.first.id.runtimeType})');
            });
          },
          error: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading programs: $error')),
            );
          },
        );
      },
    );

    final caseTypesState = ref.watch(caseTypesNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Request Service'),
      body: SafeArea(
        child: !isLoggedIn
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.login,
                        size: 80,
                        color: AppColors.grey,
                      ),
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
                        onPressed: () {
                          // TODO: Navigate to login
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              )
            : caseTypesState.when(
                started: () => const Center(child: Text('Initializing...')),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                success: (caseTypes) => _buildForm(),
                error: (error) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(caseTypesNotifierProvider.notifier)
                              .fetchCaseTypes();
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
            items: _programs,
            onChanged: (value) {
              setState(() {
                _selectedProgram = value;
              });
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
          20.gapH,
          _buildLabel('Upload Documents'),
          8.gapH,

          // Document 1: Valid ID
          Row(
            children: [
              Text(
                'Valid ID',
                style: TextStyle(
                  fontSize: D.textSM,
                  fontWeight: D.medium,
                  color: AppColors.black,
                ),
              ),
              8.gapW,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Required',
                  style: TextStyle(
                    fontSize: D.textXS,
                    color: Colors.red,
                    fontWeight: D.medium,
                  ),
                ),
              ),
            ],
          ),
          8.gapH,
          UploadImage(
            image: (_uploadedDocuments.length > 0 &&
                    _uploadedDocuments[0].path.isNotEmpty)
                ? _uploadedDocuments[0]
                : null,
            title: 'Upload Valid ID',
            subtitle: 'Take a photo or upload an image file',
            height: 180.h,
            onRemove: (_uploadedDocuments.length > 0 &&
                    _uploadedDocuments[0].path.isNotEmpty)
                ? () => _removeDocument(0)
                : null,
            onPickImage: (source) => _pickImage(source, 0),
            showActions: true,
            iconBackgroundColor: AppColors.lightPrimary,
            iconColor: AppColors.primary,
          ),
          20.gapH,

          // Document 2: Certificate of Indigency
          Row(
            children: [
              Text(
                'Certificate of Indigency',
                style: TextStyle(
                  fontSize: D.textSM,
                  fontWeight: D.medium,
                  color: AppColors.black,
                ),
              ),
              8.gapW,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Required',
                  style: TextStyle(
                    fontSize: D.textXS,
                    color: Colors.red,
                    fontWeight: D.medium,
                  ),
                ),
              ),
            ],
          ),
          8.gapH,
          UploadImage(
            image: (_uploadedDocuments.length > 1 &&
                    _uploadedDocuments[1].path.isNotEmpty)
                ? _uploadedDocuments[1]
                : null,
            title: 'Upload Certificate of Indigency',
            subtitle: 'Take a photo or upload an image file',
            height: 180.h,
            onRemove: (_uploadedDocuments.length > 1 &&
                    _uploadedDocuments[1].path.isNotEmpty)
                ? () => _removeDocument(1)
                : null,
            onPickImage: (source) => _pickImage(source, 1),
            showActions: true,
            iconBackgroundColor: AppColors.lightPrimary,
            iconColor: AppColors.primary,
          ),
          20.gapH,

          // Document 3: Proof of Residence
          Row(
            children: [
              Text(
                'Proof of Residence',
                style: TextStyle(
                  fontSize: D.textSM,
                  fontWeight: D.medium,
                  color: AppColors.black,
                ),
              ),
              8.gapW,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Required',
                  style: TextStyle(
                    fontSize: D.textXS,
                    color: Colors.red,
                    fontWeight: D.medium,
                  ),
                ),
              ),
            ],
          ),
          8.gapH,
          UploadImage(
            image: (_uploadedDocuments.length > 2 &&
                    _uploadedDocuments[2].path.isNotEmpty)
                ? _uploadedDocuments[2]
                : null,
            title: 'Upload Proof of Residence',
            subtitle: 'Take a photo or upload an image file',
            height: 180.h,
            onRemove: (_uploadedDocuments.length > 2 &&
                    _uploadedDocuments[2].path.isNotEmpty)
                ? () => _removeDocument(2)
                : null,
            onPickImage: (source) => _pickImage(source, 2),
            showActions: true,
            iconBackgroundColor: AppColors.lightPrimary,
            iconColor: AppColors.primary,
          ),
          20.gapH,
          PrimaryButton(
            text: _isSubmitting ? 'Submitting...' : 'Submit Request',
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