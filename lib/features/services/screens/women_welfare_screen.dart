import 'package:flutter/material.dart';
import '../components/program_list_page.dart';
import '../components/solo_parent_services_page.dart';

class WomenWelfareScreen extends StatefulWidget {
  static const routeName = '/women-welfare';
  
  const WomenWelfareScreen({super.key});

  @override
  State<WomenWelfareScreen> createState() => _WomenWelfareScreenState();
}

class _WomenWelfareScreenState extends State<WomenWelfareScreen> {
  // Programs data
  static const List<Map<String, String>> _programs = [
    {
      'title': 'Solo Parent Services',
      'description': 'Issuance of Solo Parent ID, booklets, and monthly financial aid for indigents.',
    },
    {
      'title': 'Sustainable Livelihood (SLP)',
      'description': 'Skills training (e.g., weaving, food processing) and capital assistance for mothers.',
    },
    {
      'title': 'Violence Against Women Help Desk',
      'description': 'Legal assistance, counseling, and rescue for victims of domestic violence.',
    },
    {
      'title': 'Pre-natal & Maternal Care',
      'description': 'Medical assistance and check-ups for pregnant and nursing mothers.',
    },
  ];

  void _handleProgramTap(String programTitle) {
    print('$programTitle tapped');
    
    // Use switch case for navigation
    switch (programTitle) {
      case 'Solo Parent Services':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SoloParentServicesPage(
              userName: 'Maria Santos', // TODO: Get from user data
              userAge: '35', // TODO: Get from user data
            ),
          ),
        );
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
    return ProgramListPage(
      title: 'Women Welfare',
      subtitle: 'Support for mothers, solo parents, and women in difficult circumstances.',
      onProgramTap: _handleProgramTap,
      programs: _programs,
    );
  }
}