// lib/features/services/screens/services_screen.dart

import 'package:flutter/material.dart';
import '../../../common/resources/dimensions.dart';
import '../components/case_track_button.dart';
import '../components/services_header.dart';
import '../components/services_page/complaint_page.dart';
import '../components/services_page/service_request_page.dart'; // ✅ ADD THIS
import '../components/services_search_section.dart';
import '../components/featured_program_section.dart';
import '../components/services_section.dart';
import 'programs/track_services_screen.dart';

class ServicesScreen extends StatefulWidget {
  static const routeName = '/services';
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleNotificationTap() {
    print('Notification tapped');
  }

  void _handleSearchChanged(String value) {
    print('Search: $value');
  }

  void _handleFilterTap() {
    print('Filter tapped');
  }

  void _handleTrackCaseTap() {
    Navigator.pushNamed(context, TrackCasesScreen.routeName);
  }

  void _handleRequestServicesTap() {
    // ✅ UPDATE THIS
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ServiceRequestPage()),
    );
  }

  void _handleComplaintsTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ComplaintPage()),
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
                    ServicesHeader(onNotificationTap: _handleNotificationTap),
                    20.gapH,
                    ServicesSearchSection(
                      searchController: _searchController,
                      onSearchChanged: _handleSearchChanged,
                      onFilterTap: _handleFilterTap,
                    ),
                    24.gapH,
                    FeaturedProgramSection(),
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