// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/widgets/background_gradient.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/nav_bar.dart';
import '../../../common/widgets/search_input.dart';
import '../../account/screens/account_screen.dart';
import '../../auth/notifier/auth_session_notifier.dart';
import '../../family/screens/family_ledger_screen.dart';
import '../../safety/screens/disaster_resilience_screen.dart';
import '../../services/components/track_case/all_track.dart';
import '../../services/screens/services_screen.dart';

import '../components/badges.dart';
import '../components/circular_notif.dart';
import '../components/home_greetings.dart';
import '../components/quik_actions.dart';
import '../notifier/user_badge_notifier.dart';

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
    const FamilyLedgerScreen(),
    const ServicesScreen(),
    const DisasterResilienceScreen(),
    const AccountScreen(),
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

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final badgesState = ref.watch(badgesNotifierProvider);

    ref.listen(authSessionProvider, (previous, next) {
      if (next.isAuthenticated && next.userId != null) {
        ref.read(badgesNotifierProvider.notifier).fetchBadges(
              mobileUserId: next.userId!,
            );
      }
    });

    return gradientBackground(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 32.w, top: 24.h),
              child: greetingText(userName: session.fullName ?? ""),
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
            badgesState.when(
              started: () => const SizedBox.shrink(),
              loading: () => SizedBox(
                height: 210.h,
                child: const Center(child: CircularProgressIndicator()),
              ),
              success: (data) => BadgeDisplay(badges: data.badges),
              error: (message) => const SizedBox.shrink(),
            ),
            10.gapH,
            quickActions(context),
            18.gapH,
            const Expanded(
              child: AllRequestsListWidget(
                showHeader: true,
                headerTitle: 'My Requests',
              ),
            ),
          ],
        ),
      ),
    );
  }
}