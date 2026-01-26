import 'package:flutter/material.dart';
import '../../../common/resources/dimensions.dart';
import '../components/case_track_button.dart';
import '../components/services_header.dart';
import '../components/services_search_section.dart';
import '../components/featured_program_section.dart';

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

  void _handleCashAssistanceTap() {
    print('Cash Assistance tapped');
  }

  void _handleTrackCaseTap() {
    print('Track Case tapped');
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
                    
                    // Header with Title and Notification Icon
                    ServicesHeader(
                      onNotificationTap: _handleNotificationTap,
                    ),
                    
                    20.gapH,
                    
                    // Search Bar, Filter Button, and Cash Assistance Banner
                    ServicesSearchSection(
                      searchController: _searchController,
                      onSearchChanged: _handleSearchChanged,
                      onFilterTap: _handleFilterTap,
                      onCashAssistanceTap: _handleCashAssistanceTap,
                    ),
                    
                    24.gapH,
                    
                    // Featured Program Section - now uses default data from component
                    const FeaturedProgramSection(),
                    
                    24.gapH,
                  ],
                ),
              ),
            ),
            
            // Floating Track Case Button
            Positioned(
              right: 20.w,
              bottom: 20.h,
              child: TrackCaseButton(
                caseCount: 3,
                onTap: _handleTrackCaseTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}