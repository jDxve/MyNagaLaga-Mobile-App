import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';

class HouseholdInfoCard extends StatelessWidget {
  final String householdCode;
  final String barangay;
  final int memberCount;

  const HouseholdInfoCard({
    super.key,
    required this.householdCode,
    required this.barangay,
    required this.memberCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      height: 220.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withAlpha(200),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            Positioned.fill(
              child: CustomPaint(
                painter: MicroGridPainter(Colors.white.withOpacity(0.04)),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const Spacer(),
                  _buildLocationBadge(),
                  20.gapH,
                  _buildMemberStats(),
                ],
              ),
            ),

            Positioned(
              bottom: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOUSEHOLD IDENTIFIER',
          style: TextStyle(
            fontSize: 10.f,
            fontWeight: D.bold,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 2.5,
          ),
        ),
        4.gapH,
        Text(
          householdCode,
          style: TextStyle(
            fontSize: 28.f,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on_outlined, size: 16.w, color: Colors.white),
          10.gapW,
          Text(
            barangay.toUpperCase(),
            style: TextStyle(
              fontSize: 12.f,
              color: Colors.white,
              fontWeight: D.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberStats() {
    return Row(
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Icon(Icons.people_rounded, color: Colors.white, size: 20.w),
        ),
        16.gapW,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$memberCount Family Members',
              style: TextStyle(
                fontSize: 16.f,
                fontWeight: D.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'OFFICIAL REGISTRY',
              style: TextStyle(
                fontSize: 10.f,
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 1.0,
                fontWeight: D.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MicroGridPainter extends CustomPainter {
  final Color color;
  MicroGridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 15.0;
    for (var i = 0.0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (var i = 0.0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}