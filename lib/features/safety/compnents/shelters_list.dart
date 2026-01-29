import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../models/shelter_data_model.dart';
import 'shelter_card.dart';
import 'shelter_map_fullpage.dart'; // Ensure this is imported

class SheltersList extends StatelessWidget {
  final List<ShelterData> shelters;

  const SheltersList({super.key, required this.shelters});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Text(
              'Nearby Shelters',
              style: TextStyle(
                fontSize: D.textLG,
                fontWeight: D.bold,
                color: AppColors.black,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: shelters.length,
              itemBuilder: (context, index) {
                final shelter = shelters[index];
                
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShelterMapFullPage(
                          shelters: shelters,
                          initialShelter: shelter,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: ShelterCard(shelter: shelter),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}