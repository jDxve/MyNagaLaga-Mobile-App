import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';
import '../../../common/widgets/text_input.dart';
import 'benefits_card.dart';

class SeniorCitizenForm extends StatefulWidget {
  final TextEditingController existingIdController;
  final Function(bool isValid, VoidCallback showError)? setIsFormValid;

  const SeniorCitizenForm({
    super.key,
    required this.existingIdController,
    this.setIsFormValid,
  });

  @override
  State<SeniorCitizenForm> createState() => _SeniorCitizenFormState();
}

class _SeniorCitizenFormState extends State<SeniorCitizenForm> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.setIsFormValid?.call(true, () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.existingSeniorCitizenId,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: Colors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        8.gapH,
        TextInput(
          controller: widget.existingIdController,
          hintText: AppString.existingIdHint,
        ),
        8.gapH,
        Text(
          AppString.optionalField,
          style: TextStyle(
            fontSize: D.textXS,
            color: AppColors.grey,
            fontFamily: 'Segoe UI',
          ),
        ),
        24.gapH,
        BenefitsCard(
          title: AppString.seniorCitizenBenefitsTitle,
          benefits: [
            AppString.seniorBenefit1,
            AppString.seniorBenefit2,
            AppString.seniorBenefit3,
          ],
          color: AppColors.lightYellow,
        ),
      ],
    );
  }
}