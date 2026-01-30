import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/search_input.dart';
import '../../home/components/circular_notif.dart';

import '../compnents/shelter_map.dart';
import '../compnents/shelters_list.dart';
import '../models/shelter_data_model.dart';

class DisasterResilienceScreen extends StatefulWidget {
  static const String routeName = '/disaster-resilience';
  const DisasterResilienceScreen({super.key});

  @override
  State<DisasterResilienceScreen> createState() =>
      _DisasterResilienceScreenState();
}

class _DisasterResilienceScreenState extends State<DisasterResilienceScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Sample shelter data
  final List<ShelterData> _shelters = [
    ShelterData(
      name: 'Cabasan Elementary School',
      address: 'Barangay Cabasan, Bacacay, Albay',
      capacity: '45/200',
      status: ShelterStatus.available,
      latitude: 13.3250,
      longitude: 123.8794,
      seniors: 12,
      infants: 5,
      pwd: 3,
    ),
    ShelterData(
      name: 'Bacacay National High School',
      address: 'Poblacion, Bacacay, Albay',
      capacity: '180/200',
      status: ShelterStatus.limited,
      latitude: 13.3280,
      longitude: 123.8820,
      seniors: 12,
      infants: 5,
      pwd: 3,
    ),
    ShelterData(
      name: 'Bacacay Covered Court',
      address: 'Centro, Bacacay, Albay',
      capacity: '200/200',
      status: ShelterStatus.full,
      latitude: 13.3220,
      longitude: 123.8760,
      seniors: 15,
      infants: 8,
      pwd: 5,
    ),
  ];
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                    onTap: () {
                      // Handle notification tap
                    },
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: searchInput(
                hintText: 'Search',
                controller: _searchController,
                onChanged: (value) {
                  // Implement search functionality
                },
              ),
            ),

            // Map Section
            ShelterMap(shelters: _shelters),

            // Shelters List
            SheltersList(shelters: _shelters),
          ],
        ),
      ),
    );
  }
}
