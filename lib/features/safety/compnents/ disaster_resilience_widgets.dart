import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/utils/distant_caculator.dart';
import '../../home/components/circular_notif.dart';
import '../models/shelter_data_model.dart';

class DrHeader extends StatelessWidget {
  final VoidCallback onNotifTap;
  final int notifCount;

  const DrHeader({super.key, required this.onNotifTap, this.notifCount = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Disaster Resilience',
            style: TextStyle(
              fontSize: D.textXL,
              fontWeight: D.bold,
              color: AppColors.black,
            ),
          ),
          const CircularNotifButton(),
        ],
      ),
    );
  }
}

class DrEmptyState extends StatelessWidget {
  const DrEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work_outlined, size: 64, color: AppColors.grey),
          16.gapH,
          Text(
            'No evacuation centers available',
            style: TextStyle(fontSize: D.textBase, color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}

class DrErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const DrErrorState({super.key, this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            16.gapH,
            Text(
              'Failed to load evacuation centers',
              style: TextStyle(
                fontSize: D.textBase,
                fontWeight: D.semiBold,
                color: AppColors.black,
              ),
            ),
            8.gapH,
            Text(
              message ?? 'Unknown error occurred',
              style: TextStyle(fontSize: D.textSM, color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            24.gapH,
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AssignedBannerLoading extends StatelessWidget {
  const AssignedBannerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          16.gapW,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 10.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                6.gapH,
                Container(
                  height: 14.h,
                  width: 180.w,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AssignedCenterBanner extends StatelessWidget {
  final AssignedCenterData assigned;
  final List<ShelterData> shelters;
  final VoidCallback onGoToCenter;
  final Function(ShelterData) onChangeShelter;
  final double? distanceInKm;

  const AssignedCenterBanner({
    super.key,
    required this.assigned,
    required this.shelters,
    required this.onGoToCenter,
    required this.onChangeShelter,
    this.distanceInKm,
  });

  void _showChangeShelterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeShelterSheet(
        shelters: shelters,
        currentCenterId: assigned.centerId,
        onSelected: onChangeShelter,
      ),
    );
  }

  ({Color color, String label, IconData icon}) get _statusConfig {
    final int current = assigned.currentOccupancy;
    final int max = assigned.maxCapacity;
    final double pct = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    if (pct >= 1.0) {
      return (
        color: const Color(0xFFE53935),
        label: 'Full',
        icon: Icons.block_rounded,
      );
    } else if (pct >= 0.75) {
      return (
        color: const Color(0xFFF57C00),
        label: 'Limited',
        icon: Icons.warning_amber_rounded,
      );
    }
    return (
      color: AppColors.primary,
      label: 'Available',
      icon: Icons.check_circle_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int current = assigned.currentOccupancy;
    final int max = assigned.maxCapacity;
    final double pct = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    final cfg = _statusConfig;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
          child: Text(
            'Your Assigned Center',
            style: TextStyle(
              fontSize: D.textLG,
              fontWeight: D.bold,
              color: AppColors.black,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.18),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BannerTopSection(
                assigned: assigned,
                statusColor: cfg.color,
                statusLabel: cfg.label,
                statusIcon: cfg.icon,
                onGoToCenter: onGoToCenter,
                distanceInKm: distanceInKm,
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.grey.withOpacity(0.1),
              ),
              _BannerBottomSection(
                current: current,
                max: max,
                pct: pct,
                statusColor: cfg.color,
                onChangeTap: () => _showChangeShelterSheet(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BannerTopSection extends StatelessWidget {
  final AssignedCenterData assigned;
  final Color statusColor;
  final String statusLabel;
  final IconData statusIcon;
  final VoidCallback onGoToCenter;
  final double? distanceInKm;

  const _BannerTopSection({
    required this.assigned,
    required this.statusColor,
    required this.statusLabel,
    required this.statusIcon,
    required this.onGoToCenter,
    this.distanceInKm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.home_work_rounded,
              color: AppColors.primary,
              size: 24.w,
            ),
          ),
          14.gapW,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusPill(
                      color: statusColor,
                      icon: statusIcon,
                      label: statusLabel,
                    ),
                    5.gapH,
                    Text(
                      assigned.centerName,
                      style: TextStyle(
                        fontSize: D.textBase,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                        height: 1.25,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
                4.gapH,
                Row(
                  children: [
                    if (assigned.barangayName.isNotEmpty) ...[
                      Icon(
                        Icons.location_on_outlined,
                        size: 11.w,
                        color: AppColors.grey,
                      ),
                      3.gapW,
                      Flexible(
                        child: Text(
                          assigned.barangayName,
                          style: TextStyle(
                            fontSize: D.textXS,
                            color: AppColors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (distanceInKm != null) ...[
                      if (assigned.barangayName.isNotEmpty) 8.gapW,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.near_me_rounded,
                              size: 10.w,
                              color: AppColors.primary,
                            ),
                            3.gapW,
                            Text(
                              DistanceCalculator.formatDistance(distanceInKm!),
                              style: TextStyle(
                                fontSize: D.textXS,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          10.gapW,
          GoButton(onTap: onGoToCenter),
        ],
      ),
    );
  }
}

class _BannerBottomSection extends StatelessWidget {
  final int current;
  final int max;
  final double pct;
  final Color statusColor;
  final VoidCallback onChangeTap;

  const _BannerBottomSection({
    required this.current,
    required this.max,
    required this.pct,
    required this.statusColor,
    required this.onChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 11.h, 14.w, 13.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      size: 13.w,
                      color: AppColors.grey,
                    ),
                    5.gapW,
                    Text(
                      'Occupancy',
                      style: TextStyle(
                        fontSize: D.textXS,
                        color: AppColors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$current / $max',
                        style: TextStyle(
                          fontSize: D.textXS,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                8.gapH,
                OccupancyBar(pct: pct, statusColor: statusColor, height: 8),
              ],
            ),
          ),
          16.gapW,
          ChangeButton(onTap: onChangeTap),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _StatusPill({
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9.w, color: color),
          3.gapW,
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class OccupancyBar extends StatelessWidget {
  final double pct;
  final Color statusColor;
  final double height;

  const OccupancyBar({
    super.key,
    required this.pct,
    required this.statusColor,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height.h,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        FractionallySizedBox(
          widthFactor: pct,
          child: Container(
            height: height.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor.withOpacity(0.7), statusColor],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class GoButton extends StatefulWidget {
  final VoidCallback onTap;
  const GoButton({super.key, required this.onTap});

  @override
  State<GoButton> createState() => _GoButtonState();
}

class _GoButtonState extends State<GoButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(_pressed ? 0.15 : 0.32),
                blurRadius: _pressed ? 4 : 10,
                offset: Offset(0, _pressed ? 1 : 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_rounded, color: Colors.white, size: 16.w),
              6.gapW,
              Text(
                'Go',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: D.textSM,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangeButton extends StatefulWidget {
  final VoidCallback onTap;
  const ChangeButton({super.key, required this.onTap});

  @override
  State<ChangeButton> createState() => _ChangeButtonState();
}

class _ChangeButtonState extends State<ChangeButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: _pressed
                ? AppColors.primary.withOpacity(0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.35),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.swap_horiz_rounded,
                color: AppColors.primary,
                size: 15.w,
              ),
              5.gapW,
              Text(
                'Change',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: D.textXS,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangeShelterSheet extends StatelessWidget {
  final List<ShelterData> shelters;
  final String currentCenterId;
  final Function(ShelterData) onSelected;

  const ChangeShelterSheet({
    super.key,
    required this.shelters,
    required this.currentCenterId,
    required this.onSelected,
  });

  Color _statusColor(ShelterStatus status) {
    switch (status) {
      case ShelterStatus.available:
        return AppColors.primary;
      case ShelterStatus.limited:
        return const Color(0xFFF57C00);
      case ShelterStatus.full:
        return const Color(0xFFE53935);
    }
  }

  String _statusLabel(ShelterStatus status) {
    switch (status) {
      case ShelterStatus.available:
        return 'Available';
      case ShelterStatus.limited:
        return 'Limited';
      case ShelterStatus.full:
        return 'Full';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 12.h),
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.swap_horiz_rounded,
                  color: AppColors.primary,
                  size: 20.w,
                ),
              ),
              14.gapW,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Evacuation Center',
                      style: TextStyle(
                        fontSize: D.textLG,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    3.gapH,
                    Text(
                      'Tap a center to get directions there',
                      style: TextStyle(
                        fontSize: D.textXS,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          14.gapH,
          Divider(height: 1, color: AppColors.grey.withOpacity(0.1)),
          12.gapH,
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.52,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: shelters.length,
              itemBuilder: (context, index) {
                final shelter = shelters[index];
                final isCurrent = shelter.id == currentCenterId;
                final isFull = shelter.status == ShelterStatus.full;
                final color = _statusColor(shelter.status);
                final pct = shelter.maxCapacity > 0
                    ? (shelter.currentOccupancy / shelter.maxCapacity).clamp(
                        0.0,
                        1.0,
                      )
                    : 0.0;

                return GestureDetector(
                  onTap: isFull
                      ? null
                      : () {
                          Navigator.pop(context);
                          onSelected(shelter);
                        },
                  child: AnimatedOpacity(
                    opacity: isFull ? 0.4 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: _ShelterSheetItem(
                      shelter: shelter,
                      isCurrent: isCurrent,
                      color: color,
                      statusLabel: _statusLabel(shelter.status),
                      pct: pct,
                    ),
                  ),
                );
              },
            ),
          ),
          24.gapH,
        ],
      ),
    );
  }
}

class _ShelterSheetItem extends StatelessWidget {
  final ShelterData shelter;
  final bool isCurrent;
  final Color color;
  final String statusLabel;
  final double pct;

  const _ShelterSheetItem({
    required this.shelter,
    required this.isCurrent,
    required this.color,
    required this.statusLabel,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.primary.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isCurrent
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.grey.withOpacity(0.15),
          width: isCurrent ? 1.5 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        shelter.name,
                        style: TextStyle(
                          fontSize: D.textSM,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrent) ...[
                      8.gapW,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Assigned',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                5.gapH,
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 11.w,
                      color: AppColors.grey,
                    ),
                    3.gapW,
                    Expanded(
                      child: Text(
                        shelter.address,
                        style: TextStyle(
                          fontSize: D.textXS,
                          color: AppColors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                9.gapH,
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          4.gapW,
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: D.textXS,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    10.gapW,
                    Expanded(
                      child: OccupancyBar(
                        pct: pct,
                        statusColor: color,
                        height: 5,
                      ),
                    ),
                    10.gapW,
                    Text(
                      '${shelter.currentOccupancy}/${shelter.maxCapacity}',
                      style: TextStyle(
                        fontSize: D.textXS,
                        color: AppColors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          12.gapW,
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.primary
                  : AppColors.grey.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCurrent ? Icons.check_rounded : Icons.chevron_right_rounded,
              color: isCurrent ? Colors.white : AppColors.grey,
              size: 17.w,
            ),
          ),
        ],
      ),
    );
  }
}
