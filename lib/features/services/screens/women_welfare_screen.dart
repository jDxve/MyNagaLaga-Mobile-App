import 'package:flutter/material.dart';
import '../components/women_welfare_page.dart';

class WomenWelfareScreen extends StatefulWidget {
  static const routeName = '/women-welfare';

  const WomenWelfareScreen({super.key});

  @override
  State<WomenWelfareScreen> createState() => _WomenWelfareScreenState();
}

class _WomenWelfareScreenState extends State<WomenWelfareScreen> {
  void _handleProgramTap(String programTitle) {
    print('$programTitle tapped');
    
    // Use switch case for navigation
    switch (programTitle) {
      case 'Solo Parent Services':
        // TODO: Navigate to Solo Parent Services page
        print('Solo Parent Services navigation - Coming soon');
        break;
      case 'Sustainable Livelihood (SLP)':
        // TODO: Navigate to Sustainable Livelihood page
        print('Sustainable Livelihood navigation - Coming soon');
        break;
      case 'Violence Against Women Help Desk':
        // TODO: Navigate to Violence Against Women page
        print('Violence Against Women navigation - Coming soon');
        break;
      case 'Pre-natal & Maternal Care':
        // TODO: Navigate to Pre-natal & Maternal Care page
        print('Pre-natal & Maternal Care navigation - Coming soon');
        break;
      default:
        print('Unknown program: $programTitle');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WomenWelfarePage(onProgramTap: _handleProgramTap);
  }
}