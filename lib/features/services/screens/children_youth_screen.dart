// children_youth_screen.dart - Updated to use switch case navigation
import 'package:flutter/material.dart';
import '../components/children_youth_page.dart';
import '../components/sanggawadan_page.dart';

class ChildrenYouthScreen extends StatefulWidget {
  static const routeName = '/children-youth';
  const ChildrenYouthScreen({super.key});

  @override
  State<ChildrenYouthScreen> createState() => _ChildrenYouthScreenState();
}

class _ChildrenYouthScreenState extends State<ChildrenYouthScreen> {
  void _handleProgramTap(String programTitle) {
    print('$programTitle tapped');

    // Use switch case for navigation
    switch (programTitle) {
      case 'SANGGAWADAN':
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
      case 'EDUCARE':
        // TODO: Navigate to Educare page
        print('Educare navigation - Coming soon');
        break;
      case 'Supplemental Feeding Program':
        // TODO: Navigate to Feeding Program page
        print('Feeding Program navigation - Coming soon');
        break;
      case 'Pag-Asa Youth Movement':
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
    return ChildrenYouthPage(onProgramTap: _handleProgramTap);
  }
}
