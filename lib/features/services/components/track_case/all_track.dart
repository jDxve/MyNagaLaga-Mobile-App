// lib/features/tracking/widgets/all_requests_list_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../common/models/dio/data_state.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../auth/notifier/auth_session_notifier.dart';
import '../../notifier/tracking_notifier.dart';
import 'track_case_card.dart';

class AllRequestsListWidget extends ConsumerStatefulWidget {
  final bool showHeader;
  final String? headerTitle;
  final EdgeInsetsGeometry? padding;

  const AllRequestsListWidget({
    super.key,
    this.showHeader = true,
    this.headerTitle = 'My Requests',
    this.padding,
  });

  @override
  ConsumerState<AllRequestsListWidget> createState() => _AllRequestsListWidgetState();
}

class _AllRequestsListWidgetState extends ConsumerState<AllRequestsListWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_loadAllData);
  }

  void _loadAllData() {
    final session = ref.read(authSessionProvider);
    if (session.userId == null) return;
    final id = session.userId!;

    ref.read(programsTrackingNotifierProvider.notifier).fetchPrograms(mobileUserId: id);
    ref.read(badgeTrackingNotifierProvider.notifier).fetchBadgeRequests(mobileUserId: id);
    ref.read(servicesTrackingNotifierProvider.notifier).fetchServices(mobileUserId: id);
    ref.read(complaintsTrackingNotifierProvider.notifier).fetchComplaints(mobileUserId: id);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return DateFormat("MM/dd/yyyy").format(date);
  }

  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case "pending":
      case "submitted":
        return "Your request has been submitted and is pending review.";
      case "under review":
      case "in progress":
        return "A Social Worker is currently verifying your documents.";
      case "action required":
        return "Please provide additional documents or information.";
      case "ready":
        return "Ready for pickup. Please visit the office.";
      case "approved":
        return "Your request has been approved.";
      case "verified":
        return "Your badge is verified and ready.";
      case "resolved":
      case "closed":
        return "Your request has been processed and closed.";
      case "rejected":
        return "Your request was rejected. Contact support.";
      case "cancelled":
        return "Your request has been cancelled.";
      default:
        return "Your request is being processed.";
    }
  }

  List<Map<String, dynamic>> _getAllRequests() {
    final List<Map<String, dynamic>> allRequests = [];
    
    final programsState = ref.watch(programsTrackingNotifierProvider);
    final badgesState = ref.watch(badgeTrackingNotifierProvider);
    final servicesState = ref.watch(servicesTrackingNotifierProvider);
    final complaintsState = ref.watch(complaintsTrackingNotifierProvider);

    programsState.whenOrNull(
      success: (response) {
        final items = response.data.expand((program) => program.postings).toList();
        for (var item in items) {
          allRequests.add({
            'caseId': item.postingId,
            'title': item.postingTitle,
            'status': item.overallStatus,
            'description': _getStatusDescription(item.overallStatus),
            'date': _formatDate(item.requestedAt),
            'showRate': item.overallStatus.toLowerCase() == "approved",
          });
        }
      },
    );

    badgesState.whenOrNull(
      success: (response) {
        for (var item in response.data) {
          allRequests.add({
            'caseId': item.id,
            'title': item.type ?? "Badge Request",
            'status': item.statusLabel,
            'description': _getStatusDescription(item.statusLabel),
            'date': _formatDate(item.updatedAt),
            'showRate': item.statusLabel.toLowerCase() == "verified",
          });
        }
      },
    );

    servicesState.whenOrNull(
      success: (response) {
        final items = response.data.expand((service) => service.postings).toList();
        for (var item in items) {
          allRequests.add({
            'caseId': item.postingId,
            'title': item.postingTitle,
            'status': item.overallStatus,
            'description': _getStatusDescription(item.overallStatus),
            'date': _formatDate(item.requestedAt),
            'showRate': item.overallStatus.toLowerCase() == "approved",
          });
        }
      },
    );

    complaintsState.whenOrNull(
      success: (response) {
        for (var item in response.data) {
          allRequests.add({
            'caseId': item.id,
            'title': item.subject ?? "Complaint",
            'status': item.statusLabel,
            'description': _getStatusDescription(item.statusLabel),
            'date': _formatDate(item.updatedAt),
            'showRate': item.statusLabel.toLowerCase() == "resolved",
          });
        }
      },
    );

    return allRequests;
  }

  bool _isAnyLoading() {
    final programsState = ref.watch(programsTrackingNotifierProvider);
    final badgesState = ref.watch(badgeTrackingNotifierProvider);
    final servicesState = ref.watch(servicesTrackingNotifierProvider);
    final complaintsState = ref.watch(complaintsTrackingNotifierProvider);

    return programsState is Loading ||
        badgesState is Loading ||
        servicesState is Loading ||
        complaintsState is Loading;
  }

  @override
  Widget build(BuildContext context) {
    final allRequests = _getAllRequests();
    final isLoading = _isAnyLoading();

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (allRequests.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Text(
            'No requests found',
            style: TextStyle(fontSize: D.textSM, color: AppColors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader)
          Padding(
            padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              widget.headerTitle ?? 'My Requests',
              style: TextStyle(
                fontSize: D.textBase,
                fontWeight: D.bold,
                fontFamily: 'Segoe UI',
              ),
            ),
          ),
        if (widget.showHeader) 12.gapH,
        Expanded(
          child: ListView.builder(
            padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 24.w),
            itemCount: allRequests.length,
            itemBuilder: (context, index) {
              final request = allRequests[index];
              return TrackCaseCard(
                caseId: request['caseId'],
                title: request['title'],
                status: request['status'],
                description: request['description'],
                updatedDate: request['date'],
                showRateButton: request['showRate'],
              );
            },
          ),
        ),
      ],
    );
  }
}