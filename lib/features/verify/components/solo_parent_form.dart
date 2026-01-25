import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';
import 'benefits_card.dart';

class SoloParentForm extends StatefulWidget {
  final TextEditingController existingIdController;
  final Function(bool isValid, VoidCallback showError)? setIsFormValid;

  const SoloParentForm({
    super.key,
    required this.existingIdController,
    this.setIsFormValid,
  });

  @override
  State<SoloParentForm> createState() => _SoloParentFormState();
}

class _SoloParentFormState extends State<SoloParentForm> {
  int _numberOfDependents = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _validate());
  }

  void _validate() {
    final isValid = _numberOfDependents > 0;
    widget.setIsFormValid?.call(isValid, () {});
  }

  void _incrementDependents() {
    setState(() {
      if (_numberOfDependents < 10) {
        _numberOfDependents++;
        _validate();
      }
    });
  }

  void _decrementDependents() {
    setState(() {
      if (_numberOfDependents > 1) {
        _numberOfDependents--;
        _validate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.numberOfDependents,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: Colors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        16.gapH,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CounterButton(icon: Icons.remove, onPressed: _decrementDependents),
            40.gapW,
            Column(
              children: [
                Text(
                  '$_numberOfDependents',
                  style: TextStyle(
                    fontSize: D.f(40),
                    fontWeight: D.bold,
                    color: AppColors.primary,
                    fontFamily: 'Segoe UI',
                  ),
                ),
                Text(
                  AppString.dependents,
                  style: TextStyle(
                    fontSize: D.textSM,
                    color: AppColors.grey,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ],
            ),
            40.gapW,
            _CounterButton(icon: Icons.add, onPressed: _incrementDependents),
          ],
        ),
        24.gapH,
        BenefitsCard(
          title: AppString.soloParentBenefitsTitle,
          benefits: [
            AppString.soloParentBenefit1,
            AppString.soloParentBenefit2,
            AppString.soloParentBenefit3,
          ],
          color: AppColors.lightPurple,
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CounterButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(D.radiusLG),
          border: Border.all(color: AppColors.grey.withOpacity(0.3), width: 1),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24.w),
      ),
    );
  }
}