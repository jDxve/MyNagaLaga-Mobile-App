import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';
import '../../../common/widgets/drop_down.dart';
import '../../../common/widgets/error_modal.dart';
import 'benefits_card.dart';

class PwdForm extends StatefulWidget {
  final TextEditingController existingIdController;
  final Function(bool isValid, VoidCallback showError)? setIsFormValid;
  final Function(Map<String, dynamic>)? onDataChanged;

  const PwdForm({
    super.key,
    required this.existingIdController,
    this.setIsFormValid,
    this.onDataChanged,
  });

  @override
  State<PwdForm> createState() => _PwdFormState();
}

class _PwdFormState extends State<PwdForm> {
  final TextEditingController _disabilityTypeController = TextEditingController();
  
  // Display labels (with spaces - user-friendly)
  final List<String> disabilityTypes = [
    'Visual Impairment',
    'Hearing Impairment',
    'Speech Impairment',
    'Physical Disability',
    'Mental Disability',
    'Intellectual Disability',
    'Psychosocial Disability',
    'Multiple Disabilities',
  ];

  // Map display labels to backend values (with underscores)
  String _convertToBackendFormat(String displayValue) {
    return displayValue.replaceAll(' ', '_');
  }

  @override
  void initState() {
    super.initState();
    _disabilityTypeController.addListener(_validate);
    WidgetsBinding.instance.addPostFrameCallback((_) => _validate());
  }

  void _validate() {
    final isValid = _disabilityTypeController.text.isNotEmpty;
    
    // Convert to backend format before sending
    final backendValue = _disabilityTypeController.text.isNotEmpty
        ? _convertToBackendFormat(_disabilityTypeController.text)
        : '';
    
    widget.setIsFormValid?.call(isValid, _showError);
    widget.onDataChanged?.call({'typeOfDisability': backendValue});
  }

  void _showError() {
    showErrorModal(
      context: context,
      title: "Required Information Missing",
      description: "Please select a type of disability.",
      icon: Icons.accessible_forward_outlined,
      iconColor: AppColors.primary,
    );
  }

  @override
  void dispose() {
    _disabilityTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.typeOfDisability,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: Colors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        8.gapH,
        Dropdown(
          controller: _disabilityTypeController,
          hintText: AppString.selectDisabilityType,
          items: disabilityTypes, // Display with spaces
        ),
        24.gapH,
        BenefitsCard(
          title: AppString.pwdBenefitsTitle,
          benefits: [
            AppString.pwdBenefit1,
            AppString.pwdBenefit2,
            AppString.pwdBenefit3,
          ],
          color: AppColors.lightPink,
        ),
      ],
    );
  }
} 