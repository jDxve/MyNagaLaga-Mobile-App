import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/utils/ui_utils.dart';
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
  File? _frontIdImage;
  File? _backIdImage;
  File? _supportingFile;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      ref.read(badgeTypesNotifierProvider.notifier).getBadgeTypes()
    );
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
      }
    });
  }

  void _handlePrevious() {
    setState(() {
      if (_currentStep > 1) _currentStep--;
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
      _frontIdImage = null;
      _backIdImage = null;
      _supportingFile = null;
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
                TextButton(
                  onPressed: () => ref.read(badgeTypesNotifierProvider.notifier).getBadgeTypes(),
                  child: const Text('Retry'),
                )
              ],
            ),
          ),
          success: (badges) => badgeSelectionCards(
            context: context,
            badgeTypes: badges,
            onBadgeSelected: (badgeType) => setState(() => _selectedBadge = badgeType),
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
          onDataChanged: (data) {}, // Handle extra data if needed
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
          selectedIdType: _selectedIdType,
          frontImage: _frontIdImage,
          backImage: _backIdImage,
          supportingFile: _supportingFile,
          onIdTypeChanged: (val) => setState(() => _selectedIdType = val),
          onFrontImageChanged: (file) => setState(() => _frontIdImage = file),
          onBackImageChanged: (file) => setState(() => _backIdImage = file),
          onSupportingFileChanged: (file) => setState(() => _supportingFile = file),
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
          frontIdImage: _frontIdImage,
          backIdImage: _backIdImage,
          supportingFile: _supportingFile,
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