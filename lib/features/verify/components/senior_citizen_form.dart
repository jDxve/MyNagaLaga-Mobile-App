import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';
import '../../../common/widgets/text_input.dart';
import 'benefits_card.dart';

class SeniorCitizenForm extends StatelessWidget {
  final TextEditingController existingIdController;

  const SeniorCitizenForm({
    super.key,
    required this.existingIdController,
  });

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
          controller: existingIdController,
          hintText: AppString.existingIdHint,
        ),
        16.gapH,
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