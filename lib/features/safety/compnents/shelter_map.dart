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
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        await _startLocationTracking();
        await _addShelterMarkers();
      }
    }
  }

  Future<void> _startLocationTracking() async {
    try {
      await _mapController.enableTracking();
      await _updateUserLocation();

      _locationTimer = Timer.periodic(
        const Duration(seconds: 5),
        (timer) async {
          if (mounted) {
            await _updateUserLocation();
          } else {
            timer.cancel();
          }
        },
      );
    } catch (e) {
      debugPrint('❌ Error enabling tracking: $e');
      if (mounted) {
        setState(() {
          _userLocation = Constant.nagaCityCenter;
        });
        await _updateCurrentLocationMarker();
      }
    }
  }

  Future<void> _updateUserLocation() async {
    try {
      final position = await _mapController.myLocation();
      final newLocation = GeoPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (_userLocation == null || _hasLocationChanged(_userLocation!, newLocation)) {
        if (mounted) {
          setState(() {
            _userLocation = newLocation;
          });
        }

        debugPrint('📍 User location: ${_userLocation?.latitude}, ${_userLocation?.longitude}');
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        await _updateCurrentLocationMarker();
        await _drawRouteToNearestShelter();
      }
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
    }
  }

  Future<void> _updateCurrentLocationMarker() async {
    if (_userLocation == null || !mounted) return;

    try {
      await _mapController.removeMarker(_userLocation!);
    } catch (e) {
      debugPrint('No existing current location marker to remove');
    }

    await Future.delayed(const Duration(milliseconds: 200));

    try {
      await _mapController.addMarker(
        _userLocation!,
        markerIcon: MarkerIcon(
          assetMarker: AssetMarker(
            image: AssetImage(Assets.currentLoc),
            scaleAssetImage: 1.5,
          ),
        ),
      );
      debugPrint('📍 Current location marker updated');
    } catch (e) {
      debugPrint('❌ Error adding current location marker: $e');
    }
  }

  bool _hasLocationChanged(GeoPoint oldLocation, GeoPoint newLocation) {
    final distance = _calculateDistance(
      oldLocation.latitude,
      oldLocation.longitude,
      newLocation.latitude,
      newLocation.longitude,
    );
    return distance > 0.0001;
  }

  Future<void> _addShelterMarkers() async {
    if (!mounted) return;

    int successCount = 0;
    for (var shelter in widget.shelters) {
      if (!mounted) return;

      try {
        await _mapController.addMarker(
          GeoPoint(latitude: shelter.latitude, longitude: shelter.longitude),
          markerIcon: MarkerIcon(
            assetMarker: AssetMarker(
              image: AssetImage(_getMarkerIcon(shelter.status)),
              scaleAssetImage: 1,
            ),
          ),
        );
        successCount++;
        debugPrint('✅ Added marker $successCount/${widget.shelters.length}: ${shelter.name}');

        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        debugPrint('❌ Error adding marker for ${shelter.name}: $e');
      }
    }

    debugPrint('🎯 Successfully added $successCount/${widget.shelters.length} markers');
  }

  Future<void> _drawRouteToNearestShelter() async {
    if (widget.shelters.isEmpty || _userLocation == null || !mounted) return;

    await _removeCurrentRoute();

    final nearestShelter = _findNearestShelter();
    if (nearestShelter == null || !mounted) return;

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

      if (mounted) {
        _currentRoadKey = road.key;
        debugPrint('🛣️ Route to ${nearestShelter.name}: ${road.distance?.toStringAsFixed(2)} km');
      }
    } catch (e) {
      debugPrint('❌ Error drawing route: $e');
    }
  }

  Future<void> _removeCurrentRoute() async {
    if (_currentRoadKey != null) {
      try {
        await _mapController.removeRoad(roadKey: _currentRoadKey!);
      } catch (e) {
        debugPrint('❌ Error removing route: $e');
      }
    }
  }

  ShelterData? _findNearestShelter() {
    if (_userLocation == null) return null;

    ShelterData? nearest;
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
        nearest = shelter;
      }
    }

    return nearest;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    return (dLat * dLat + dLon * dLon);
  }

  String _getMarkerIcon(ShelterStatus status) {
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
    final mapWidget = OSMFlutter(
      controller: _mapController,
      osmOption: OSMOption(
        zoomOption: const ZoomOption(
          initZoom: 14,
          minZoomLevel: 12,
          maxZoomLevel: 18,
        ),
        userTrackingOption: UserTrackingOption(
          enableTracking: true,
          unFollowUser: false,
        ),
        showDefaultInfoWindow: false,
        enableRotationByGesture: false,
        isPicker: false,
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