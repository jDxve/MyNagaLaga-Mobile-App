import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/error_modal.dart';
import '../../../common/resources/strings.dart';
import '../../../common/utils/ui_utils.dart';
import '../../home/screens/home_screen.dart';
import '../notifier/badge_types_notifier.dart';
import '../notifier/badge_request_notifier.dart';
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
  bool _isFormValid = false;
  bool _isConsentGiven = false;
  VoidCallback? _validationCallback;
  String? _generatedReferenceNumber;
  bool _isSubmitting = false;

  final _fullNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _existingIdController = TextEditingController();
  final _typeOfDisabilityController = TextEditingController();
  final _numberOfDependentsController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _schoolNameController = TextEditingController();
  final _educationLevelController = TextEditingController();
  final _yearGradeController = TextEditingController();
  final _schoolIdController = TextEditingController();

  String? _selectedGender;
  String? _selectedIdType;
  Map<String, List<File>> _uploadedFiles = {};

  bool get _isCitizen => _selectedBadge?.badgeKey == 'citizen';
  int get _totalSteps => _isCitizen ? 4 : 6;

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
    _typeOfDisabilityController.dispose();
    _numberOfDependentsController.dispose();
    _monthlyIncomeController.dispose();
    _schoolNameController.dispose();
    _educationLevelController.dispose();
    _yearGradeController.dispose();
    _schoolIdController.dispose();
    super.dispose();
  }

  void _handleNext() {
    // Steps >= 2 require valid form before proceeding
    if (_currentStep >= 2 && !_isFormValid) {
      _validationCallback?.call();
      return;
    }

    final isLastContentStep =
        (_isCitizen && _currentStep == _totalSteps - 1) ||
        (!_isCitizen && _currentStep == _totalSteps - 1);

    if (isLastContentStep) {
      _submitApplication();
    } else {
      setState(() {
        _currentStep++;
        // Reset validity for the next page — except step 1
        _isFormValid = false;
      });
    }
  }

  void _handlePrevious() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
        _isFormValid = _currentStep == 1 ? (_selectedBadge != null) : false;
      });
    }
  }

  Future<void> _submitApplication() async {
  if (_selectedBadge == null || _isSubmitting) return;

  // Validate gender
  if (_selectedGender == null || _selectedGender!.isEmpty) {
    showErrorModal(
      context: context,
      title: 'Gender Required',
      description: 'Please select your gender before submitting.',
      icon: Icons.person_outline,
      iconColor: Colors.orange,
      buttonText: AppString.ok,
    );
    return;
  }

  // Validate ID type
  final selectedId = _selectedIdType ?? '';
  if (selectedId.isEmpty) {
    showErrorModal(
      context: context,
      title: AppString.idTypeNotSelectedTitle,
      description: AppString.idTypeNotSelectedDescription,
      icon: Icons.badge_outlined,
      iconColor: Colors.orange,
      buttonText: AppString.ok,
    );
    return;
  }

  // Validate birthdate
  if (_dateOfBirthController.text.isEmpty) {
    showErrorModal(
      context: context,
      title: 'Birthdate Required',
      description: 'Please enter your date of birth.',
      icon: Icons.calendar_today_outlined,
      iconColor: Colors.orange,
      buttonText: AppString.ok,
    );
    return;
  }

  setState(() => _isSubmitting = true);

  // Sanitize income — strip everything except digits
  final cleanIncome = _monthlyIncomeController.text
      .replaceAll(RegExp(r'[^\d]'), '');

  await ref.read(badgeRequestNotifierProvider.notifier).submit(
    badgeTypeId: _selectedBadge!.id,
    fullName: _fullNameController.text.trim(),
    birthdate: UIUtils.convertDateToApiFormat(_dateOfBirthController.text),
    gender: UIUtils.convertGenderToApiFormat(_selectedGender),
    homeAddress: _addressController.text.trim(),
    contactNumber: _phoneController.text.trim(),
    typeOfId: UIUtils.convertIdTypeToApiFormat(_selectedIdType),
    existingSeniorCitizenId:
        _existingIdController.text.trim().isEmpty
            ? null
            : _existingIdController.text.trim(),
    typeOfDisability:
        _typeOfDisabilityController.text.trim().isEmpty
            ? null
            : _typeOfDisabilityController.text.trim(),
    numberOfDependents:
        int.tryParse(_numberOfDependentsController.text.trim()),
    estimatedMonthlyHouseholdIncome:
        cleanIncome.isEmpty ? null : cleanIncome,
    schoolName:
        _schoolNameController.text.trim().isEmpty
            ? null
            : _schoolNameController.text.trim(),
    educationLevel:
        _educationLevelController.text.trim().isEmpty
            ? null
            : _educationLevelController.text.trim(),
    yearOrGradeLevel:
        _yearGradeController.text.trim().isEmpty
            ? null
            : _yearGradeController.text.trim(),
    schoolIdNumber:
        _schoolIdController.text.trim().isEmpty
            ? null
            : _schoolIdController.text.trim(),
    uploadedFiles: _uploadedFiles,
  );
}
  void _resetForm() {
    ref.read(badgeRequestNotifierProvider.notifier).reset();
    setState(() {
      _currentStep = 1;
      _selectedBadge = null;
      _isFormValid = false;
      _isConsentGiven = false;
      _isSubmitting = false;
      _selectedGender = null;
      _selectedIdType = null;
      _uploadedFiles = {};
      _generatedReferenceNumber = null;
    });
    _fullNameController.clear();
    _dateOfBirthController.clear();
    _phoneController.clear();
    _addressController.clear();
    _existingIdController.clear();
    _typeOfDisabilityController.clear();
    _numberOfDependentsController.clear();
    _monthlyIncomeController.clear();
    _schoolNameController.clear();
    _educationLevelController.clear();
    _yearGradeController.clear();
    _schoolIdController.clear();
  }

  Widget _buildDocumentPage() {
    return DocumentPage(
      context: context,
      badgeTypeId: _selectedBadge?.id ?? '',
      selectedIdType: _selectedIdType,
      uploadedFiles: _uploadedFiles,
      onIdTypeChanged: (val) => setState(() => _selectedIdType = val),
      onFilesChanged: (key, files) =>
          setState(() => _uploadedFiles[key] = files),
      setIsFormValid: (isValid, showError) {
        // Use post-frame to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isFormValid = isValid;
              _validationCallback = showError;
            });
          }
        });
      },
    );
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
                  onPressed: () => ref
                      .read(badgeTypesNotifierProvider.notifier)
                      .getBadgeTypes(),
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
                  onBadgeSelected: (badge) => setState(() {
                    _selectedBadge = badge;
                    _isFormValid = true;
                  }),
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
          setIsFormValid: (callback) => setState(() {
            _isFormValid =
                UIUtils.validateFullName(_fullNameController.text) == null &&
                _dateOfBirthController.text.isNotEmpty &&
                UIUtils.validateAddress(_addressController.text) == null &&
                UIUtils.validatePhoneNumber(_phoneController.text) == null;
            _validationCallback = callback;
          }),
        );

      case 3:
        if (_isCitizen) return _buildDocumentPage();
        return EligibilityPage(
          context: context,
          selectedBadge: _selectedBadge?.badgeKey ?? '',
          existingIdController: _existingIdController,
          onDataChanged: (data) {
            _typeOfDisabilityController.text = data['typeOfDisability'] ?? '';
            _numberOfDependentsController.text =
                (data['numberOfDependents'] ?? '').toString();

            // ← FIX: Strip all non-digit characters before storing
            final rawIncome = (data['estimatedMonthlyIncome'] ?? '').toString();
            _monthlyIncomeController.text = rawIncome.replaceAll(
              RegExp(r'[^\d]'),
              '',
            ); // removes ₱, commas, spaces

            _schoolNameController.text = data['schoolName'] ?? '';
            _educationLevelController.text = data['educationLevel'] ?? '';
            _yearGradeController.text = data['yearOrGradeLevel'] ?? '';
            _schoolIdController.text = data['schoolIdNumber'] ?? '';
          },
          setIsFormValid: (isValid, showError) => setState(() {
            _isFormValid = isValid;
            _validationCallback = showError;
          }),
        );

      case 4:
        if (_isCitizen) {
          return applicationSubmitted(
            context: context,
            referenceNumber: _generatedReferenceNumber,
            onStartNewApplication: _resetForm,
            onBackToHome: () => Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(HomeScreen.routeName, (route) => false),
          );
        }
        return _buildDocumentPage();

      case 5:
        return ReviewPage(
          selectedBadge: _selectedBadge?.badgeKey,
          fullName: _fullNameController.text,
          dateOfBirth: _dateOfBirthController.text,
          gender: _selectedGender,
          address: _addressController.text,
          contactNumber: _phoneController.text,
          existingId: _existingIdController.text.isNotEmpty
              ? _existingIdController.text
              : null,
          selectedIdType: _selectedIdType,
          uploadedFiles: _uploadedFiles,
          isConsentGiven: _isConsentGiven,
          onConsentChanged: (value) => setState(() {
            _isConsentGiven = value;
            _isFormValid = value;
          }),
        );

      case 6:
        return applicationSubmitted(
          context: context,
          referenceNumber: _generatedReferenceNumber,
          onStartNewApplication: _resetForm,
          onBackToHome: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(HomeScreen.routeName, (route) => false),
        );

      default:
        return const Center(child: Text('Unknown Step'));
    }
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);

    ref.listen<DataState>(badgeRequestNotifierProvider, (previous, next) {
      if (_isSubmitting) {
        next.when(
          started: () {},
          loading: () {},
          success: (data) => setState(() {
            _generatedReferenceNumber = data.badgeRequestCode;
            _currentStep = _totalSteps;
            _isSubmitting = false;
          }),
          error: (error) {
            setState(() => _isSubmitting = false);
            showErrorModal(
              context: context,
              title: 'Submission Failed',
              description: error ?? 'Failed to submit badge request.',
              icon: Icons.error_outline,
              iconColor: Colors.red,
              buttonText: AppString.ok,
            );
          },
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            if (_currentStep < _totalSteps)
              topVerify(currentStep: _currentStep, totalSteps: _totalSteps - 1),
            Expanded(
              child: _currentStep == _totalSteps
                  ? _buildStepContent()
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(20.w),
                      child: _buildStepContent(),
                    ),
            ),
            if (_currentStep > 1 && _currentStep < _totalSteps)
              _isSubmitting
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    )
                  : previousNextButton(
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
