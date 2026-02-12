// lib/features/family_ledger/components/tree_member_node.dart
import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';

class TreeMemberNode extends StatelessWidget {
  final String name;
  final String role;
  final bool isHead;
  final String status;

  const TreeMemberNode({
    super.key,
    required this.name,
    required this.role,
    required this.isHead,
    required this.status,
  });

  Color get _avatarColor {
    if (isHead) return const Color(0xFFE3F2FD); // Light blue
    if (role == 'Spouse') return const Color(0xFFF3E5F5); // Light purple
    if (role == 'Child') return const Color(0xFFFFE0B2); // Light orange
    if (role == 'Grandchild') return const Color(0xFFFFF9C4); // Light yellow
    return const Color(0xFFF5F5F5);
  }

  Color get _borderColor {
    if (isHead) return const Color(0xFF1976D2); // Blue
    if (role == 'Spouse') return const Color(0xFF7B1FA2); // Purple
    if (role == 'Child') return const Color(0xFFF57C00); // Orange
    if (role == 'Grandchild') return const Color(0xFFFBC02D); // Yellow
    return AppColors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'Pending';
    final isRevoked = status == 'Revoked';

    return Opacity(
      opacity: isRevoked ? 0.5 : 1.0,
      child: SizedBox(
        width: 100.w,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    color: _avatarColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _borderColor,
                      width: isPending ? 2 : 3,
                      style: BorderStyle.solid,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _borderColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 36.w,
                      color: _borderColor,
                    ),
                  ),
                ),
                if (isHead)
                  Positioned(
                    right: -2.w,
                    bottom: -2.h,
                    child: Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.star,
                        size: 16.w,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                if (isPending)
                  Positioned(
                    left: -2.w,
                    top: -2.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(D.radiusSM),
                        border: Border.all(
                          color: AppColors.white,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '!',
                        style: TextStyle(
                          fontSize: D.textXS,
                          fontWeight: D.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            10.gapH,
            Text(
              name.split(' ')[0],
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: D.textSM,
                fontWeight: D.bold,
                color: isRevoked ? AppColors.grey : AppColors.textlogo,
              ),
            ),
            2.gapH,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: _borderColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(D.radiusSM),
              ),
              child: Text(
                role,
                style: TextStyle(
                  fontSize: D.textXS,
                  color: _borderColor,
                  fontWeight: D.semiBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}