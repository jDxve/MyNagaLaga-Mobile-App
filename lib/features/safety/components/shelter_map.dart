import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'dart:async';
import '../../../common/resources/assets.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/utils/constant.dart';
import '../models/shelter_data_model.dart';
import '../../../common/utils/distant_caculator.dart';
import 'shelter_map_fullpage.dart';

class ShelterMap extends StatefulWidget {
  final List<ShelterData> shelters;
  final bool isFullScreen;
  final GeoPoint? initialCenter;
  final Function(Map<String, double>)? onDistancesCalculated;

  const ShelterMap({
    super.key,
    required this.shelters,
    this.isFullScreen = false,
    this.initialCenter,
    this.onDistancesCalculated,
  });

  @override
  State<ShelterMap> createState() => ShelterMapState();
}

class ShelterMapState extends State<ShelterMap> with OSMMixinObserver {
  late MapController _mapController;
  bool _markersAdded = false;
  GeoPoint? _userLocation;
  String? _currentRoadKey;
  Timer? _locationTimer;
  final Map<String, double> _shelterDistances = {};
  bool _isInitializing = false;
  bool _isGoingToLocation = false;

  @override
  void initState() {
    super.initState();
    final initialPosition = widget.initialCenter ??
        (widget.shelters.isNotEmpty
            ? GeoPoint(
                latitude: widget.shelters.first.latitude,
                longitude: widget.shelters.first.longitude,
              )
            : Constant.nagaCityCenter);

    _mapController = MapController(
      initPosition: initialPosition,
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
    if (!mounted || _markersAdded || _isInitializing) return;

    if (isReady) {
      _isInitializing = true;
      _markersAdded = true;

      await _addShelterMarkers();
      await _startLocationTracking();
      
      if (!widget.isFullScreen) {
        await _zoomToShowAllShelters();
      }

      _isInitializing = false;
    }
  }

  Future<void> _zoomToShowAllShelters() async {
    if (!mounted || widget.shelters.isEmpty) return;
    try {
      if (widget.shelters.length == 1) {
        await _mapController.setZoom(zoomLevel: 15);
      } else {
        final bounds = _calculateBounds();
        await _mapController.zoomToBoundingBox(
          BoundingBox(
            north: bounds['north']!,
            south: bounds['south']!,
            east: bounds['east']!,
            west: bounds['west']!,
          ),
          paddinInPixel: 50,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Map<String, double> _calculateBounds() {
    double north = widget.shelters.first.latitude;
    double south = widget.shelters.first.latitude;
    double east = widget.shelters.first.longitude;
    double west = widget.shelters.first.longitude;

    for (var shelter in widget.shelters) {
      if (shelter.latitude > north) north = shelter.latitude;
      if (shelter.latitude < south) south = shelter.latitude;
      if (shelter.longitude > east) east = shelter.longitude;
      if (shelter.longitude < west) west = shelter.longitude;
    }

    return {
      'north': north + 0.01,
      'south': south - 0.01,
      'east': east + 0.01,
      'west': west - 0.01,
    };
  }

  Future<void> _startLocationTracking() async {
    try {
      await _updateUserLocation(shouldMoveCamera: false);

      _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        if (mounted) {
          await _updateUserLocation(shouldMoveCamera: false);
        } else {
          timer.cancel();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _userLocation = Constant.nagaCityCenter);
        await _updateCurrentLocationMarker();
        _calculateAllDistances();
      }
    }
  }

  Future<void> _updateUserLocation({bool shouldMoveCamera = false}) async {
    try {
      final position = await _mapController.myLocation();
      final newLocation = GeoPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (_userLocation == null || _hasLocationChanged(_userLocation!, newLocation)) {
        if (mounted) {
          setState(() => _userLocation = newLocation);
        }
        await _updateCurrentLocationMarker();
        _calculateAllDistances();
        
        if (shouldMoveCamera) {
          await _mapController.goToLocation(newLocation);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> goToCurrentLocation() async {
    if (_userLocation == null || !mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not available')),
      );
      return;
    }

    if (_isGoingToLocation) return;

    setState(() => _isGoingToLocation = true);

    try {
      await _mapController.goToLocation(_userLocation!);
      await _mapController.setZoom(zoomLevel: 16);
    } finally {
      if (mounted) {
        setState(() => _isGoingToLocation = false);
      }
    }
  }

  void _calculateAllDistances() {
    if (_userLocation == null) return;

    for (var shelter in widget.shelters) {
      final distance = DistanceCalculator.calculateDistance(
        _userLocation!.latitude,
        _userLocation!.longitude,
        shelter.latitude,
        shelter.longitude,
      );
      _shelterDistances[shelter.id] = distance;
    }

    if (widget.onDistancesCalculated != null && mounted) {
      widget.onDistancesCalculated!(_shelterDistances);
    }
  }

  Future<void> drawRouteToShelter(ShelterData shelter) async {
    if (_userLocation == null || !mounted) return;

    await _removeCurrentRoute();

    try {
      final road = await _mapController.drawRoad(
        _userLocation!,
        GeoPoint(latitude: shelter.latitude, longitude: shelter.longitude),
        roadType: RoadType.car,
        roadOption: const RoadOption(
          roadWidth: 10,
          roadColor: AppColors.primary,
        ),
      );

      if (mounted) {
        _currentRoadKey = road.key;
        await _mapController.zoomToBoundingBox(
          BoundingBox(
            north: [_userLocation!.latitude, shelter.latitude].reduce((a, b) => a > b ? a : b) + 0.01,
            south: [_userLocation!.latitude, shelter.latitude].reduce((a, b) => a < b ? a : b) - 0.01,
            east: [_userLocation!.longitude, shelter.longitude].reduce((a, b) => a > b ? a : b) + 0.01,
            west: [_userLocation!.longitude, shelter.longitude].reduce((a, b) => a < b ? a : b) - 0.01,
          ),
          paddinInPixel: 100,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _updateCurrentLocationMarker() async {
    if (_userLocation == null || !mounted) return;

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
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  bool _hasLocationChanged(GeoPoint oldLoc, GeoPoint newLoc) {
    return DistanceCalculator.calculateDistance(
          oldLoc.latitude,
          oldLoc.longitude,
          newLoc.latitude,
          newLoc.longitude,
        ) > 0.005;
  }

  Future<void> _addShelterMarkers() async {
    if (!mounted || widget.shelters.isEmpty) return;

    for (var shelter in widget.shelters) {
      if (!mounted) return;
      await _mapController.addMarker(
        GeoPoint(latitude: shelter.latitude, longitude: shelter.longitude),
        markerIcon: MarkerIcon(
          assetMarker: AssetMarker(
            image: AssetImage(_getMarkerIcon(shelter.status)),
            scaleAssetImage: 0.5,
          ),
        ),
      );
    }
  }

  Future<void> _removeCurrentRoute() async {
    if (_currentRoadKey != null) {
      try {
        await _mapController.removeRoad(roadKey: _currentRoadKey!);
        _currentRoadKey = null;
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  String _getMarkerIcon(ShelterStatus status) {
    switch (status) {
      case ShelterStatus.available: return Assets.avalableShelter;
      case ShelterStatus.limited: return Assets.limitedShelter;
      case ShelterStatus.full: return Assets.fullShelter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapWidget = Stack(
      children: [
        OSMFlutter(
          controller: _mapController,
          osmOption: OSMOption(
            zoomOption: const ZoomOption(
              initZoom: 13,
              minZoomLevel: 11,
              maxZoomLevel: 18,
            ),
            userTrackingOption: const UserTrackingOption(
              enableTracking: false,
              unFollowUser: true,
            ),
            showDefaultInfoWindow: false,
            enableRotationByGesture: false,
            isPicker: false,
            showZoomController: widget.isFullScreen,
          ),
        ),
        if (widget.isFullScreen)
          Positioned(
            bottom: 20,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _isGoingToLocation ? null : goToCurrentLocation,
              child: _isGoingToLocation
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : Icon(Icons.my_location, color: _userLocation != null ? AppColors.primary : Colors.grey),
            ),
          ),
      ],
    );

    if (widget.isFullScreen) return mapWidget;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShelterMapFullPage(
            shelters: widget.shelters,
            initialShelter: widget.shelters.first,
          ),
        ),
      ),
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