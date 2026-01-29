import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../models/shelter_data_model.dart';

class ShelterCard extends StatelessWidget {
  final ShelterData shelter;

  const ShelterCard({super.key, required this.shelter});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(D.radiusLG),
        border: Border.all(
          color: AppColors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getStatusBackgroundColor(shelter.status),
                  borderRadius: BorderRadius.circular(D.radiusSM),
                ),
                child: Text(
                  _getStatusText(shelter.status),
                  style: TextStyle(
                    fontSize: D.textXS,
                    fontWeight: D.semiBold,
                    color: _getStatusTextColor(shelter.status),
                  ),
                ),
              ),
            ],
          ),
          8.gapH,
          Text(
            shelter.address,
            style: TextStyle(
              fontSize: D.textSM,
              color: AppColors.grey,
            ),
          ),
          12.gapH,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Capacity:',
                style: TextStyle(
                  fontSize: D.textSM,
                  fontWeight: D.medium,
                  color: AppColors.grey,
                ),
              ),
              Text(
                shelter.capacity,
                style: TextStyle(
                  fontSize: D.textSM,
                  fontWeight: D.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          12.gapH,
          Row(
            children: [
              _buildIconInfo(Icons.elderly, shelter.seniors.toString(), 'Seniors'),
              16.gapW,
              _buildIconInfo(Icons.child_care, shelter.infants.toString(), 'Infants'),
              16.gapW,
              _buildIconInfo(Icons.accessible, shelter.pwd.toString(), 'PWD'),
            ],
          ),
        ],
      ),
    );
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

  Widget _buildIconInfo(IconData icon, String count, String label) {
    return Row(
      children: [
        Icon(icon, size: D.iconSM, color: AppColors.grey),
        4.gapW,
        Text(
          count,
          style: TextStyle(
            fontSize: D.textSM,
            fontWeight: D.semiBold,
            color: AppColors.black,
          ),
        ),
        4.gapW,
        Text(
          label,
          style: TextStyle(
            fontSize: D.textXS,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }
}