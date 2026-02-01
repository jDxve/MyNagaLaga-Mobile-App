// lib/features/tracking/components/track_case/track_case_indicator.dart
import 'package:flutter/material.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import 'rate_service.dart';

class TrackCaseCard extends StatelessWidget {
  final String? caseId;
  final String? title;
  final String status;
  final String description;
  final String updatedDate;
  final bool showRateButton;

  const TrackCaseCard({
    super.key,
    required this.caseId,
    required this.title,
    required this.status,
    required this.description,
    required this.updatedDate,
    this.showRateButton = false,
  });

  Color _getStatusColor() {
    final statusLower = status.toLowerCase();
    
    if (statusLower == 'pending' || statusLower == 'submitted') {
      return Colors.orange;
    }
    
    if (statusLower == 'under review' || statusLower == 'in progress') {
      return Colors.blue;
    }
    
    if (statusLower == 'action required') {
      return Colors.red;
    }
    
    if (statusLower == 'ready' || 
        statusLower == 'approved' || 
        statusLower == 'verified') {
      return Colors.green;
    }
    
    if (statusLower == 'closed' || statusLower == 'resolved') {
      return Colors.grey;
    }
    
    if (statusLower == 'rejected' || statusLower == 'cancelled') {
      return Colors.red.shade700;
    }
    
    return AppColors.grey;
  }

  int _getCurrentStep() {
    final statusLower = status.toLowerCase();
    
    if (statusLower == 'pending' || statusLower == 'submitted') {
      return 1;
    }
    if (statusLower == 'under review' || statusLower == 'in progress' || statusLower == 'action required') {
      return 2;
    }
    if (statusLower == 'ready' || statusLower == 'approved' || statusLower == 'verified') {
      return 3;
    }
    if (statusLower == 'closed' || statusLower == 'resolved') {
      return 4;
    }
    if (statusLower == 'rejected' || statusLower == 'cancelled') {
      return 0;
    }
    
    return 0;
  }

  Widget _buildProgressIndicator() {
    final statusColor = _getStatusColor();
    final currentStep = _getCurrentStep();
    
    if (currentStep == 0) {
      return const SizedBox.shrink();
    }

    return Row(
      children: List.generate(4, (index) {
        final isActive = index < currentStep;
        return Expanded(
          child: Container(
            height: 6.h,
            margin: EdgeInsets.only(
              right: index < 3 ? 4.w : 0,
            ),
            decoration: BoxDecoration(
              color: isActive ? statusColor : statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final currentStep = _getCurrentStep();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(D.radiusLG),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caseId ?? 'N/A',
                      style: TextStyle(
                        fontSize: D.textXS,
                        color: AppColors.grey,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                    4.gapH,
                    Text(
                      title ?? 'Untitled',
                      style: TextStyle(
                        fontSize: D.textBase,
                        fontWeight: D.semiBold,
                        color: Colors.black87,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: D.textXS,
                    fontWeight: D.medium,
                    color: statusColor,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ),
            ],
          ),
          if (currentStep > 0) ...[
            12.gapH,
            _buildProgressIndicator(),
          ],
          12.gapH,
          Text(
            description,
            style: TextStyle(
              fontSize: D.textSM,
              color: AppColors.grey,
              fontFamily: 'Segoe UI',
            ),
          ),
          8.gapH,
          Text(
            'Updated $updatedDate',
            style: TextStyle(
              fontSize: D.textXS,
              color: AppColors.grey,
              fontFamily: 'Segoe UI',
            ),
          ),
          if (showRateButton) ...[
            12.gapH,
            GestureDetector(
              onTap: () {
                RateServiceDialog.show(
                  context: context,
                  serviceType: title ?? 'Service',
                  caseId: caseId ?? '',
                  onSubmit: (rating) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Thank you for your $rating star rating!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(D.radiusLG),
                ),
                child: Center(
                  child: Text(
                    'Rate your experience',
                    style: TextStyle(
                      fontSize: D.textBase,
                      fontWeight: D.bold,
                      color: Colors.white,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}