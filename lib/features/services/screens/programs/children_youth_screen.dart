import 'package:flutter/material.dart';
import '../../components/programs_page/program_list_page.dart';
import '../../components/programs_page/sanggawadan_page.dart';

class ChildrenYouthScreen extends StatefulWidget {
  static const routeName = '/children-youth';
  
  const ChildrenYouthScreen({super.key});

  @override
  State<ChildrenYouthScreen> createState() => _ChildrenYouthScreenState();
}

class _ChildrenYouthScreenState extends State<ChildrenYouthScreen> {
  // Programs data
  static const List<Map<String, String>> _programs = [
    {
      'title': 'Sanggawadan',
      'description': 'Community assistance program providing support to families in need',
    },
    {
      'title': 'EduCare',
      'description': 'Educational support program for students and scholars',
    },
    {
      'title': 'Feeding Program',
      'description': 'Nutrition program for children and malnourished individuals',
    },
    {
      'title': 'Pag-Asa',
      'description': 'Livelihood and skills training program for community members',
    },
    {
      'title': 'Yakap Youth',
      'description': 'Youth development and empowerment program',
    },
  ];

  void _handleProgramTap(String programTitle) {
    print('$programTitle tapped');
    
    // Use switch case for navigation
    switch (programTitle) {
      case 'Sanggawadan':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SanggawadanPage(
              userName: 'Maria Santos',
              userAge: '20',
              userSchool: 'Bicol University',
              userGradeLevel: 'University',
            ),
          ),
        );
        break;
        
      case 'EduCare':
        // TODO: Navigate to Educare page
        print('Educare navigation - Coming soon');
        break;
        
      case 'Feeding Program':
        // TODO: Navigate to Feeding Program page
        print('Feeding Program navigation - Coming soon');
        break;
        
      case 'Pag-Asa':
        // TODO: Navigate to Pag-Asa page
        print('Pag-Asa navigation - Coming soon');
        break;
        
      case 'Yakap Youth':
        // TODO: Navigate to Yakap Youth page
        print('Yakap Youth navigation - Coming soon');
        break;
        
      default:
        print('Unknown program: $programTitle');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgramListPage(
      title: 'Children & Youth Welfare',
      subtitle: 'Programs for children and young adults',
      onProgramTap: _handleProgramTap,
      programs: _programs,
    );
  }
}