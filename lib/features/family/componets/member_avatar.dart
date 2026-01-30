import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../models/family_ledger_model.dart';

class MemberAvatar extends StatelessWidget {
  final FamilyMember member;
  final int generation;
  final VoidCallback onLongPress;

  const MemberAvatar({
    super.key,
    required this.member,
    required this.generation,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: member.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.grey.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.person,
              size: D.iconMD,
              color: AppColors.textlogo.withOpacity(0.6),
            ),
          ),
          8.gapH,
          Text(
            member.name,
            style: TextStyle(
              fontWeight: D.semiBold,
              fontSize: D.textBase,
              color: AppColors.textlogo,
            ),
          ),
          2.gapH,
          Text(
            member.role,
            style: TextStyle(
              fontSize: D.textXS,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}