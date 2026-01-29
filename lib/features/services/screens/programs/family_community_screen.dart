import 'package:flutter/material.dart';
import '../../components/programs_page/program_list_page.dart';
import '../../components/programs_page/senior_citizen_services_page.dart';

class FamilyCommunityScreen extends StatefulWidget {
  static const routeName = '/family-community';

  const FamilyCommunityScreen({super.key});

  @override
  State<FamilyCommunityScreen> createState() => _FamilyCommunityScreenState();
}

class _FamilyCommunityScreenState extends State<FamilyCommunityScreen> {
  // Programs data - matching the screenshot
  static const List<Map<String, String>> _programs = [
    {
      'title': 'Pre-Marriage Counseling',
      'description':
          'Mandatory counseling session for couples applying for a marriage license.',
    },
    {
      'title': 'Senior Citizen Services',
      'description':
          'OSCA ID issuance and release of Social Pension for indigent seniors.',
    },
    {
      'title': 'ERPAT (Fathers)',
      'description':
          'Empowerment and Reaffirmation of Paternal Abilities training for fathers.',
    },
    {
      'title': 'Parent Effectiveness (PES)',
      'description':
          'Seminars on parenting, child development, and family values.',
    },
  ];

  void _handleProgramTap(String programTitle) {
    print('$programTitle tapped');

    // Use switch case for navigation
    switch (programTitle) {
      case 'Pre-Marriage Counseling':
        // TODO: Navigate to Pre-Marriage Counseling page
        print('Pre-Marriage Counseling navigation - Coming soon');
        break;

      case 'Senior Citizen Services':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SeniorCitizenServicesPage(
              userName: 'Maria Santos', // TODO: Get from user data
              userAge: '35', // TODO: Get from user data
            ),
          ),
        );
        break;

      case 'ERPAT (Fathers)':
        // TODO: Navigate to ERPAT page
        print('ERPAT navigation - Coming soon');
        break;

      case 'Parent Effectiveness (PES)':
        // TODO: Navigate to Parent Effectiveness page
        print('Parent Effectiveness navigation - Coming soon');
        break;

      default:
        print('Unknown program: $programTitle');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgramListPage(
      title: 'Family & Community Welfare',
      subtitle: 'Strengthening family bonds and supporting vulnerable adults.',
      onProgramTap: _handleProgramTap,
      programs: _programs,
    );
  }
}
