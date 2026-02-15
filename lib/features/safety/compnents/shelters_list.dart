import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../models/shelter_data_model.dart';
import 'shelter_card.dart';
import 'shelter_detail_sheet.dart';

import 'shelter_map.dart';
import 'shelter_map_fullpage.dart';

class SheltersList extends StatelessWidget {
  final List<ShelterData> shelters;
  final Map<String, double> distances;
  final GlobalKey<ShelterMapState>? mapKey;

  const SheltersList({
    super.key,
    required this.shelters,
    this.distances = const {},
    this.mapKey,
  });

  List<ShelterData> _getSortedShelters() {
    if (distances.isEmpty) return shelters;

    final shelterList = List<ShelterData>.from(shelters);
    shelterList.sort((a, b) {
      final distA = distances[a.id] ?? double.infinity;
      final distB = distances[b.id] ?? double.infinity;
      return distA.compareTo(distB);
    });

    return shelterList;
  }

  @override
  Widget build(BuildContext context) {
    final sortedShelters = _getSortedShelters();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                  '${shelters.length} Centers',
                  style: TextStyle(
                    fontSize: D.textSM,
                    color: AppColors.grey,
                    fontWeight: D.semiBold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: sortedShelters.length,
              itemBuilder: (context, index) {
                final shelter = sortedShelters[index];
                final distance = distances[shelter.id];

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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShelterMapFullPage(
                              shelters: shelters,
                              initialShelter: shelter,
                              targetShelter: shelter,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}