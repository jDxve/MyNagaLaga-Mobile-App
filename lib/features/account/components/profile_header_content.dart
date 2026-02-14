import 'package:flutter/material.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/strings.dart';
import '../../../common/widgets/primary_button.dart';
import '../../verify_badge/screens/verify_badge_screen.dart';

class ProfileHeaderContent extends StatelessWidget {
  final String name;
  final String phoneNumber;

  const ProfileHeaderContent({
    super.key,
    required this.name,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 50.r,
              backgroundColor: const Color(0xFFF0F0F0),
              child: Icon(Icons.person, size: 60.r, color: Colors.grey[400]),
            ),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.file_upload_outlined,
                color: Colors.white,
                size: 18.r,
              ),
            ),
          ],
        ),
        16.gapH,
        Text(
          name,
          style: TextStyle(
            fontFamily: 'Segoe UI',
            fontSize: D.textXL,
            fontWeight: D.bold,
          ),
        ),
        Text(
          phoneNumber,
          style: TextStyle(
            fontFamily: 'Segoe UI',
            fontSize: D.textLG,
            color: AppColors.grey,
          ),
        ),
        20.gapH,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: PrimaryButton(
            text: AppString.verifyYourBadge,
            onPressed: () {
              Navigator.pushNamed(context, VerifyBadgeScreen.routeName);
            },
          ),
        ),
      ],
    );
  }
}