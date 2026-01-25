import 'package:flutter/material.dart';
import '../../../common/widgets/background_gradient.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/nav_bar.dart';
import '../../../common/widgets/search_input.dart';

import '../components/badges.dart';
import '../components/circular_notif.dart';
import '../components/home_greetings.dart';
import '../components/quik_actions.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeTab(),
    const Center(child: Text('Family')),
    const Center(child: Text('Services')),
    const Center(child: Text('Safety')),
    const Center(child: Text('Account')),
  ];

  @override
  Widget build(BuildContext context) {
    D.init(context);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return gradientBackground(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 32.w, top: 24.h),
              child: greetingText(userName: 'John Dave Bañas'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
              child: Row(
                children: [
                  Expanded(child: searchInput()),
                  12.gapW,
                  circularNotif(notificationCount: 0),
                ],
              ),
            ),
            12.gapH,
            const BadgeDisplay(
              badges: [BadgeType.student, BadgeType.soloParent, BadgeType.pwd],
            ),
            10.gapH,
            quickActions(),
          ],
        ),
      ),
    );
  }
}
