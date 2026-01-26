import 'package:flutter/material.dart';
import '../../../common/resources/dimensions.dart';
import 'profile_header_content.dart';
import '../../../common/resources/strings.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  static Widget buildList(
    BuildContext context, {
    required String name,
    required String phoneNumber,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileHeaderContent(name: name, phoneNumber: phoneNumber),
        24.gapH,
        SettingsTile.sectionTitle(AppString.preferences),
        const SettingsTile(
          icon: Icons.account_circle_outlined,
          title: AppString.personalInfo,
        ),
        const SettingsTile(
          icon: Icons.palette_outlined,
          title: AppString.appearance,
        ),
        8.gapH,
        SettingsTile.sectionTitle(AppString.legal),
        const SettingsTile(
          icon: Icons.description_outlined,
          title: AppString.termsAndConditions,
        ),
        const SettingsTile(
          icon: Icons.shield_outlined,
          title: AppString.privacyPolicy,
        ),
        32.gapH,
        _buildLogoutButton(context),
      ],
    );
  }

  static Widget sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Segoe UI',
          fontSize: D.textMD,
          fontWeight: D.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  static Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle Logout Logic
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(D.radiusLG),
        ),
        child: Row(
          children: [
            Icon(Icons.logout, color: Colors.redAccent, size: D.iconMD),
            12.gapW,
            Text(
              AppString.logOut,
              style: TextStyle(
                fontFamily: 'Segoe UI',
                color: Colors.redAccent,
                fontSize: D.textBase,
                fontWeight: D.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black87, size: D.iconMD),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Segoe UI',
          fontSize: D.textBase,
          fontWeight: D.medium,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey, size: D.iconMD),
      onTap: onTap ?? () {},
    );
  }
}
