import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import '../../../common/resources/assets.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/utils/constant.dart';
import '../models/shelter_data_model.dart';
import 'shelter_map_fullpage.dart';

class ShelterMap extends StatefulWidget {
  final List<ShelterData> shelters;
  final bool isFullScreen;
  final GeoPoint? initialCenter;

  const ShelterMap({
    super.key,
    required this.shelters,
    this.isFullScreen = false,
    this.initialCenter,
  });

  @override
  State<ShelterMap> createState() => _ShelterMapState();
}

class _ShelterMapState extends State<ShelterMap> with OSMMixinObserver {
  late MapController _mapController;
  bool _markersAdded = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController(
      initPosition: widget.initialCenter ?? Constant.nagaCityCenter,
      areaLimit: Constant.nagaBoundingBox,
    );
    _mapController.addObserver(this);
  }

  @override
  void dispose() {
    _mapController.removeObserver(this);
    _mapController.dispose();
    super.dispose();
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (!mounted || _markersAdded) return;
    if (isReady) {
      _markersAdded = true;
      await Future.delayed(const Duration(milliseconds: 1500));
      await _addShelterMarkers();
    }
  }

  Future<void> _addShelterMarkers() async {
    for (var shelter in widget.shelters) {
      try {
        await _mapController.addMarker(
          GeoPoint(latitude: shelter.latitude, longitude: shelter.longitude),
          markerIcon: MarkerIcon(
            assetMarker: AssetMarker(
              image: AssetImage(_getMarkerPngPath(shelter.status)),
              scaleAssetImage: 2,
            ),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        debugPrint('Error adding marker for ${shelter.name}: $e');
      }
    }
  }

  String _getMarkerPngPath(ShelterStatus status) {
    switch (status) {
      case ShelterStatus.available:
        return Assets.avalableShelter;
      case ShelterStatus.limited:
        return Assets.limitedShelter;
      case ShelterStatus.full:
        return Assets.fullShelter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget mapWidget = OSMFlutter(
      controller: _mapController,
      osmOption: OSMOption(
        zoomOption: const ZoomOption(initZoom: 14, minZoomLevel: 10),
        userLocationMarker: UserLocationMaker(
          personMarker: MarkerIcon(
            icon: Icon(
              Icons.person_pin_circle,
              color: AppColors.primary,
              size: 48,
            ),
          ),
          directionArrowMarker: MarkerIcon(
            icon: Icon(
              Icons.location_searching,
              color: AppColors.primary,
              size: 48,
            ),
          ),
        ),
      ),
    );

    if (widget.isFullScreen) return mapWidget;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShelterMapFullPage(
              shelters: widget.shelters,
              initialShelter: widget.shelters.first,
            ),
          ),
        );
      },
      child: Container(
        height: 200.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(D.radiusLG),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10.r)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(D.radiusLG),
          child: AbsorbPointer(child: mapWidget),
        ),
      ),
    );
  }
}