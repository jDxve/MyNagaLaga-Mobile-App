import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';

class Toggle extends StatelessWidget {
  final String? selectedValue;
  final Function(String?) onChanged;
  final String firstLabel;
  final String secondLabel;
  final String firstValue;
  final String secondValue;

  const Toggle({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    required this.firstLabel,
    required this.secondLabel,
    required this.firstValue,
    required this.secondValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.h,
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(D.radiusLG),
        border: Border.all(
          color: AppColors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              label: firstLabel,
              isSelected: selectedValue == firstValue,
              onTap: () => onChanged(firstValue),
            ),
          ),
          4.gapW,
          Expanded(
            child: _ToggleOption(
              label: secondLabel,
              isSelected: selectedValue == secondValue,
              onTap: () => onChanged(secondValue),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(D.radiusMD),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: D.textBase,
              fontWeight: D.semiBold,
              color: isSelected ? Colors.white : Colors.black,
              fontFamily: 'Segoe UI',
            ),
          ),
        ),
      ),
    );
  }
}