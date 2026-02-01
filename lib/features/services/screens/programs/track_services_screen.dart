import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../common/models/dio/data_state.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../auth/notifier/auth_session_notifier.dart';
import '../../components/track_case/top_nav_services.dart';
import '../../components/track_case/track_case_indicator.dart';
import '../../notifier/tracking_notifier.dart';

class TrackCasesScreen extends ConsumerStatefulWidget {
  static const routeName = '/track-cases';
  const TrackCasesScreen({super.key});

  @override
  ConsumerState<TrackCasesScreen> createState() => _TrackCasesScreenState();
}

class _TrackCasesScreenState extends ConsumerState<TrackCasesScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadData();
      _startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    super.dispose();
  }

  void _loadData() {
    final session = ref.read(authSessionProvider);
    if (session.userId == null) return;

    final mobileUserId = session.userId!;

    switch (_selectedTab) {
      case 0:
        ref.read(programsTrackingNotifierProvider.notifier).fetchPrograms(
              mobileUserId: mobileUserId,
            );
        break;
      case 1:
        ref.read(badgeTrackingNotifierProvider.notifier).fetchBadgeRequests(
              mobileUserId: mobileUserId,
            );
        break;
      case 2:
        ref.read(servicesTrackingNotifierProvider.notifier).fetchServices(
              mobileUserId: mobileUserId,
            );
        break;
      case 3:
        ref.read(complaintsTrackingNotifierProvider.notifier).fetchComplaints(
              mobileUserId: mobileUserId,
            );
        break;
    }
  }

  void _startAutoRefresh() {
    switch (_selectedTab) {
      case 0:
        ref.read(programsTrackingNotifierProvider.notifier).startAutoRefresh(
              interval: const Duration(seconds: 30),
            );
        break;
      case 1:
        ref.read(badgeTrackingNotifierProvider.notifier).startAutoRefresh(
              interval: const Duration(seconds: 30),
            );
        break;
      case 2:
        ref.read(servicesTrackingNotifierProvider.notifier).startAutoRefresh(
              interval: const Duration(seconds: 30),
            );
        break;
      case 3:
        ref.read(complaintsTrackingNotifierProvider.notifier).startAutoRefresh(
              interval: const Duration(seconds: 30),
            );
        break;
    }
  }

  void _stopAutoRefresh() {
    ref.read(programsTrackingNotifierProvider.notifier).stopAutoRefresh();
    ref.read(badgeTrackingNotifierProvider.notifier).stopAutoRefresh();
    ref.read(servicesTrackingNotifierProvider.notifier).stopAutoRefresh();
    ref.read(complaintsTrackingNotifierProvider.notifier).stopAutoRefresh();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MM/dd/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(
        title: 'Track Requests',
      ),
      body: Column(
        children: [
          TopNavTrack(
            selectedIndex: _selectedTab,
            onTabChanged: (index) {
              _stopAutoRefresh();
              setState(() {
                _selectedTab = index;
              });
              _loadData();
              _startAutoRefresh();
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadData();
              },
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _buildProgramsTracking();
      case 1:
        return _buildBadgeTracking();
      case 2:
        return _buildServicesTracking();
      case 3:
        return _buildComplaintsTracking();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProgramsTracking() {
    final programsState = ref.watch(programsTrackingNotifierProvider);

    return programsState.when(
      started: () => const Center(child: Text('Getting started...')),
      loading: () => const Center(child: CircularProgressIndicator()),
      success: (response) {
        final allPostings = response.data
            .expand((program) => program.postings.map((posting) => ({
                  'posting': posting,
                  'programName': program.program.name,
                })))
            .toList();

        if (allPostings.isEmpty) {
          return ListView(
            children: const [
              SizedBox(height: 100),
              Center(child: Text('No program applications found')),
            ],
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: allPostings.length,
          itemBuilder: (context, index) {
            final data = allPostings[index];
            final posting = data['posting'] as dynamic;

            return TrackCaseCard(
              caseId: posting.postingId,
              title: posting.postingTitle,
              status: posting.overallStatus,
              description: _getDescriptionForStatus(posting.overallStatus),
              updatedDate: _formatDate(posting.requestedAt),
              showRateButton: posting.overallStatus.toLowerCase() == 'approved',
            );
          },
        );
      },
      error: (message) => _buildErrorState(message),
    );
  }

  Widget _buildBadgeTracking() {
    final badgeState = ref.watch(badgeTrackingNotifierProvider);

    return badgeState.when(
      started: () => const Center(child: Text('Getting started...')),
      loading: () => const Center(child: CircularProgressIndicator()),
      success: (response) {
        if (response.data.isEmpty) {
          return ListView(
            children: const [
              SizedBox(height: 100),
              Center(child: Text('No badge requests found')),
            ],
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: response.data.length,
          itemBuilder: (context, index) {
            final badge = response.data[index];
            return TrackCaseCard(
              caseId: badge.code ?? badge.id,
              title: badge.type ?? 'Badge Request',
              status: badge.statusLabel,
              description: badge.reviewNotes ??
                  _getDescriptionForStatus(badge.statusLabel),
              updatedDate: _formatDate(badge.updatedAt),
              showRateButton: badge.statusLabel.toLowerCase() == 'verified' ||
                  badge.statusLabel.toLowerCase() == 'approved',
            );
          },
        );
      },
      error: (message) => _buildErrorState(message),
    );
  }

  Widget _buildServicesTracking() {
    final servicesState = ref.watch(servicesTrackingNotifierProvider);

    return servicesState.when(
      started: () => const Center(child: Text('Getting started...')),
      loading: () => const Center(child: CircularProgressIndicator()),
      success: (response) {
        final allPostings = response.data
            .expand((service) => service.postings.map((posting) => ({
                  'posting': posting,
                })))
            .toList();

        if (allPostings.isEmpty) {
          return ListView(
            children: const [
              SizedBox(height: 100),
              Center(child: Text('No service requests found')),
            ],
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: allPostings.length,
          itemBuilder: (context, index) {
            final data = allPostings[index];
            final posting = data['posting'] as dynamic;

            return TrackCaseCard(
              caseId: posting.postingId,
              title: posting.postingTitle,
              status: posting.overallStatus,
              description: _getDescriptionForStatus(posting.overallStatus),
              updatedDate: _formatDate(posting.requestedAt),
              showRateButton: posting.overallStatus.toLowerCase() == 'approved',
            );
          },
        );
      },
      error: (message) => _buildErrorState(message),
    );
  }

  Widget _buildComplaintsTracking() {
    final complaintsState = ref.watch(complaintsTrackingNotifierProvider);

    return complaintsState.when(
      started: () => const Center(child: Text('Getting started...')),
      loading: () => const Center(child: CircularProgressIndicator()),
      success: (response) {
        if (response.data.isEmpty) {
          return ListView(
            children: const [
              SizedBox(height: 100),
              Center(child: Text('No complaints found')),
            ],
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: response.data.length,
          itemBuilder: (context, index) {
            final complaint = response.data[index];
            return TrackCaseCard(
              caseId: complaint.code ?? complaint.id,
              title: complaint.subject ?? complaint.type ?? 'Complaint',
              status: complaint.statusLabel,
              description: _getDescriptionForStatus(complaint.statusLabel),
              updatedDate: _formatDate(complaint.updatedAt),
              showRateButton: complaint.statusLabel.toLowerCase() == 'resolved',
            );
          },
        );
      },
      error: (message) => _buildErrorState(message),
    );
  }

  Widget _buildErrorState(String? message) {
    return ListView(
      children: [
        SizedBox(height: 100.h),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${message ?? "An unknown error occurred"}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDescriptionForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'submitted':
        return 'Your request has been submitted and is pending review.';
      case 'under review':
      case 'in progress':
        return 'In Progress: A Social Worker is currently verifying your documents.';
      case 'action required':
        return 'Action Required: Please provide additional information or documents.';
      case 'ready':
        return 'Ready for Pickup: Please visit the designated office to claim.';
      case 'approved':
        return 'Your request has been approved.';
      case 'verified':
        return 'Your badge has been verified and is ready.';
      case 'closed':
      case 'resolved':
        return 'Your request has been processed and closed.';
      case 'rejected':
        return 'Your request has been rejected. Please contact support for more information.';
      case 'cancelled':
        return 'Your request has been cancelled.';
      default:
        return 'Your request is being processed.';
    }
  }
}