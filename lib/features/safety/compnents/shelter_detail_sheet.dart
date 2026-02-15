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
      padding: EdgeInsets.symmetric(horizontal: D.w(24)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(D.r(32))),
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
                  const Divider(height: 32, thickness: 1),
                  _buildOccupancySection(current, total),
                  const SizedBox(height: 24),
                  _buildVulnerableGrid(),
                  const SizedBox(height: 24),
                  _buildAmenitiesSection(),
                  const SizedBox(height: 32),
                  _buildFooter(context),
                  const SizedBox(height: 32),
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                shelter.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textlogo,
                  fontFamily: 'Segoe UI',
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusBadge(),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.near_me, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              distanceInKm != null
                  ? DistanceCalculator.formatDistance(distanceInKm!)
                  : 'Calculating...',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: D.textBase,
                fontWeight: FontWeight.w800,
                fontFamily: 'Segoe UI',
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.location_on_outlined,
                size: 16, color: AppColors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                shelter.address,
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config['bgColor'],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        config['text'],
        style: TextStyle(
          color: config['textColor'],
          fontSize: 10,
          fontWeight: FontWeight.w900,
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
        const Text(
          'Occupancy Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textlogo,
            fontFamily: 'Segoe UI',
          ),
        ),
        const SizedBox(height: 20),
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
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColors.textlogo,
            fontFamily: 'Segoe UI',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w600,
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
        const Text(
          'Vulnerable Groups',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textlogo,
            fontFamily: 'Segoe UI',
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 16,
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
        const Text(
          'Amenities',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textlogo,
            fontFamily: 'Segoe UI',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ['Water', 'Restroom', 'First Aid']
              .map((e) => _AmenityChip(label: e))
              .toList(),
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
      margin: const EdgeInsets.symmetric(vertical: 16),
      width: 45,
      height: 5,
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: iconColor.withOpacity(0.3), width: 1.5),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(width: 14),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: AppColors.textlogo,
                fontFamily: 'Segoe UI',
                height: 1.1,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.grey,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          fontFamily: 'Segoe UI',
        ),
      ),
    );
  }
}