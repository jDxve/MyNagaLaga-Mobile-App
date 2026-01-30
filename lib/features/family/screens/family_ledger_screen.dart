import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/primary_button.dart';
import '../componets/family_ledger_banner.dart';
import '../componets/family_tree_page.dart';

class FamilyLedgerScreen extends StatefulWidget {
  static const String routeName = '/family-ledger';
  
  const FamilyLedgerScreen({super.key});

  @override
  State<FamilyLedgerScreen> createState() => _FamilyLedgerScreenState();
}

class _FamilyLedgerScreenState extends State<FamilyLedgerScreen> {
  void _navigateToFamilyTree() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FamilyTreePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              // Banner and Info Section
              const FamilyLedgerBanner(),

              // Add Family Member Button
              PrimaryButton(
                text: 'Add Family Member',
                onPressed: _navigateToFamilyTree,
              ),
              
              24.gapH,
            ],
          ),
        ),
      ),
    );
  }
}