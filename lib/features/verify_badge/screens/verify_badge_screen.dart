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
    if (_currentStep >= 2 && !_isFormValid) {
      _validationCallback?.call();
      return;
    }

    setState(() {
      if ((_isCitizen && _currentStep == 3) || (!_isCitizen && _currentStep == 5)) {
        _submitApplication();
      } else {
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

  void _submitApplication() async {
    if (_selectedBadge == null || _isSubmitting) return;

    final idTypeError = UIUtils.convertIdTypeToApiFormat(_selectedIdType);
    if (idTypeError == 'OTHER' && _selectedIdType != 'Other') {
      showErrorModal(
        context: context,
        title: 'ID Type Required',
        description: 'Please select a valid ID type before submitting.',
        icon: Icons.badge_outlined,
        iconColor: Colors.orange,
        buttonText: AppString.ok,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    await ref.read(badgeRequestNotifierProvider.notifier).submit(
      badgeTypeId: _selectedBadge!.id,
      fullName: _fullNameController.text.trim(),
      birthdate: UIUtils.convertDateToApiFormat(_dateOfBirthController.text),
      gender: UIUtils.convertGenderToApiFormat(_selectedGender),
      homeAddress: _addressController.text.trim(),
      contactNumber: _phoneController.text.trim(),
      typeOfId: UIUtils.convertIdTypeToApiFormat(_selectedIdType),
      existingSeniorCitizenId: _existingIdController.text.isEmpty ? null : _existingIdController.text,
      typeOfDisability: _typeOfDisabilityController.text.isEmpty ? null : _typeOfDisabilityController.text,
      numberOfDependents: int.tryParse(_numberOfDependentsController.text),
      estimatedMonthlyHouseholdIncome: _monthlyIncomeController.text.isEmpty ? null : _monthlyIncomeController.text,
      schoolName: _schoolNameController.text.isEmpty ? null : _schoolNameController.text,
      educationLevel: _educationLevelController.text.isEmpty ? null : _educationLevelController.text,
      yearOrGradeLevel: _yearGradeController.text.isEmpty ? null : _yearGradeController.text,
      schoolIdNumber: _schoolIdController.text.isEmpty ? null : _schoolIdController.text,
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
            _isFormValid = UIUtils.validateFullName(_fullNameController.text) == null &&
                _dateOfBirthController.text.isNotEmpty &&
                UIUtils.validateAddress(_addressController.text) == null &&
                UIUtils.validatePhoneNumber(_phoneController.text) == null;
            _validationCallback = callback;
          }),
        );

      case 3:
        if (_isCitizen) {
          return DocumentPage(
            context: context,
            badgeTypeId: _selectedBadge?.id ?? '',
            selectedIdType: _selectedIdType,
            uploadedFiles: _uploadedFiles,
            onIdTypeChanged: (val) => setState(() => _selectedIdType = val),
            onFilesChanged: (key, files) => setState(() => _uploadedFiles[key] = files),
            setIsFormValid: (isValid, showError) => setState(() {
              _isFormValid = isValid;
              _validationCallback = showError;
            }),
          );
        }
        return EligibilityPage(
          context: context,
          selectedBadge: _selectedBadge?.badgeKey ?? '',
          existingIdController: _existingIdController,
          onDataChanged: (data) {
            _typeOfDisabilityController.text = data['typeOfDisability'] ?? '';
            _numberOfDependentsController.text = (data['numberOfDependents'] ?? '').toString();
            _monthlyIncomeController.text = (data['estimatedMonthlyIncome'] ?? '').toString();
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
            onBackToHome: () => Navigator.of(context).pushNamedAndRemoveUntil(HomeScreen.routeName, (route) => false),
          );
        }
        return DocumentPage(
          context: context,
          badgeTypeId: _selectedBadge?.id ?? '',
          selectedIdType: _selectedIdType,
          uploadedFiles: _uploadedFiles,
          onIdTypeChanged: (val) => setState(() => _selectedIdType = val),
          onFilesChanged: (key, files) => setState(() => _uploadedFiles[key] = files),
          setIsFormValid: (isValid, showError) => setState(() {
            _isFormValid = isValid;
            _validationCallback = showError;
          }),
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
          onBackToHome: () => Navigator.of(context).pushNamedAndRemoveUntil(HomeScreen.routeName, (route) => false),
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
              topVerify(
                currentStep: _currentStep,
                totalSteps: _totalSteps - 1,
              ),
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