import 'package:flutter/material.dart';
import '../components/medical_assistance_page.dart';
import '../components/program_list_page.dart';

class CrisisInterventionScreen extends StatefulWidget {
  static const routeName = '/crisis-intervention';

  const CrisisInterventionScreen({super.key});

  @override
  State<CrisisInterventionScreen> createState() =>
      _CrisisInterventionScreenState();
}

class _CrisisInterventionScreenState extends State<CrisisInterventionScreen> {
  // Programs data
  static const List<Map<String, String>> _programs = [
    {
      'title': 'Medical Assistance',
      'description':
          'Financial aid for hospital bills, laboratories, dialysis, and medicines.',
    },
    {
      'title': 'Burial Assistance',
      'description':
          'Cash assistance for funeral and interment expenses of indigent residents.',
    },
    {
      'title': 'Calamity Assistance',
      'description':
          'Financial aid for victims of fire or natural disasters to rebuild homes.',
    },
    {
      'title': 'Rescue & Referral',
      'description':
          'Immediate extraction and safe shelter for abandoned or abused individuals.',
    },
  ];

  void _handleProgramTap(String programTitle) {
    print('$programTitle tapped');

    // Use switch case for navigation
    switch (programTitle) {
      case 'Medical Assistance':
                Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MedicalAssistancePage(
              userName: 'Maria Santos', // TODO: Get from user data
              userAge: '35', // TODO: Get from user data
            ),
          ),
        );
       
        break;

      case 'Burial Assistance':
        // TODO: Navigate to Burial Assistance page
        print('Burial Assistance navigation - Coming soon');
        break;

      case 'Calamity Assistance':
        // TODO: Navigate to Calamity Assistance page
        print('Calamity Assistance navigation - Coming soon');
        break;

      case 'Rescue & Referral':
        // TODO: Navigate to Rescue & Referral page
        print('Rescue & Referral navigation - Coming soon');
        break;

      default:
        print('Unknown program: $programTitle');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgramListPage(
      title: 'Crisis Intervention Program (AICS)',
      subtitle:
          'Immediate financial or material help for individuals in crisis.',
      onProgramTap: _handleProgramTap,
      programs: _programs,
    );
  }
}
