import 'package:flutter/material.dart';
import 'package:mynagalaga_mobile_app/features/verify_badge/components/senior_citizen_form.dart';
import 'package:mynagalaga_mobile_app/features/verify_badge/components/pwd_form.dart';
import 'package:mynagalaga_mobile_app/features/verify_badge/components/solo_parent_form.dart';
import 'package:mynagalaga_mobile_app/features/verify_badge/components/indigent_form.dart';
import 'package:mynagalaga_mobile_app/features/verify_badge/components/student_form.dart';

class EligibilityPage extends StatelessWidget {
  final BuildContext context;
  final String selectedBadge;
  final TextEditingController existingIdController;
  final Function(bool isValid, VoidCallback showError)? setIsFormValid;
  final Function(Map<String, dynamic>)? onDataChanged;

  const EligibilityPage({
    super.key,
    required this.context,
    required this.selectedBadge,
    required this.existingIdController,
    this.setIsFormValid,
    this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (selectedBadge) {
      case 'senior_citizen':
        return SeniorCitizenForm(
          existingIdController: existingIdController,
          setIsFormValid: setIsFormValid,
        );
      case 'pwd':
        return PwdForm(
          existingIdController: existingIdController,
          setIsFormValid: setIsFormValid,
          onDataChanged: onDataChanged,
        );
      case 'solo_parent':
        return SoloParentForm(
          existingIdController: existingIdController,
          setIsFormValid: setIsFormValid,
          onDataChanged: onDataChanged,
        );
      case 'indigent':
        return IndigentForm(
          existingIdController: existingIdController,
          setIsFormValid: setIsFormValid,
          onDataChanged: onDataChanged,
        );
      case 'student':
        return StudentForm(
          existingIdController: existingIdController,
          setIsFormValid: setIsFormValid,
          onDataChanged: onDataChanged,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}