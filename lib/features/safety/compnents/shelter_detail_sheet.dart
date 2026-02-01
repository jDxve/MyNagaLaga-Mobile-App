import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/secondary_button.dart';
import '../models/shelter_data_model.dart';

class ShelterDetailsSheet extends StatelessWidget {
  final ShelterData shelter;
  final VoidCallback onDirections;

  const ShelterDetailsSheet({
    super.key,
    required this.shelter,
    required this.onDirections,
  });

  static void show(BuildContext context, ShelterData shelter, VoidCallback onDirections) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShelterDetailsSheet(
        shelter: shelter,
        onDirections: onDirections,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final capacity = _parseCapacity(shelter.capacity);
    final percentage = (capacity['current']! / capacity['max']!) * 100;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    shelter.name,
                    style: TextStyle(
                      fontSize: D.textXL,
                      fontWeight: D.bold,
                      color: AppColors.black,
                    ),
                  ),

                  16.gapH,

                  // Distance
                  Row(
                    children: [
                      Icon(
                        Icons.navigation,
                        size: 20.w,
                        color: AppColors.grey,
                      ),
                      8.gapW,
                      Text(
                        '0.5 km away',
                        style: TextStyle(
                          fontSize: D.textBase,
                          color: AppColors.grey,
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: _getStatusBackgroundColor(shelter.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getStatusText(shelter.status),
                          style: TextStyle(
                            fontSize: D.textSM,
                            fontWeight: D.semiBold,
                            color: _getStatusTextColor(shelter.status),
                          ),
                        ),
                      ),
                    ],
                  ),

                  12.gapH,

                  // Address
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 20.w,
                        color: AppColors.grey,
                      ),
                      8.gapW,
                      Expanded(
                        child: Text(
                          shelter.address,
                          style: TextStyle(
                            fontSize: D.textBase,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  32.gapH,

                  // Occupancy Details
                  Text(
                    'Occupancy Details',
                    style: TextStyle(
                      fontSize: D.textLG,
                      fontWeight: D.bold,
                      color: AppColors.black,
                    ),
                  ),

                  24.gapH,

                  Row(
                    children: [
                      Expanded(
                        child: _buildOccupancyCard(
                          'Current',
                          capacity['current'].toString(),
                          AppColors.primary.withOpacity(0.1),
                          AppColors.primary,
                        ),
                      ),
                      16.gapW,
                      Expanded(
                        child: _buildOccupancyCard(
                          'Maximum',
                          capacity['max'].toString(),
                          AppColors.grey.withOpacity(0.1),
                          AppColors.grey,
                        ),
                      ),
                    ],
                  ),

                  24.gapH,

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: capacity['current']! / capacity['max']!,
                      backgroundColor: AppColors.grey.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStatusTextColor(shelter.status),
                      ),
                      minHeight: 8.h,
                    ),
                  ),

                  8.gapH,

                  Text(
                    '${percentage.toStringAsFixed(0)}% occupied',
                    style: TextStyle(
                      fontSize: D.textSM,
                      color: AppColors.grey,
                    ),
                  ),

                  32.gapH,

                  // Vulnerable Groups
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(D.radiusLG),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vulnerable Groups',
                          style: TextStyle(
                            fontSize: D.textBase,
                            fontWeight: D.bold,
                            color: AppColors.black,
                          ),
                        ),
                        20.gapH,
                        Row(
                          children: [
                            Expanded(
                              child: _buildVulnerableGroupItem(
                                Icons.elderly,
                                shelter.seniors.toString(),
                                'Senior',
                                AppColors.orange.withOpacity(0.1),
                                AppColors.orange,
                              ),
                            ),
                            16.gapW,
                            Expanded(
                              child: _buildVulnerableGroupItem(
                                Icons.child_care,
                                shelter.infants.toString(),
                                'Infant',
                                AppColors.primary.withOpacity(0.1),
                                AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        16.gapH,
                        Row(
                          children: [
                            Expanded(
                              child: _buildVulnerableGroupItem(
                                Icons.accessible,
                                shelter.pwd.toString(),
                                'PWD',
                                Colors.purple.withOpacity(0.1),
                                Colors.purple,
                              ),
                            ),
                            16.gapW,
                            Expanded(
                              child: _buildVulnerableGroupItem(
                                Icons.pregnant_woman,
                                '2',
                                'Pregnant',
                                Colors.pink.withOpacity(0.1),
                                Colors.pink,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  32.gapH,

                  // Amenities
                  Text(
                    'Amenities',
                    style: TextStyle(
                      fontSize: D.textLG,
                      fontWeight: D.bold,
                      color: AppColors.black,
                    ),
                  ),

                  16.gapH,

                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: [
                      _buildAmenityChip('Water', AppColors.primary),
                      _buildAmenityChip('Restroom', AppColors.orange),
                      _buildAmenityChip('First Aid', Colors.red),
                      _buildAmenityChip('Kitchen', Colors.green),
                      _buildAmenityChip('Generator', Colors.purple),
                    ],
                  ),

                  24.gapH,
                ],
              ),
            ),
          ),

          // Directions Button
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SecondaryButton(
                text: 'Get Directions',
                icon: Icons.directions,
                isFilled: true,
                onPressed: () {
                  Navigator.pop(context);
                  onDirections();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyCard(String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(D.radiusLG),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: D.textBase,
              fontWeight: D.bold,
              color: textColor,
            ),
          ),
          4.gapH,
          Text(
            label,
            style: TextStyle(
              fontSize: D.textSM,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVulnerableGroupItem(
    IconData icon,
    String count,
    String label,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(D.radiusMD),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24.w, color: iconColor),
          8.gapW,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: D.textBase,
                  fontWeight: D.bold,
                  color: AppColors.black,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: D.textXS,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: D.textSM,
          fontWeight: D.medium,
          color: color,
        ),
      ),
    );
  }

  Map<String, int> _parseCapacity(String capacity) {
    final parts = capacity.split('/');
    return {
      'current': int.tryParse(parts[0]) ?? 0,
      'max': int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 1,
    };
  }

  String _getStatusText(ShelterStatus status) {
    switch (status) {
      case ShelterStatus.available:
        return 'Available';
      case ShelterStatus.limited:
        return 'Limited';
      case ShelterStatus.full:
        return 'Full';
    }
  }

  Color _getStatusBackgroundColor(ShelterStatus status) {
    switch (status) {
      case ShelterStatus.available:
        return AppColors.lightPrimary;
      case ShelterStatus.limited:
        return AppColors.lightYellow;
      case ShelterStatus.full:
        return Colors.red.withOpacity(0.1);
    }
  }

  Color _getStatusTextColor(ShelterStatus status) {
    switch (status) {
      case ShelterStatus.available:
        return AppColors.primary;
      case ShelterStatus.limited:
        return AppColors.orange;
      case ShelterStatus.full:
        return Colors.red;
    }
  }
}