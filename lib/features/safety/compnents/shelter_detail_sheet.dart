import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/secondary_button.dart';
import '../models/shelter_data_model.dart';
import '../../../common/utils/distant_caculator.dart';

class ShelterDetailsSheet extends StatelessWidget {
  final ShelterData shelter;
  final double? distanceInKm;
  final VoidCallback onDirections;

  const ShelterDetailsSheet({
    super.key,
    required this.shelter,
    this.distanceInKm,
    required this.onDirections,
  });

  static void show(
    BuildContext context,
    ShelterData shelter,
    double? distanceInKm,
    VoidCallback onDirections,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShelterDetailsSheet(
        shelter: shelter,
        distanceInKm: distanceInKm,
        onDirections: onDirections,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parts = shelter.capacity.split('/');
    final current = parts[0];
    final total = parts.length > 1 ? parts[1] : '0';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  Divider(thickness: 1),
                  12.gapH,
                  _buildOccupancySection(current, total),
                  24.gapH,
                  _buildVulnerableGrid(),
                  24.gapH,
                  _buildAmenitiesSection(),
                  32.gapH,
                  _buildFooter(context),
                  32.gapH,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shelter name + status badge
        Row(
          children: [
            Expanded(
              child: Text(
                shelter.name.toUpperCase(),
                style: TextStyle(
                  fontSize: D.textLG,
                  fontWeight: D.bold,
                  color: AppColors.black,
                  fontFamily: 'Segoe UI',
                  letterSpacing: 0.2,
                ),
              ),
            ),
            8.gapW,
            _buildStatusBadge(),
          ],
        ),
        12.gapH,
        Row(
          children: [
            Icon(Icons.near_me, size: D.iconSM, color: AppColors.primary),
            6.gapW,
            Text(
              distanceInKm != null
                  ? DistanceCalculator.formatDistance(distanceInKm!)
                  : 'Calculating...',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: D.textMD,
                fontWeight: D.semiBold,
                fontFamily: 'Segoe UI',
              ),
            ),
          ],
        ),
        8.gapH,
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: D.iconXS,
              color: AppColors.grey,
            ),
            4.gapW,
            Expanded(
              child: Text(
                shelter.address,
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: D.textBase,
                  fontWeight: D.semiBold,
                  fontFamily: 'Segoe UI',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final config = _getStatusConfig();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: config['bgColor'],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        config['text'],
        style: TextStyle(
          color: config['textColor'],
          fontSize: D.textXS,
          fontWeight: D.bold,
          fontFamily: 'Segoe UI',
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig() {
    switch (shelter.status) {
      case ShelterStatus.available:
        return {
          'text': 'AVAILABLE',
          'bgColor': AppColors.primary.withOpacity(0.1),
          'textColor': AppColors.primary,
        };
      case ShelterStatus.limited:
        return {
          'text': 'LIMITED',
          'bgColor': AppColors.orange.withOpacity(0.1),
          'textColor': AppColors.orange,
        };
      case ShelterStatus.full:
        return {
          'text': 'FULL',
          'bgColor': AppColors.red.withOpacity(0.1),
          'textColor': AppColors.red,
        };
    }
  }

  Widget _buildOccupancySection(String current, String total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Occupancy Details',
          style: TextStyle(
            fontSize: D.textMD,
            fontWeight: D.semiBold,
            color: AppColors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        20.gapH,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStat('Current', current),
            _buildStat('Maximum', total),
          ],
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: D.textXXL,
            fontWeight: D.bold,
            color: AppColors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.grey,
            fontSize: D.textXS,
            fontWeight: D.medium,
            fontFamily: 'Segoe UI',
          ),
        ),
      ],
    );
  }

  Widget _buildVulnerableGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vulnerable Groups',
          style: TextStyle(
            fontSize: D.textMD,
            fontWeight: D.semiBold,
            color: AppColors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        20.gapH,
        GridView.count(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.2,
          mainAxisSpacing: 20.h,
          crossAxisSpacing: 16.w,
          children: [
            _VulnerableTile(
              icon: Icons.elderly,
              count: shelter.seniors,
              label: 'Senior',
              bgColor: AppColors.lightYellow,
              iconColor: AppColors.darkYellow,
            ),
            _VulnerableTile(
              icon: Icons.child_care,
              count: shelter.infants,
              label: 'Infant',
              bgColor: AppColors.lightBlue,
              iconColor: AppColors.darkBlue,
            ),
            _VulnerableTile(
              icon: Icons.accessible,
              count: shelter.pwd,
              label: 'PWD',
              bgColor: AppColors.lightPurple,
              iconColor: AppColors.darkPurple,
            ),
            _VulnerableTile(
              icon: Icons.pregnant_woman,
              count: 2,
              label: 'Pregnant',
              bgColor: AppColors.lightPink,
              iconColor: AppColors.darkPink,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: TextStyle(
            fontSize: D.textMD,
            fontWeight: D.semiBold,
            color: AppColors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        12.gapH,
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: [
            'Water',
            'Restroom',
            'First Aid',
          ].map((e) => _AmenityChip(label: e)).toList(),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return SecondaryButton(
      text: 'GET DIRECTIONS',
      isFilled: true,
      icon: Icons.directions,
      onPressed: onDirections,
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h),
      width: 45.w,
      height: 5.h,
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }
}

class _VulnerableTile extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color bgColor;
  final Color iconColor;

  const _VulnerableTile({
    required this.icon,
    required this.count,
    required this.label,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: iconColor.withOpacity(0.3), width: 1.5),
          ),
          child: Icon(icon, color: iconColor, size: D.iconLG),
        ),
        14.gapW,
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontWeight: D.bold,
                fontSize: D.textLG,
                color: AppColors.black,
                fontFamily: 'Segoe UI',
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppColors.grey,
                fontSize: D.textXS,
                fontWeight: D.semiBold,
                fontFamily: 'Segoe UI',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String label;

  const _AmenityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.grey,
          fontSize: D.textSM,
          fontWeight: D.semiBold,
          fontFamily: 'Segoe UI',
        ),
      ),
    );
  }
}
