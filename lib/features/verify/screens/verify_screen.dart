import 'dart:io';
import 'package:flutter/material.dart';
import '../../../common/resources/dimensions.dart';
import '../components/basic_info_form.dart';
import '../components/document_form.dart';
import '../components/eligibility_form.dart';
import '../components/previous_next_button.dart';
import '../components/select_badges.dart';
import '../components/top_verify.dart';

class VerifyScreen extends StatefulWidget {
  static const routeName = '/verify';
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  String? _selectedBadge;
  int _currentStep = 1;
  final int _totalSteps = 5;
  bool _isFormValid = false;
  VoidCallback? _validationCallback;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _existingIdController = TextEditingController();
  String? _selectedGender;
  String? _selectedIdType;
  
  // Store document images at parent level
  File? _frontIdImage;
  File? _backIdImage;

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
    // Validate for step 2 (Basic Info) and step 4 (Document Upload)
    if ((_currentStep == 2 || _currentStep == 4) && !_isFormValid) {
      _validationCallback?.call();
      return;
    }

    setState(() {
      if (_currentStep < _totalSteps) {
        _currentStep++;
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
        return BasicInfoForm(
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
        return EligibilityForm(
          context: context,
          selectedBadge: _selectedBadge ?? '',
          existingIdController: _existingIdController,
        );
      case 4:
        return DocumentForm(
          context: context,
          selectedIdType: _selectedIdType,
          frontImage: _frontIdImage,
          backImage: _backIdImage,
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
          setIsFormValid: (isValid, showError) {
            setState(() {
              _isFormValid = isValid;
              _validationCallback = showError;
            });
          },
        );
      case 5:
        return Center(child: Text('Step 5: Review'));
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
            topVerify(currentStep: _currentStep, totalSteps: _totalSteps),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: _buildStepContent(),
              ),
            ),
            if (_currentStep > 1)
              previousNextButton(
                onPrevious: _handlePrevious,
                onNext: _handleNext,
                isDisabled: (_currentStep == 2 || _currentStep == 4) && !_isFormValid,
              ),
          ],
        ),
      ),
    );
  }
}