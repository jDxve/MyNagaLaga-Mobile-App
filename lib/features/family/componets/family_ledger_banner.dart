import 'package:flutter/material.dart';
import '../../../common/resources/assets.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';

class FamilyLedgerBanner extends StatelessWidget {
  const FamilyLedgerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
  
        Image.asset(
          Assets.familyCard,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        20.gapH,
        // About Section
        Text(
          'About Family Ledger',
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.bold,
            color: AppColors.textlogo,
          ),
        ),
        8.gapH,
        Text(
          'The Family Ledger helps you keep track of your household members, manage family relationships, and maintain an organized record of your family structure. Easily view and update family member information all in one convenient place.',
          style: TextStyle(
            fontSize: D.textSM,
            color: AppColors.grey,
            height: 1.5,
          ),
        ),
        24.gapH,
      ],
    );
  }
}