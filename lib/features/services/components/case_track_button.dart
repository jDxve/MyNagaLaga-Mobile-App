import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/assets.dart';

class TrackCaseButton extends StatefulWidget {
  final VoidCallback? onTap;
  final int caseCount;

  const TrackCaseButton({
    super.key,
    this.onTap,
    this.caseCount = 0,
  });

  @override
  State<TrackCaseButton> createState() => _TrackCaseButtonState();
}

class _TrackCaseButtonState extends State<TrackCaseButton> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      widget.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.caseCount > 0,
      child: GestureDetector(
        onTap: _toggleExpanded,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: _isExpanded ? 20.w : 16.w,
            vertical: _isExpanded ? 12.h : 16.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                Assets.trackCaseIcon,
                width: 20.w,
                height: 20.w,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isExpanded
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          8.gapW,
                          Text(
                            'Track Cases',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: D.textBase,
                              fontWeight: D.semiBold,
                              fontFamily: 'Segoe UI',
                            ),
                          ),
                          8.gapW,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '${widget.caseCount}',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: D.textSM,
                                fontWeight: D.bold,
                                fontFamily: 'Segoe UI',
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}