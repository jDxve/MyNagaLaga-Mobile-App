import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/background_gradient.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/colors.dart';
import '../components/settings_tile.dart';
import '../../../common/models/dio/data_state.dart';
import '../notifier/user_info_notifier.dart';
import '../../auth/notifier/auth_session_notifier.dart';

class AccountScreen extends ConsumerStatefulWidget {
  static const routeName = '/account';
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userInfoNotifierProvider.notifier).fetchUserInfo();
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(D.radiusLG),
        ),
        title: const Text(
          'Log Out',
          style: TextStyle(fontFamily: 'Segoe UI', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(fontFamily: 'Segoe UI'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Segoe UI',
                color: AppColors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'Segoe UI',
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(authSessionProvider.notifier).logout();

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login', // replace with your actual login route
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userInfoNotifierProvider);

    return gradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: userState.when(
            started: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            success: (user) => SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(D.radiusXL),
                ),
                child: SettingsTile.buildList(
                  context,
                  name: user.fullName ?? user.email,
                  phoneNumber: user.phoneNumber ?? 'N/A',
                  onLogout: _handleLogout,
                ),
              ),
            ),
            error: (err) => const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('Error loading profile')),
            ),
          ),
        ),
      ),
    );
  }
}