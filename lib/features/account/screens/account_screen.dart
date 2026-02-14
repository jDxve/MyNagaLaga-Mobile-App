import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/background_gradient.dart';
import '../../../common/resources/dimensions.dart';
import '../components/settings_tile.dart';
import '../../../common/models/dio/data_state.dart';
import '../notifier/user_info_notifier.dart';

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