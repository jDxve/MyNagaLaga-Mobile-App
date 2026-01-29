import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../../common/utils/constant.dart';
import '../../../../common/widgets/primary_button.dart';


class MapLocationPicker extends StatefulWidget {
  final Function(String address, double lat, double lng) onLocationSelected;

  const MapLocationPicker({super.key, required this.onLocationSelected});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> with OSMMixinObserver {
  late MapController _mapController;
  GeoPoint? _selectedLocation;
  String _selectedAddress = 'Fetching exact address...';
  bool _isLoadingLocation = false;
  bool _isLoadingAddress = false;
  bool _mapReady = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _mapController = MapController(
      initPosition: Constant.nagaCityCenter, // Used Constant here
      areaLimit: Constant.nagaBoundingBox,   // Used Constant here
    );
    _mapController.addObserver(this);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController.removeObserver(this);
    _mapController.dispose();
    super.dispose();
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (!mounted) return;
    setState(() => _mapReady = isReady);
    if (isReady) {
      _updateLocationInfo(Constant.nagaCityCenter); // Used Constant here
    }
  }

  @override
  void onRegionChanged(Region region) {
    super.onRegionChanged(region);
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 700), () {
      _updateLocationInfo(region.center);
    });
  }

  Future<void> _updateLocationInfo(GeoPoint position) async {
    if (!mounted) return;
    setState(() {
      _selectedLocation = position;
      _isLoadingAddress = true;
    });

    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 4));

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        List<String> addressParts = [];
        
        if (p.street != null && p.street!.isNotEmpty && !p.street!.contains('+')) {
          addressParts.add(p.street!);
        }
        if (p.subLocality != null && p.subLocality!.isNotEmpty) {
          addressParts.add(p.subLocality!);
        }
        if (p.locality != null && p.locality!.isNotEmpty) {
          addressParts.add(p.locality!);
        }

        setState(() {
          _selectedAddress = addressParts.isEmpty 
              ? "Unknown Location" 
              : addressParts.join(', ');
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = "Unknown Address";
      });
    } finally {
      if (mounted) setState(() => _isLoadingAddress = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!_mapReady) return;
    setState(() => _isLoadingLocation = true);
    try {
      await _mapController.currentLocation(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enable GPS in settings.")),
      );
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          OSMFlutter(
            controller: _mapController,
            osmOption: OSMOption(
              userLocationMarker: UserLocationMaker(
                personMarker: MarkerIcon(
                  icon: Icon(Icons.person_pin, color: AppColors.blue, size: 48.w),
                ),
                directionArrowMarker: const MarkerIcon(
                  icon: Icon(Icons.navigation, color: AppColors.blue),
                ),
              ),
              isPicker: true,
              zoomOption: const ZoomOption(
                initZoom: 16,
                minZoomLevel: 12,
                maxZoomLevel: 19,
              ),
            ),
          ),

          // Circle Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10.h,
            left: 16.w,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10.r, spreadRadius: 1)
                  ],
                ),
                child: Icon(Icons.arrow_back_ios_new, color: AppColors.black, size: 18.w),
              ),
            ),
          ),

          // Center Pin Icon
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.h),
              child: Icon(
                Icons.location_on, 
                color: AppColors.primary, 
                size: 50.w,
                shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 10.r)],
              ),
            ),
          ),

          // Top Instruction
          Positioned(
            top: MediaQuery.of(context).padding.top + 15.h,
            left: 0, right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(D.radiusXXL),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8.r)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, color: AppColors.primary, size: 16.w),
                    8.gapW,
                    Text('Slide map to adjust pin', style: TextStyle(fontWeight: D.semiBold, fontSize: 13.f)),
                  ],
                ),
              ),
            ),
          ),

          // GPS Button
          Positioned(
            right: 16.w,
            bottom: 280.h, 
            child: FloatingActionButton(
              heroTag: 'gps_btn',
              elevation: 2,
              backgroundColor: Colors.white,
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              child: _isLoadingLocation 
                ? SizedBox(width: 24.w, height: 24.w, child: const CircularProgressIndicator(strokeWidth: 2)) 
                : Icon(Icons.gps_fixed, color: AppColors.primary, size: D.iconMD),
            ),
          ),

          // Bottom Info Card
          Positioned(
            left: 16.w, right: 16.w, bottom: 20.h,
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(D.radiusXL),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20.r, offset: const Offset(0, -4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18.w),
                      8.gapW,
                      Text(
                        'Selected Location:', 
                        style: TextStyle(fontSize: D.textSM, color: AppColors.grey, fontWeight: D.medium),
                      ),
                    ],
                  ),
                  12.gapH,
                  Text(
                    _selectedAddress, 
                    style: TextStyle(
                      fontSize: 16.f, 
                      fontWeight: D.bold, 
                      color: AppColors.black,
                      height: 1.4,
                    ),
                    softWrap: true,
                  ),
                  8.gapH,
                  if (_selectedLocation != null)
                    Text(
                      '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(fontSize: 11.f, color: AppColors.grey.withOpacity(0.7), letterSpacing: 0.5),
                    ),
                  24.gapH,
                  PrimaryButton(
                    text: 'Confirm Location',
                    onPressed: () {
                      if (!_isLoadingAddress && _selectedLocation != null) {
                        widget.onLocationSelected(
                          _selectedAddress, 
                          _selectedLocation!.latitude, 
                          _selectedLocation!.longitude
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}