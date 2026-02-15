import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/search_input.dart';
import '../../home/components/circular_notif.dart';
import '../compnents/shelter_map.dart';
import '../compnents/shelters_list.dart';
import '../notifier/shelter_notifier.dart';

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
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateDistances(Map<String, double> distances) {
    if (mounted) {
      setState(() {
        _distances = distances;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);
    final sheltersState = ref.watch(sheltersNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                  circularNotif(
                    notificationCount: 3,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: searchInput(
                hintText: 'Search',
                controller: _searchController,
                onChanged: (value) {},
              ),
            ),
            Expanded(
              child: sheltersState.when(
                started: () => const Center(
                  child: Text('Loading evacuation centers...'),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                success: (data) {
                  if (data.shelters.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home_work_outlined,
                            size: 64,
                            color: AppColors.grey,
                          ),
                          16.gapH,
                          Text(
                            'No evacuation centers available',
                            style: TextStyle(
                              fontSize: D.textBase,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      ShelterMap(
                        key: _mapKey,
                        shelters: data.shelters,
                        onDistancesCalculated: _updateDistances,
                      ),
                      SheltersList(
                        shelters: data.shelters,
                        distances: _distances,
                        mapKey: _mapKey,
                      ),
                    ],
                  );
                },
                error: (error) => Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
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
                          error ?? 'Unknown error occurred',
                          style: TextStyle(
                            fontSize: D.textSM,
                            color: AppColors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        24.gapH,
                        ElevatedButton.icon(
                          onPressed: () {
                            ref
                                .read(sheltersNotifierProvider.notifier)
                                .fetchAllShelters();
                          },
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}