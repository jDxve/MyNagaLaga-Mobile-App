import 'package:flutter/material.dart';
import '../../../common/resources/assets.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../models/user_badge_model.dart';
import '../../verify_badge/screens/verify_badge_screen.dart';

class BadgeDisplay extends StatefulWidget {
  final List<BadgeModel> badges;

  const BadgeDisplay({super.key, required this.badges});

  @override
  State<BadgeDisplay> createState() => _BadgeDisplayState();
}

class _BadgeDisplayState extends State<BadgeDisplay>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isMovingForward = true;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1)).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getBadgeImage(BadgeType badgeType) {
    switch (badgeType) {
      case BadgeType.student:
        return Assets.studentBadge;
      case BadgeType.soloParent:
        return Assets.soloParentBadge;
      case BadgeType.seniorCitizen:
        return Assets.seniorCitizenBadge;
      case BadgeType.pwd:
        return Assets.pwdBadge;
      case BadgeType.indigent:
        return Assets.indigentFamilyBadge;
      case BadgeType.citizen:
        return Assets.citizenBadge;
      case BadgeType.other:
        return Assets.studentBadge;
    }
  }

  Future<void> _nextBadge() async {
    if (_controller.isAnimating) return;
    setState(() {
      _isMovingForward = true;
      _slideAnimation =
          Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1)).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
          );
    });
    await _controller.forward();
    setState(() => _currentIndex = (_currentIndex + 1) % widget.badges.length);
    _controller.reset();
  }

  Future<void> _previousBadge() async {
    if (_controller.isAnimating) return;
    setState(() {
      _isMovingForward = false;
      _slideAnimation =
          Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1)).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
          );
    });
    await _controller.forward();
    setState(() =>
        _currentIndex = (_currentIndex - 1 + widget.badges.length) % widget.badges.length);
    _controller.reset();
  }

  // ── Empty state ──────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, VerifyBadgeScreen.routeName),
        child: Container(
          height: 210.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(D.radiusXL),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge icon placeholder
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.badge_outlined,
                  size: 28.w,
                  color: Colors.grey.shade400,
                ),
              ),
              16.gapH,
              Text(
                'No Badge Yet',
                style: TextStyle(
                  fontSize: D.textBase,
                  fontWeight: D.semiBold,
                  color: Colors.grey.shade600,
                  fontFamily: 'Segoe UI',
                ),
              ),
              6.gapH,
              Text(
                'Tap to apply for your first badge',
                style: TextStyle(
                  fontSize: D.textSM,
                  color: Colors.grey.shade400,
                  fontFamily: 'Segoe UI',
                ),
              ),
              20.gapH,
              // CTA chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(D.radiusXL),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 16.w),
                    6.gapW,
                    Text(
                      'Apply for Badge',
                      style: TextStyle(
                        fontSize: D.textSM,
                        fontWeight: D.semiBold,
                        color: Colors.white,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Badge stack ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.badges.isEmpty) return _buildEmptyState();

    final int total = widget.badges.length;
    final int displayCount = total > 4 ? 4 : total;

    double containerHeight;
    switch (displayCount) {
      case 4:
        containerHeight = 250.h;
        break;
      case 3:
        containerHeight = 230.h;
        break;
      case 2:
        containerHeight = 220.h;
        break;
      default:
        containerHeight = 210.h;
    }

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (total <= 1) return;
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < 0) {
          _nextBadge();
        } else if (velocity > 0) {
          _previousBadge();
        }
      },
      child: SizedBox(
        height: containerHeight,
        child: Stack(
          alignment: Alignment.topCenter,
          children: List.generate(displayCount, (index) {
            final int reversedIndex = displayCount - 1 - index;

            int badgeIndex;
            if (_isMovingForward) {
              badgeIndex = (_currentIndex + reversedIndex) % total;
            } else {
              badgeIndex = (_currentIndex - reversedIndex + total) % total;
            }

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double progress = _controller.value;
                final double position = reversedIndex - progress;

                if (reversedIndex == 0) {
                  return Positioned(
                    top: 0,
                    left: 32.w,
                    right: 32.w,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Image.asset(
                          _getBadgeImage(
                            widget.badges[_currentIndex].badgeTypeKey,
                          ),
                          height: 200.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                }

                final double topOffset = 15.h * position;
                final double scale = 1.0 - (0.04 * position);
                final double opacity =
                    position > 3 ? 0.0 : (1.0 - (0.25 * position));

                return Positioned(
                  top: topOffset.clamp(0, 60.h),
                  left: 32.w,
                  right: 32.w,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: scale.clamp(0.8, 1.0),
                      child: Image.asset(
                        _getBadgeImage(widget.badges[badgeIndex].badgeTypeKey),
                        height: 200.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}