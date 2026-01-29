import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import '../models/shelter_data_model.dart';
import 'shelter_map.dart';

class ShelterMapFullPage extends StatelessWidget {
  final List<ShelterData> shelters;
  final ShelterData initialShelter;

  const ShelterMapFullPage({
    super.key,
    required this.shelters,
    required this.initialShelter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ShelterMap(
            shelters: shelters,
            isFullScreen: true,
            initialCenter: GeoPoint(
              latitude: initialShelter.latitude,
              longitude: initialShelter.longitude,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: FloatingActionButton.small(
              backgroundColor: Colors.white,
              child: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}