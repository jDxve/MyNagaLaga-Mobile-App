import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynagalaga_mobile_app/core/network/data_state.dart';
import 'package:mynagalaga_mobile_app/common/resources/colors.dart';
import 'package:mynagalaga_mobile_app/common/resources/dimensions.dart';
import 'package:mynagalaga_mobile_app/common/widgets/search_input.dart';
import 'package:mynagalaga_mobile_app/features/safety/components/disaster_resilience_widgets.dart';
import 'package:mynagalaga_mobile_app/features/safety/components/shelter_map.dart';
import 'package:mynagalaga_mobile_app/features/safety/components/shelter_card.dart';
import 'package:mynagalaga_mobile_app/features/safety/components/shelter_detail_sheet.dart';
import 'package:mynagalaga_mobile_app/features/safety/components/shelter_map_fullpage.dart';
import 'package:mynagalaga_mobile_app/features/safety/notifier/shelter_notifier.dart';
import 'package:mynagalaga_mobile_app/features/safety/models/shelter_data_model.dart';

class DisasterResilienceScreen extends ConsumerStatefulWidget {
  static const String routeName = '/disaster-resilience';
  const DisasterResilienceScreen({super.key});

  @override
  ConsumerState<DisasterResilienceScreen> createState() =>
      _DisasterResilienceScreenState();
}

class _DisasterResilienceScreenState
    extends ConsumerState<DisasterResilienceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ShelterMapState> _mapKey = GlobalKey<ShelterMapState>();
  Map<String, double> _distances = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sheltersNotifierProvider.notifier).fetchAllShelters();
      ref.read(assignedCenterNotifierProvider.notifier).fetch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateDistances(Map<String, double> distances) {
    if (mounted) setState(() => _distances = distances);
  }

  void _goToShelterMap(BuildContext context, List<ShelterData> shelters, ShelterData target) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShelterMapFullPage(
          shelters: shelters,
          initialShelter: target,
          targetShelter: target,
        ),
      ),
    );
  }

  Widget _buildAssignedBanner(
    BuildContext context,
    List<ShelterData> shelters,
    AssignedCenterData assigned,
    double? distance,
  ) {
    final match = shelters.firstWhere(
      (s) => s.id == assigned.centerId,
      orElse: () => fallbackShelterFromAssignedCenter(assigned),
    );
    return AssignedCenterBanner(
      assigned: assigned,
      shelters: shelters,
      distanceInKm: distance,
      onGoToCenter: () => _goToShelterMap(context, shelters, match),
      onChangeShelter: (shelter) => _goToShelterMap(context, shelters, shelter),
    );
  }

  Widget _buildSuccessBody(BuildContext context, shelterData) {
    if (shelterData.shelters.isEmpty) return const DrEmptyState();

    final assignedState = ref.watch(assignedCenterNotifierProvider);
    final sortedShelters = sortSheltersByDistance(shelterData.shelters, _distances);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
                child: searchInput(
                  hintText: 'Search evacuation centers...',
                  controller: _searchController,
                  onChanged: (value) {},
                ),
              ),
              ShelterMap(
                key: _mapKey,
                shelters: shelterData.shelters,
                onDistancesCalculated: _updateDistances,
              ),
              assignedState.when(
                started: () => const SizedBox.shrink(),
                loading: () => const AssignedBannerLoading(),
                error: (_) => const SizedBox.shrink(),
                success: (assigned) {
                  final distance = _distances[assigned.centerId];
                  return _buildAssignedBanner(context, shelterData.shelters, assigned, distance);
                },
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Evacuation Centers',
                      style: TextStyle(
                        fontSize: D.textLG,
                        fontWeight: D.bold,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      '${shelterData.shelters.length} Centers',
                      style: TextStyle(
                        fontSize: D.textSM,
                        color: AppColors.grey,
                        fontWeight: D.semiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final shelter = sortedShelters[index];
                final distance = _distances[shelter.id];
                return ShelterCard(
                  shelter: shelter,
                  distanceInKm: distance,
                  onTap: () {
                    ShelterDetailsSheet.show(
                      context,
                      shelter,
                      distance,
                      () {
                        Navigator.pop(context);
                        _goToShelterMap(context, shelterData.shelters, shelter);
                      },
                    );
                  },
                );
              },
              childCount: sortedShelters.length,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);
    final sheltersState = ref.watch(sheltersNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrHeader(onNotifTap: () {}, notifCount: 3),
            Expanded(
              child: sheltersState.when(
                started: () => const Center(child: Text('Loading evacuation centers...')),
                loading: () => const Center(child: CircularProgressIndicator()),
                success: (data) => _buildSuccessBody(context, data),
                error: (error) => DrErrorState(
                  message: error,
                  onRetry: () => ref
                      .read(sheltersNotifierProvider.notifier)
                      .fetchAllShelters(forceRefresh: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}