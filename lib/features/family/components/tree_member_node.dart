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

  Color get _avatarColor {
    if (widget.isHead) return AppColors.lightBlue;
    if (widget.role == 'Spouse') return AppColors.lightPurple;
    if (widget.role == 'Child') return AppColors.lightPink;
    if (widget.role == 'Grandchild') return AppColors.lightYellow;
    if (widget.role == 'Sibling') return AppColors.lightYellow;
    return AppColors.background;
  }

  Color get _borderColor {
    if (widget.isHead) return AppColors.blue;
    if (widget.role == 'Spouse') return AppColors.purple;
    if (widget.role == 'Child') return AppColors.orange;
    if (widget.role == 'Grandchild') return AppColors.darkYellow;
    if (widget.role == 'Sibling') return AppColors.darkYellow;
    return AppColors.grey;
  }

  bool get _isPending => widget.status == 'Pending';
  bool get _isRevoked => widget.status == 'Revoked';

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isRevoked ? 0.5 : 1.0,
      child: SizedBox(
        width: 100.w,
        child: Column(
          children: [
            _buildAvatar(),
            10.gapH,
            _buildName(),
            2.gapH,
            _buildRoleBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (widget.isCurrentUser) {
      return SizedBox(
        width: 90.w,
        height: 90.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildRipple(0.0),
            _buildRipple(0.33),
            _buildRipple(0.66),
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
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _borderColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 36.w,
                    color: _borderColor,
                  ),
                ),
                if (_isPending) _buildPendingBadge(),
              ],
            ),
          ],
        ),
      );
    }

    return Stack(
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
              width: _isPending ? 2 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: _borderColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.person, size: 36.w, color: _borderColor),
        ),
        if (_isPending) _buildPendingBadge(),
      ],
    );
  }

  Widget _buildRipple(double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = (_controller.value + delay) % 1.0;
        final scale = 1.0 + progress * 0.6;
        final opacity = (1.0 - progress).clamp(0.0, 1.0);

        return Container(
          width: 72.w * scale,
          height: 72.w * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _borderColor.withOpacity(opacity * 0.6),
              width: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingBadge() {
    return Positioned(
      left: -2.w,
      top: -2.h,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.orange,
          borderRadius: BorderRadius.circular(D.radiusSM),
          border: Border.all(color: AppColors.white, width: 2),
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
    );
  }

  Widget _buildName() {
    return Text(
      widget.name,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14.f,
        fontWeight: widget.isCurrentUser ? FontWeight.w900 : FontWeight.w700,
        fontFamily: 'Segoe UI',
        color: _isRevoked ? AppColors.grey : AppColors.textlogo,
      ),
    );
  }

  Widget _buildRoleBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _borderColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(D.radiusSM),
      ),
      child: Text(
        widget.role,
        style: TextStyle(
          fontSize: 11.f,
          fontWeight: FontWeight.w600,
          fontFamily: 'Segoe UI',
          color: _borderColor,
        ),
      ),
    );
  }
}
