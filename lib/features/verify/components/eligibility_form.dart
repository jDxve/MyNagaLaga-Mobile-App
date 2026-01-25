import 'package:flutter/material.dart';
import 'senior_citizen_form.dart';
import 'pwd_form.dart';
import 'solo_parent_form.dart';
import 'indigent_form.dart';
import 'student_form.dart';

class EligibilityForm extends StatelessWidget {
  final BuildContext context;
  final String selectedBadge;
  final TextEditingController existingIdController;

  const EligibilityForm({
    super.key,
    required this.context,
    required this.selectedBadge,
    required this.existingIdController,
  });

  @override
  Widget build(BuildContext context) {
    switch (selectedBadge) {
      case 'senior_citizen':
        return SeniorCitizenForm(
          existingIdController: existingIdController,
        );
      case 'pwd':
        return PwdForm(
          existingIdController: existingIdController,
        );
      case 'solo_parent':
        return SoloParentForm(
          existingIdController: existingIdController,
        );
      case 'indigent':
        return IndigentForm(
          existingIdController: existingIdController,
        );
      case 'student':
        return StudentForm(
          existingIdController: existingIdController,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}