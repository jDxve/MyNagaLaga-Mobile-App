import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../models/shelter_data_model.dart';
import '../../../common/utils/distant_caculator.dart';

class ShelterCard extends StatelessWidget {
  final ShelterData shelter;
  final double? distanceInKm;
  final VoidCallback? onTap;

  const ShelterCard({
    super.key,
    required this.shelter,
    this.distanceInKm,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.grey.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            12.gapH,
            _buildInfoRow(),
            12.gapH,
            _buildCapacityBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            shelter.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
        ),
        8.gapW,
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final config = _StatusConfig.from(shelter.status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        config.text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: config.textColor,
        ),
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 16, color: AppColors.grey),
        4.gapW,
        Expanded(
          child: Text(
            shelter.address,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (distanceInKm != null) ...[
          12.gapW,
          Icon(Icons.navigation, size: 16, color: AppColors.primary),
          4.gapW,
          Text(
            DistanceCalculator.formatDistance(distanceInKm!),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCapacityBar() {
    final percentage = _calculateCapacityPercentage();
    final config = _StatusConfig.from(shelter.status);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Capacity',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey,
              ),
            ),
            Text(
              shelter.capacity,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        8.gapH,
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppColors.grey.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(config.textColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  double _calculateCapacityPercentage() {
    final parts = shelter.capacity.split('/');
    if (parts.length != 2) return 0.0;
    final current = double.tryParse(parts[0]) ?? 0;
    final total = double.tryParse(parts[1]) ?? 1;
    return (current / total).clamp(0.0, 1.0);
  }
}

class _StatusConfig {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const _StatusConfig({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  factory _StatusConfig.from(ShelterStatus status) {
    switch (status) {
      case ShelterStatus.available:
        return const _StatusConfig(
          text: 'Available',
          backgroundColor: AppColors.lightPrimary,
          textColor: AppColors.primary,
        );
      case ShelterStatus.limited:
        return const _StatusConfig(
          text: 'Limited',
          backgroundColor: AppColors.lightYellow,
          textColor: AppColors.orange,
        );
      case ShelterStatus.full:
        return const _StatusConfig(
          text: 'Full',
          backgroundColor: AppColors.lightPink,
          textColor: AppColors.red,
        );
    }
  }
}