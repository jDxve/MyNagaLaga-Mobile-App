import 'package:flutter/material.dart';
import '../../../common/resources/dimensions.dart';
import '../components/slect_badges.dart';
import '../components/top_verify.dart';

class VerifyScreen extends StatefulWidget {
  static const routeName = '/verify';
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  String? _selectedBadge;
  int _currentStep = 1;
  final int _totalSteps = 5;

  @override
  Widget build(BuildContext context) {
    D.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            topVerify(currentStep: _currentStep, totalSteps: _totalSteps),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: badgeSelectionCards(
                  context: context,
                  onBadgeSelected: (badgeId) {
                    setState(() {
                      _selectedBadge = badgeId;
                    });
                  },
                  selectedBadge: _selectedBadge,
                  onNext: () {
                    setState(() {
                      if (_currentStep < _totalSteps) {
                        _currentStep++;
                      }
                    });
                    print('Selected badge: $_selectedBadge');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}