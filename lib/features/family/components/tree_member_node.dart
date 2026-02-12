import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';

class TreeMemberNode extends StatefulWidget {
  final String name;
  final String role;
  final bool isHead;
  final String status;
  final bool isCurrentUser;

  const TreeMemberNode({
    super.key,
    required this.name,
    required this.role,
    required this.isHead,
    required this.status,
    this.isCurrentUser = false,
  });

  @override
  State<TreeMemberNode> createState() => _TreeMemberNodeState();
}

class _TreeMemberNodeState extends State<TreeMemberNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.isCurrentUser) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2200),
      )..repeat();
    }
  }

  @override
  void dispose() {
    if (widget.isCurrentUser) {
      _controller.dispose();
    }
    super.dispose();
  }

  Color get avatarColor {
    if (widget.isHead) return AppColors.lightBlue;
    if (widget.role == 'Spouse') return AppColors.lightPurple;
    if (widget.role == 'Child') return AppColors.lightPink;
    if (widget.role == 'Grandchild') return AppColors.lightYellow;
    if (widget.role == 'Sibling') return AppColors.lightYellow;
    return AppColors.background;
  }

  Color get borderColor {
    if (widget.isHead) return AppColors.blue;
    if (widget.role == 'Spouse') return AppColors.purple;
    if (widget.role == 'Child') return AppColors.orange;
    if (widget.role == 'Grandchild') return AppColors.darkYellow;
    if (widget.role == 'Sibling') return AppColors.darkYellow;
    return AppColors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final isPending = widget.status == 'Pending';
    final isRevoked = widget.status == 'Revoked';

    return Opacity(
      opacity: isRevoked ? 0.5 : 1.0,
      child: SizedBox(
        width: 100.w,
        child: Column(
          children: [
            SizedBox(
              width: widget.isCurrentUser ? 90.w : 72.w,
              height: widget.isCurrentUser ? 90.w : 72.w,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (widget.isCurrentUser)
                    ...[0.0, 0.33, 0.66].map(
                      (delay) => AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final progress =
                              (_controller.value + delay) % 1.0;
                          final scale = 1.0 + progress * 0.6;
                          final opacity =
                              (1.0 - progress).clamp(0.0, 1.0);

                          return Container(
                            width: 72.w * scale,
                            height: 72.w * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    borderColor.withOpacity(opacity * 0.6),
                                width: 2,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      color: avatarColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: borderColor,
                        width: isPending ? 2 : 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: borderColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person,
                      size: 36.w,
                      color: borderColor,
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
                          borderRadius:
                              BorderRadius.circular(D.radiusSM),
                          border: Border.all(
                            color: AppColors.white,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '!',
                          style: TextStyle(
                            fontSize: 10.f,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Segoe UI',
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            10.gapH,
            Text(
              widget.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.f,
                fontWeight: widget.isCurrentUser
                    ? FontWeight.w900
                    : FontWeight.w700,
                fontFamily: 'Segoe UI',
                color:
                    isRevoked ? AppColors.grey : AppColors.textlogo,
              ),
            ),
            2.gapH,
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 2.h,
              ),
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(D.radiusSM),
              ),
              child: Text(
                widget.role,
                style: TextStyle(
                  fontSize: 11.f,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Segoe UI',
                  color: borderColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
