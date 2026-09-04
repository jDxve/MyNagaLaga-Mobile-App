import 'package:flutter/material.dart';
import 'package:mynagalaga_mobile_app/common/resources/colors.dart';
import 'package:mynagalaga_mobile_app/common/resources/dimensions.dart';

class FamilyLedgerHeader extends StatelessWidget {
  const FamilyLedgerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.gapH,
        Text(
          'Family Ledger',
          style: TextStyle(
            fontSize: 24.f,
            fontWeight: FontWeight.w700,
            fontFamily: 'Segoe UI',
            color: AppColors.textlogo,
          ),
        ),
        4.gapH,
        Text(
          'View and manage your household members',
          style: TextStyle(
            fontSize: 14.f,
            fontWeight: FontWeight.w400,
            fontFamily: 'Segoe UI',
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }
}
