import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';

class BenefitsCard extends StatelessWidget {
  final String title;
  final List<String> benefits;
  final Color color;

  const BenefitsCard({
    super.key,
    required this.title,
    required this.benefits,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(D.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: D.textBase,
              fontWeight: D.semiBold,
              color: Colors.black,
              fontFamily: 'Segoe UI',
            ),
          ),
          12.gapH,
          ...benefits.map(
            (benefit) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      fontSize: D.textSM,
                      color: AppColors.grey,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                  Expanded(
                    child: Text(
                      benefit,
                      style: TextStyle(
                        fontSize: D.textSM,
                        color: AppColors.grey,
                        height: 1.4,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}