import 'package:flutter/material.dart';
import 'package:mynagalaga_mobile_app/features/services/components/programs_page/evacuation_center_page.dart';
import '../../components/programs_page/program_list_page.dart';

class DisasterResponseScreen extends StatefulWidget {
  static const routeName = '/disaster-response';
  
  const DisasterResponseScreen({super.key});

  @override
  State<DisasterResponseScreen> createState() => _DisasterResponseScreenState();
}

class _DisasterResponseScreenState extends State<DisasterResponseScreen> {
  // Programs data - matching the screenshot
  static const List<Map<String, String>> _programs = [
    {
      'title': 'Evacuation Center',
      'description': 'Registration and management of families staying in designated shelters.',
    },
    {
      'title': 'Relief Distribution',
      'description': 'Scheduling and distribution of food packs to affected households.',
    },
    {
      'title': 'Balik-Probinsya',
      'description': 'Transport assistance for stranded individuals returning to their provinces.',
    },
  ];

  void _handleProgramTap(String programTitle) {
    print('$programTitle tapped');
    
    // Use switch case for navigation
    switch (programTitle) {
      case 'Evacuation Center':
         Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EvacuationCenterPage(
              userName: 'Maria Santos', // TODO: Get from user data
              userAge: '35', // TODO: Get from user data
            ),
          ),
        );
        break;
        
      case 'Relief Distribution':
        // TODO: Navigate to Relief Distribution page
        print('Relief Distribution navigation - Coming soon');
        break;
        
      case 'Balik-Probinsya':
        // TODO: Navigate to Balik-Probinsya page
        print('Balik-Probinsya navigation - Coming soon');
        break;
        
      default:
        print('Unknown program: $programTitle');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgramListPage(
      title: 'Disaster Response',
      subtitle: 'Management of safety and relief during typhoons or emergencies.',
      onProgramTap: _handleProgramTap,
      programs: _programs,
    );
  }
}