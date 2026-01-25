import 'dart:io';
import 'package:flutter/material.dart';
import '../../../common/resources/dimensions.dart';
import '../../home/screens/home_screen.dart';
import '../components/application_submitted.dart';
import '../components/basic_info_page.dart';
import '../components/document_page.dart';
import '../components/eligibility_page.dart';
import '../components/previous_next_button.dart';
import '../components/review_page.dart';
import '../components/select_badges.dart';
import '../components/top_verify.dart';

class VerifyBadgeScreen extends StatefulWidget {
  static const routeName = '/verify_badge';
  const VerifyBadgeScreen({super.key});

  @override
  State<VerifyBadgeScreen> createState() => _VerifyScreenBadgeState();
}

class _VerifyScreenBadgeState extends State<VerifyBadgeScreen> {
  String? _selectedBadge;
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
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _existingIdController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if ((_currentStep == 2 || _currentStep == 3 || _currentStep == 4 || _currentStep == 5) &&
        !_isFormValid) {
      _validationCallback?.call();
      return;
    }

    setState(() {
      if (_currentStep < _totalSteps) {
        _currentStep++;
      } else {
        _submitApplication();
      }
    });
  }

  void _handlePrevious() {
    setState(() {
      if (_currentStep > 1) {
        _currentStep--;
      }
    });
  }

  void _submitApplication() {
    print('\n========================================');
    print('APPLICATION SUBMITTED SUCCESSFULLY');
    print('========================================');
    print('Timestamp: ${DateTime.now()}');
    print('');
    print('Selected Badge: ${_selectedBadge ?? "N/A"}');
    print('Full Name: ${_fullNameController.text}');
    print('Date of Birth: ${_dateOfBirthController.text}');
    print('Gender: ${_selectedGender ?? "N/A"}');
    print('Address: ${_addressController.text}');
    print('Contact Number: ${_phoneController.text}');
    print(
      'Existing ID: ${_existingIdController.text.isEmpty ? "None" : _existingIdController.text}',
    );
    print('ID Type: ${_selectedIdType ?? "N/A"}');
    print('Front ID: ${_frontIdImage != null ? _frontIdImage!.path : "N/A"}');
    print('Back ID: ${_backIdImage != null ? _backIdImage!.path : "N/A"}');
    print('Consent Given: $_isConsentGiven');
    print('========================================\n');

    setState(() {
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
      _generatedReferenceNumber = null;
    });
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return badgeSelectionCards(
          context: context,
          onBadgeSelected: (badgeId) {
            setState(() {
              _selectedBadge = badgeId;
            });
          },
          selectedBadge: _selectedBadge,
          onNext: _handleNext,
        );

      case 2:
        return BasicInfoPage(
          context: context,
          fullNameController: _fullNameController,
          dateOfBirthController: _dateOfBirthController,
          selectedGender: _selectedGender,
          onGenderChanged: (gender) {
            setState(() {
              _selectedGender = gender;
            });
          },
          addressController: _addressController,
          phoneController: _phoneController,
          setIsFormValid: (callback) {
            setState(() {
              _isFormValid =
                  _fullNameController.text.trim().isNotEmpty &&
                  _dateOfBirthController.text.trim().isNotEmpty &&
                  _addressController.text.trim().isNotEmpty &&
                  _phoneController.text.trim().isNotEmpty &&
                  _phoneController.text.trim().length >= 10;
              _validationCallback = callback;
            });
          },
        );

      case 3:
        return EligibilityPage(
          context: context,
          selectedBadge: _selectedBadge ?? '',
          existingIdController: _existingIdController,
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
          onIdTypeChanged: (value) {
            setState(() {
              _selectedIdType = value;
            });
          },
          onFrontImageChanged: (file) {
            setState(() {
              _frontIdImage = file;
            });
          },
          onBackImageChanged: (file) {
            setState(() {
              _backIdImage = file;
            });
          },
          onSupportingFileChanged: (file) {
            setState(() {
              _supportingFile = file;
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
          selectedBadge: _selectedBadge,
          fullName: _fullNameController.text,
          dateOfBirth: _dateOfBirthController.text,
          gender: _selectedGender,
          address: _addressController.text,
          contactNumber: _phoneController.text,
          existingId: _existingIdController.text.isNotEmpty
              ? _existingIdController.text
              : null,
          selectedIdType: _selectedIdType,
          frontIdImage: _frontIdImage,
          backIdImage: _backIdImage,
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
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(HomeScreen.routeName, (route) => false);
          },
        );

      default:
        return Center(child: Text('Unknown Step'));
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
              topVerify(currentStep: _currentStep, totalSteps: _totalSteps - 1),
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
                isDisabled:
                    (_currentStep == 2 ||
                        _currentStep == 3 ||
                        _currentStep == 4 ||
                        _currentStep == 5) &&
                    !_isFormValid,
              ),
          ],
        ),
      ),
    );
  }
}