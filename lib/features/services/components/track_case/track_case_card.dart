import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../notifier/tracking_notifier.dart';

class TrackCaseCard extends ConsumerWidget {
  final String? caseId;
  final String? title;
  final String? subtitle;
  final String? tag;
  final String status;
  final String description;
  final String updatedDate;
  final bool showRateButton;
  final bool hasRated;
  final VoidCallback? onRated;

  /// The feedbackable_type to send to the backend.
  /// Must be one of: 'assistance_posting', 'complaint', 'case'
  final String feedbackableType;

  const TrackCaseCard({
    super.key,
    required this.caseId,
    required this.title,
    this.subtitle,
    this.tag,
    required this.status,
    required this.description,
    required this.updatedDate,
    this.showRateButton = false,
    this.hasRated = false,
    this.onRated,
    this.feedbackableType = 'assistance_posting',
  });

  Color _getStatusColor() {
    final s = status.toLowerCase();
    if (s == 'pending' || s == 'submitted') return Colors.orange;
    if (s == 'under review' || s == 'in progress') return Colors.blue;
    if (s == 'action required') return Colors.red;
    if (s == 'ready' || s == 'approved' || s == 'verified') return Colors.green;
    if (s == 'closed' || s == 'resolved') return Colors.grey;
    if (s == 'rejected' || s == 'cancelled') return Colors.red.shade700;
    return AppColors.grey;
  }

  int _getCurrentStep() {
    final s = status.toLowerCase();
    if (s == 'pending' || s == 'submitted') return 1;
    if (s == 'under review' || s == 'in progress' || s == 'action required') return 2;
    if (s == 'ready' || s == 'approved' || s == 'verified') return 3;
    if (s == 'closed' || s == 'resolved') return 4;
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
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor();
    final currentStep = _getCurrentStep();

    return Opacity(
      opacity: hasRated ? 0.65 : 1.0,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(D.radiusLG),
          border: Border.all(
            color: AppColors.lightGrey.withOpacity(0.6),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tag != null) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag!,
                  style: TextStyle(
                    fontSize: D.textXS,
                    color: AppColors.primary,
                    fontWeight: D.semiBold,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ),
              6.gapH,
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title ?? 'Untitled',
                        style: TextStyle(
                          fontSize: D.textBase,
                          fontWeight: D.semiBold,
                          color: Colors.black87,
                          fontFamily: 'Segoe UI',
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        4.gapH,
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: D.textXS,
                            color: AppColors.grey,
                            fontFamily: 'Segoe UI',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
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
                    if (hasRated) ...[
                      6.gapH,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 12.w, color: Colors.amber),
                          3.gapW,
                          Text(
                            'Rated',
                            style: TextStyle(
                              fontSize: D.textXS,
                              color: Colors.amber.shade700,
                              fontWeight: D.semiBold,
                              fontFamily: 'Segoe UI',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
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
            if (showRateButton && !hasRated) ...[
              12.gapH,
              _RateButton(
                caseId: caseId ?? '',
                title: title ?? 'Service',
                feedbackableType: feedbackableType,
                onRated: onRated,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RateButton extends ConsumerWidget {
  final String caseId;
  final String title;
  final String feedbackableType;
  final VoidCallback? onRated;

  const _RateButton({
    required this.caseId,
    required this.title,
    required this.feedbackableType,
    this.onRated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => _RateServiceDialog(
          serviceType: title,
          caseId: caseId,
          feedbackableType: feedbackableType,
          onSubmitted: onRated,
        ),
      ),
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
    );
  }
}

class _RateServiceDialog extends ConsumerStatefulWidget {
  final String serviceType;
  final String caseId;
  final String feedbackableType;
  final VoidCallback? onSubmitted;

  const _RateServiceDialog({
    required this.serviceType,
    required this.caseId,
    required this.feedbackableType,
    this.onSubmitted,
  });

  @override
  ConsumerState<_RateServiceDialog> createState() => _RateServiceDialogState();
}

class _RateServiceDialogState extends ConsumerState<_RateServiceDialog> {
  int _selectedRating = 0;
  final _commentController = TextEditingController();
  bool _anonymous = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    final id = int.tryParse(widget.caseId) ?? 0;

    await ref.read(feedbackSubmitNotifierProvider.notifier).submit(
          feedbackableType: widget.feedbackableType,
          feedbackableId: id,
          rating: _selectedRating,
          comment: _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
          isAnonymous: _anonymous,
          // Pass the right ID param based on type so notifier marks correct item
          postingId:
              widget.feedbackableType == 'assistance_posting' ? widget.caseId : null,
          complaintId:
              widget.feedbackableType == 'complaint' ? widget.caseId : null,
          badgeId:
              widget.feedbackableType == 'badge_request' ? widget.caseId : null,
        );

    if (!mounted) return;

    final state = ref.read(feedbackSubmitNotifierProvider);

    if (state.isSuccess) {
      Navigator.pop(context);
      widget.onSubmitted?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thank you for your $_selectedRating star rating!'),
          backgroundColor: Colors.green,
        ),
      );
      ref.read(feedbackSubmitNotifierProvider.notifier).reset();
    } else if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          backgroundColor: Colors.red,
        ),
      );
      ref.read(feedbackSubmitNotifierProvider.notifier).reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(feedbackSubmitNotifierProvider);

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
                final star = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = star),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      _selectedRating >= star ? Icons.star : Icons.star_border,
                      size: 40.w,
                      color: _selectedRating >= star
                          ? Colors.amber
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              }),
            ),
            20.gapH,
            TextField(
              controller: _commentController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Leave a comment (optional)',
                hintStyle: TextStyle(
                    fontSize: D.textSM,
                    color: AppColors.grey,
                    fontFamily: 'Segoe UI'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(D.radiusMD),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(D.radiusMD),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(D.radiusMD),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
            8.gapH,
            Row(
              children: [
                Checkbox(
                  value: _anonymous,
                  onChanged: (v) => setState(() => _anonymous = v ?? false),
                  activeColor: AppColors.primary,
                ),
                Text(
                  'Submit anonymously',
                  style: TextStyle(
                      fontSize: D.textSM,
                      color: Colors.black87,
                      fontFamily: 'Segoe UI'),
                ),
              ],
            ),
            16.gapH,
            Opacity(
              opacity: _selectedRating > 0 ? 1.0 : 0.5,
              child: IgnorePointer(
                ignoring: _selectedRating == 0 || submitState.isLoading,
                child: submitState.isLoading
                    ? const CircularProgressIndicator()
                    : PrimaryButton(
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