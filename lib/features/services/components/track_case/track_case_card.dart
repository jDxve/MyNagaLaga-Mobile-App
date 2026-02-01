// lib/features/tracking/widgets/track_case_card.dart
import 'package:flutter/material.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../../common/widgets/primary_button.dart';


/// Individual tracking case card
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
    if (statusLower == 'pending' || statusLower == 'submitted') return Colors.orange;
    if (statusLower == 'under review' || statusLower == 'in progress') return Colors.blue;
    if (statusLower == 'action required') return Colors.red;
    if (statusLower == 'ready' || statusLower == 'approved' || statusLower == 'verified') return Colors.green;
    if (statusLower == 'closed' || statusLower == 'resolved') return Colors.grey;
    if (statusLower == 'rejected' || statusLower == 'cancelled') return Colors.red.shade700;
    return AppColors.grey;
  }

  int _getCurrentStep() {
    final statusLower = status.toLowerCase();
    if (statusLower == 'pending' || statusLower == 'submitted') return 1;
    if (statusLower == 'under review' || statusLower == 'in progress' || statusLower == 'action required') return 2;
    if (statusLower == 'ready' || statusLower == 'approved' || statusLower == 'verified') return 3;
    if (statusLower == 'closed' || statusLower == 'resolved') return 4;
    return 0;
  }

  Widget _buildProgressIndicator() {
    final statusColor = _getStatusColor();
    final currentStep = _getCurrentStep();
    if (currentStep == 0) return const SizedBox.shrink();

    return Row(
      children: List.generate(4, (index) {
        final isActive = index < currentStep;
        return Expanded(
          child: Container(
            height: 6.h,
            margin: EdgeInsets.only(right: index < 3 ? 4.w : 0),
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(D.radiusLG),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title ?? 'Untitled',
                  style: TextStyle(
                    fontSize: D.textBase,
                    fontWeight: D.semiBold,
                    color: Colors.black87,
                    fontFamily: 'Segoe UI',
                  ),
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
              onTap: () => _showRatingDialog(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(D.radiusLG),
                ),
                child: const Center(
                  child: Text(
                    'Rate your experience',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RateServiceDialog(
        serviceType: title ?? 'Service',
        caseId: caseId ?? '',
        onSubmit: (rating) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Thank you for your $rating star rating!')),
          );
        },
      ),
    );
  }
}

/// Rating dialog
class RateServiceDialog extends StatefulWidget {
  final String serviceType;
  final String caseId;
  final Function(int rating) onSubmit;

  const RateServiceDialog({
    super.key,
    required this.serviceType,
    required this.caseId,
    required this.onSubmit,
  });

  @override
  State<RateServiceDialog> createState() => _RateServiceDialogState();
}

class _RateServiceDialogState extends State<RateServiceDialog> {
  int _selectedRating = 0;

  void _handleSubmit() {
    if (_selectedRating > 0) {
      widget.onSubmit(_selectedRating);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(D.radiusLG),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(D.radiusLG),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rate Your Experience',
              style: TextStyle(
                fontSize: D.textLG,
                fontWeight: D.bold,
                color: Colors.black87,
                fontFamily: 'Segoe UI',
              ),
              textAlign: TextAlign.center,
            ),
            12.gapH,
            Text(
              'How was your experience with "${widget.serviceType}"?',
              style: TextStyle(
                fontSize: D.textSM,
                color: AppColors.grey,
                fontFamily: 'Segoe UI',
              ),
              textAlign: TextAlign.center,
            ),
            24.gapH,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = starIndex),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      _selectedRating >= starIndex ? Icons.star : Icons.star_border,
                      size: 40.w,
                      color: _selectedRating >= starIndex ? Colors.amber : Colors.grey.shade300,
                    ),
                  ),
                );
              }),
            ),
            32.gapH,
            Opacity(
              opacity: _selectedRating > 0 ? 1.0 : 0.5,
              child: IgnorePointer(
                ignoring: _selectedRating == 0,
                child: PrimaryButton(
                  text: 'Submit',
                  onPressed: _handleSubmit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}