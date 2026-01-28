import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';
import '../../../common/utils/ui_utils.dart';
import 'benefits_card.dart';

class IndigentForm extends StatefulWidget {
  final TextEditingController existingIdController;
  final Function(bool isValid, VoidCallback showError)? setIsFormValid;
  final Function(Map<String, dynamic>)? onDataChanged;

  const IndigentForm({
    super.key,
    required this.existingIdController,
    this.setIsFormValid,
    this.onDataChanged,
  });

  @override
  State<IndigentForm> createState() => _IndigentFormState();
}

class _IndigentFormState extends State<IndigentForm> {
  double _monthlyIncome = 8000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _validate());
  }

  void _validate() {
    widget.setIsFormValid?.call(true, () {});
    widget.onDataChanged?.call({'estimatedMonthlyIncome': _monthlyIncome});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.estimatedMonthlyIncome,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: Colors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        16.gapH,
        Column(
          children: [
            Text(
              UIUtils.numberFormat(_monthlyIncome),
              style: TextStyle(
                fontSize: D.f(32),
                fontWeight: D.bold,
                color: AppColors.primary,
                fontFamily: 'Segoe UI',
              ),
            ),
            8.gapH,
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.grey.withOpacity(0.3),
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withOpacity(0.2),
                trackHeight: 4.h,
              ),
              child: Slider(
                value: _monthlyIncome,
                min: 0,
                max: 50000,
                divisions: 100,
                onChanged: (value) {
                  setState(() {
                    _monthlyIncome = value;
                    _validate();
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  UIUtils.numberFormat(0),
                  style: TextStyle(
                    fontSize: D.textSM,
                    color: AppColors.grey,
                    fontFamily: 'Segoe UI',
                  ),
                ),
                Text(
                  UIUtils.numberFormat(50000),
                  style: TextStyle(
                    fontSize: D.textSM,
                    color: AppColors.grey,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ],
            ),
          ],
        ),
        24.gapH,
        BenefitsCard(
          title: AppString.indigentBenefitsTitle,
          benefits: [
            AppString.indigentBenefit1,
            AppString.indigentBenefit2,
            AppString.indigentBenefit3,
          ],
          color: AppColors.lightPrimary,
        ),
      ],
    );
  }
}