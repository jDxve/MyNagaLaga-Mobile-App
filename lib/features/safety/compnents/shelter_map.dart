import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'dart:async';
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
  GeoPoint? _userLocation;
  String? _currentRoadKey;
  Timer? _locationTimer;

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
    _locationTimer?.cancel();
    _mapController.removeObserver(this);
    _mapController.dispose();
    super.dispose();
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (!mounted || _markersAdded) return;
    if (isReady) {
      _markersAdded = true;
      await Future.delayed(const Duration(milliseconds: 500));
      await _startLocationTracking();
      await _addShelterMarkers();
    }
  }

  Future<void> _startLocationTracking() async {
    try {
      await _mapController.enableTracking();
      await _updateUserLocation();

      _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        if (mounted) {
          await _updateUserLocation();
        } else {
          timer.cancel();
        }
      });
    } catch (e) {
      debugPrint('Error enabling tracking: $e');
      _userLocation = Constant.nagaCityCenter;
    }
  }

  Future<void> _updateUserLocation() async {
    try {
      final position = await _mapController.myLocation();
      final newLocation = GeoPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (_userLocation == null ||
          _calculateDistance(
            _userLocation!.latitude,
            _userLocation!.longitude,
            newLocation.latitude,
            newLocation.longitude,
          ) > 0.0001) {
        setState(() {
          _userLocation = newLocation;
        });

        debugPrint('User location updated: ${_userLocation?.latitude}, ${_userLocation?.longitude}');
        await _drawRouteToNearestShelter();
      }
    } catch (e) {
      debugPrint('Error getting user location: $e');
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
              scaleAssetImage: 1,
            ),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));
      } catch (e) {
        debugPrint('Error adding marker for ${shelter.name}: $e');
      }
    }
  }

  Future<void> _drawRouteToNearestShelter() async {
    if (widget.shelters.isEmpty || _userLocation == null) return;

    if (_currentRoadKey != null) {
      try {
        await _mapController.removeRoad(roadKey: _currentRoadKey!);
      } catch (e) {
        debugPrint('Error removing old route: $e');
      }
    }

    ShelterData? nearestShelter;
    double minDistance = double.infinity;

    for (var shelter in widget.shelters) {
      final distance = _calculateDistance(
        _userLocation!.latitude,
        _userLocation!.longitude,
        shelter.latitude,
        shelter.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestShelter = shelter;
      }
    }

    if (nearestShelter == null) return;

    try {
      final road = await _mapController.drawRoad(
        _userLocation!,
        GeoPoint(
          latitude: nearestShelter.latitude,
          longitude: nearestShelter.longitude,
        ),
        roadType: RoadType.car,
        roadOption: RoadOption(
          roadWidth: 10,
          roadColor: AppColors.primary,
        ),
      );

      _currentRoadKey = road.key;
      debugPrint('Route updated to ${nearestShelter.name}: ${road.distance} km');
    } catch (e) {
      debugPrint('Error drawing route: $e');
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    return (dLat * dLat + dLon * dLon);
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
            iconWidget: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.2),
              ),
              child: Center(
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(color: AppColors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.5),
                        blurRadius: 10.r,
                        spreadRadius: 2.r,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          directionArrowMarker: MarkerIcon(
            iconWidget: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.2),
              ),
              child: Center(
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(color: AppColors.white, width: 3),
                  ),
                  child: Icon(
                    Icons.navigation,
                    color: AppColors.white,
                    size: 12.w,
                  ),
                ),
              ),
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
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.12),
              blurRadius: 10.r,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(D.radiusLG),
          child: AbsorbPointer(child: mapWidget),
        ),
      ),
    );
  }
}