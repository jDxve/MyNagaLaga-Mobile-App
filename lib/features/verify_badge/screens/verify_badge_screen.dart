import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/resources/dimensions.dart';
import '../../home/screens/home_screen.dart';
import '../notifier/badge_types_notifier.dart';
import '../components/application_submitted.dart';
import '../components/basic_info_page.dart';
import '../components/document_page.dart';
import '../components/eligibility_page.dart';
import '../components/previous_next_button.dart';
import '../components/review_page.dart';
import '../components/select_badges.dart';
import '../components/top_verify.dart';
import '../models/badge_type_model.dart';

class VerifyBadgeScreen extends ConsumerStatefulWidget {
  static const routeName = '/verify_badge';
  const VerifyBadgeScreen({super.key});

  @override
  ConsumerState<VerifyBadgeScreen> createState() => _VerifyScreenBadgeState();
}

class _VerifyScreenBadgeState extends ConsumerState<VerifyBadgeScreen> {
  BadgeType? _selectedBadge;
  int _currentStep = 1;
  final int _totalSteps = 6;
  bool _isFormValid = false;
  bool _isConsentGiven = false;
  VoidCallback? _validationCallback;
  String? _generatedReferenceNumber;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _existingIdController = TextEditingController();

  String? _selectedGender;
  String? _selectedIdType;
  Map<String, List<File>> _uploadedFiles = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(badgeTypesNotifierProvider.notifier).getBadgeTypes();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _existingIdController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_currentStep >= 2 && _currentStep <= 5 && !_isFormValid) {
      _validationCallback?.call();
      return;
    }

    setState(() {
      if (_currentStep == 5) {
        _submitApplication();
      } else if (_currentStep < _totalSteps) {
        _currentStep++;
        _isFormValid = false;
      }
    });
  }

  void _handlePrevious() {
    setState(() {
      if (_currentStep > 1) {
        _currentStep--;
        _isFormValid = _currentStep == 1 ? (_selectedBadge != null) : false;
      }
    });
  }

  void _submitApplication() {
    final referenceNumber = 'REF-${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _generatedReferenceNumber = referenceNumber;
      _currentStep = 6;
    });
  }

  void _resetForm() {
    setState(() {
      _currentStep = 1;
      _selectedBadge = null;
      _isFormValid = false;
      _isConsentGiven = false;
      _fullNameController.clear();
      _dateOfBirthController.clear();
      _phoneController.clear();
      _addressController.clear();
      _existingIdController.clear();
      _selectedGender = null;
      _selectedIdType = null;
      _uploadedFiles = {};
      _generatedReferenceNumber = null;
    });
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        final badgeState = ref.watch(badgeTypesNotifierProvider);
        return badgeState.when(
          started: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(error ?? 'An error occurred'),
                16.gapH,
                TextButton(
                  onPressed: () => ref.read(badgeTypesNotifierProvider.notifier).getBadgeTypes(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          success: (badges) => badges.isEmpty
              ? const Center(child: Text('No badges available'))
              : badgeSelectionCards(
                  context: context,
                  badgeTypes: badges,
                  onBadgeSelected: (badgeType) {
                    setState(() {
                      _selectedBadge = badgeType;
                      _isFormValid = true;
                    });
                  },
                  selectedBadge: _selectedBadge,
                  onNext: _handleNext,
                ),
        );

      case 2:
        return BasicInfoPage(
          context: context,
          fullNameController: _fullNameController,
          dateOfBirthController: _dateOfBirthController,
          selectedGender: _selectedGender,
          onGenderChanged: (gender) => setState(() => _selectedGender = gender),
          addressController: _addressController,
          phoneController: _phoneController,
          setIsFormValid: (callback) {
            setState(() {
              _isFormValid = _fullNameController.text.isNotEmpty &&
                  _dateOfBirthController.text.isNotEmpty &&
                  _addressController.text.isNotEmpty &&
                  _phoneController.text.length >= 10;
              _validationCallback = callback;
            });
          },
        );

      case 3:
        return EligibilityPage(
          context: context,
          selectedBadge: _selectedBadge?.badgeKey ?? '',
          existingIdController: _existingIdController,
          onDataChanged: (data) {},
          setIsFormValid: (isValid, showError) {
            setState(() {
              _isFormValid = isValid;
              _validationCallback = showError;
            });
          },
        );

      case 4:
        return DocumentPage(
          context: context,
          badgeTypeId: _selectedBadge?.id ?? '',
          selectedIdType: _selectedIdType,
          uploadedFiles: _uploadedFiles,
          onIdTypeChanged: (val) => setState(() => _selectedIdType = val),
          onFilesChanged: (key, files) {
            setState(() {
              _uploadedFiles[key] = files;
            });
          },
          setIsFormValid: (isValid, showError) {
            setState(() {
              _isFormValid = isValid;
              _validationCallback = showError;
            });
          },
        );

      case 5:
        return ReviewPage(
          selectedBadge: _selectedBadge?.badgeKey,
          fullName: _fullNameController.text,
          dateOfBirth: _dateOfBirthController.text,
          gender: _selectedGender,
          address: _addressController.text,
          contactNumber: _phoneController.text,
          existingId: _existingIdController.text.isNotEmpty ? _existingIdController.text : null,
          selectedIdType: _selectedIdType,
          uploadedFiles: _uploadedFiles,
          isConsentGiven: _isConsentGiven,
          onConsentChanged: (value) {
            setState(() {
              _isConsentGiven = value;
              _isFormValid = value;
            });
          },
        );

      case 6:
        return applicationSubmitted(
          context: context,
          referenceNumber: _generatedReferenceNumber,
          onStartNewApplication: _resetForm,
          onBackToHome: () {
            Navigator.of(context).pushNamedAndRemoveUntil(HomeScreen.routeName, (route) => false);
          },
        );

      default:
        return const Center(child: Text('Unknown Step'));
    }
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            if (_currentStep < 6)
              topVerify(
                currentStep: _currentStep,
                totalSteps: _totalSteps - 1,
              ),
            Expanded(
              child: _currentStep == 6
                  ? _buildStepContent()
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(20.w),
                      child: _buildStepContent(),
                    ),
            ),
            if (_currentStep > 1 && _currentStep < 6)
              previousNextButton(
                onPrevious: _handlePrevious,
                onNext: _handleNext,
                isDisabled: !_isFormValid,
              ),
          ],
        ),
      ),
    );
  }
}