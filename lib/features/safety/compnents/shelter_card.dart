import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../models/shelter_data_model.dart';

class ShelterCard extends StatelessWidget {
  final ShelterData shelter;
  final VoidCallback? onTap;

  const ShelterCard({super.key, required this.shelter, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(D.radiusLG),
          border: Border.all(
            color: AppColors.grey.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            8.gapH,
            _buildLocationRow(),
            16.gapH,
            _buildCapacitySection(),
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
              fontSize: D.textBase,
              fontWeight: D.bold,
              color: AppColors.black,
            ),
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final config = _StatusConfig.from(shelter.status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(D.radiusSM),
      ),
      child: Text(
        config.text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: D.bold,
          color: config.textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLocationRow() {
    return Row(
      children: [
        Icon(Icons.near_me, size: 14, color: AppColors.primary),
        4.gapW,
        Text(
          '0.5 km away',
          style: TextStyle(
            fontSize: D.textSM,
            fontWeight: D.semiBold,
            color: AppColors.primary,
          ),
        ),
        12.gapW,
        Icon(Icons.location_on_outlined, size: 14, color: AppColors.grey),
        4.gapW,
        Expanded(
          child: Text(
            shelter.address,
            style: TextStyle(fontSize: D.textSM, color: AppColors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCapacitySection() {
    final percentage = _calculateCapacityPercentage();
    final barColor = _StatusConfig.from(shelter.status).textColor;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Occupancy',
              style: TextStyle(
                fontSize: D.textXS,
                fontWeight: D.semiBold,
                color: AppColors.grey,
              ),
            ),
            Text(
              shelter.capacity,
              style: TextStyle(
                fontSize: D.textXS,
                fontWeight: D.bold,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        6.gapH,
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppColors.grey.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 8,
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