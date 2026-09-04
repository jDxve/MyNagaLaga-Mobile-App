import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynagalaga_mobile_app/common/resources/dimensions.dart';
import 'package:mynagalaga_mobile_app/features/services/components/case_track_button.dart';
import 'package:mynagalaga_mobile_app/features/services/components/services_header.dart';
import 'package:mynagalaga_mobile_app/features/services/components/services_page/complaint_page.dart';
import 'package:mynagalaga_mobile_app/features/services/components/services_page/service_request_page.dart';
import 'package:mynagalaga_mobile_app/features/services/components/services_search_section.dart';
import 'package:mynagalaga_mobile_app/features/services/components/featured_program_section.dart';
import 'package:mynagalaga_mobile_app/features/services/components/services_section.dart';
import 'package:mynagalaga_mobile_app/features/home/components/circular_notif.dart';
import 'package:mynagalaga_mobile_app/features/services/screens/track_services_screen.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  static const routeName = '/services';
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String value) {
    setState(() {});
  }

  void _handleFilterTap() {}

  void _handleTrackCaseTap() {
    Navigator.pushNamed(context, TrackCasesScreen.routeName);
  }

  void _handleRequestServicesTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ServiceRequestPage()),
    );
  }

  void _handleComplaintsTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ComplaintPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.gapH,
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ServicesHeader(), // remove onNotificationTap param
                        CircularNotifButton(), // ✅
                      ],
                    ),
                    20.gapH,
                    ServicesSearchSection(
                      searchController: _searchController,
                      onSearchChanged: _handleSearchChanged,
                      onFilterTap: _handleFilterTap,
                    ),
                    24.gapH,
                    const FeaturedProgramSection(),
                    24.gapH,
                    ServicesSection(
                      onRequestServicesTap: _handleRequestServicesTap,
                      onComplaintsTap: _handleComplaintsTap,
                    ),
                    24.gapH,
                  ],
                ),
              ),
            ),
            Positioned(
              right: 20.w,
              bottom: 20.h,
              child: TrackCaseButton(caseCount: 3, onTap: _handleTrackCaseTap),
            ),
          ],
        ),
      ),
    );
  }
}