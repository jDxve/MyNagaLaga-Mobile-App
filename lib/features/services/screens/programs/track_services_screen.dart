import 'package:flutter/material.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../components/track_case/top_nav_services.dart';
import '../../components/track_case/track_case_indicator.dart';

class TrackCasesScreen extends StatefulWidget {
  static const routeName = '/track-cases';
  const TrackCasesScreen({super.key});

  @override
  State<TrackCasesScreen> createState() => _TrackCasesScreenState();
}

class _TrackCasesScreenState extends State<TrackCasesScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    D.init(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(
        title: 'Track Cases Request',
      ),
      body: Column(
        children: [
          TopNavTrack(
            selectedIndex: _selectedTab,
            onTabChanged: (index) {
              setState(() {
                _selectedTab = index;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: 5,
              itemBuilder: (context, index) {
                final status = index == 0
                    ? 'Pending'
                    : index == 1
                        ? 'Under Review'
                        : index == 2
                            ? 'Ready'
                            : 'Closed';

                return TrackCaseCard(
                  caseId: 'BRQ-2026-00${index + 1}',
                  title: 'SANGGAWADAN',
                  status: status,
                  description: index == 1
                      ? 'In Progress: A Social Worker is currently verifying your documents.'
                      : index == 2
                          ? 'Action Required: Please visit the designated office to claim.'
                          : 'Your request has been processed.',
                  updatedDate: '12/25/2026',
                  showRateButton: status.toLowerCase() == 'closed',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}