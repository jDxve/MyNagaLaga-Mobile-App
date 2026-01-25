// account/screens/account_screen.dart
import 'package:flutter/material.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/background_gradient.dart';
import '../components/settings_tile.dart';

class AccountScreen extends StatelessWidget {
  static const routeName = '/account';

  final String name;
  final String phoneNumber;

  const AccountScreen({
    super.key,
    this.name = 'John Dave Banas',
    this.phoneNumber = '09928463564972',
  });

  @override
  Widget build(BuildContext context) {
    return gradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                46.gapH,
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24.w),
                  padding: EdgeInsets.symmetric(
                    vertical: 24.h,
                    horizontal: 24.w,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(D.radiusXL),
                  ),
                  child: SettingsTile.buildList(
                    context,
                    name: name,
                    phoneNumber: phoneNumber,
                  ),
                ),
                40.gapH,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
