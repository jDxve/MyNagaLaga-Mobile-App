// lib/features/tracking/widgets/tracking_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../common/models/dio/data_state.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../auth/notifier/auth_session_notifier.dart';
import '../../notifier/tracking_notifier.dart';
import 'track_case_card.dart';

/// Reusable tracking widget that can be embedded in any screen
/// 
/// Features:
/// - Tab navigation between Programs, Badges, Services, and Complaints
/// - Automatic data caching - no unnecessary reloads on navigation
/// - Pull-to-refresh functionality
/// - Loading states and error handling
/// - Empty state messages
class TrackingWidget extends ConsumerStatefulWidget {
  final int initialTab;
  final bool showNavigation;
  final Function(int)? onTabChanged;
  final EdgeInsetsGeometry? padding;

  const TrackingWidget({
    super.key,
    this.initialTab = 0,
    this.showNavigation = true,
    this.onTabChanged,
    this.padding,
  });

  @override
  ConsumerState<TrackingWidget> createState() => _TrackingWidgetState();
}

class _TrackingWidgetState extends ConsumerState<TrackingWidget> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    Future.microtask(() => _loadData());
  }

  /// Load data for the current tab
  /// Uses cached data when available, only fetches if needed
  void _loadData({bool forceRefresh = false}) {
    final session = ref.read(authSessionProvider);
    if (session.userId == null) return;
    final id = session.userId!;

    switch (_selectedTab) {
      case 0:
        ref.read(programsTrackingNotifierProvider.notifier).fetchPrograms(
              mobileUserId: id,
              forceRefresh: forceRefresh,
            );
        break;
      case 1:
        ref.read(badgeTrackingNotifierProvider.notifier).fetchBadgeRequests(
              mobileUserId: id,
              forceRefresh: forceRefresh,
            );
        break;
      case 2:
        ref.read(servicesTrackingNotifierProvider.notifier).fetchServices(
              mobileUserId: id,
              forceRefresh: forceRefresh,
            );
        break;
      case 3:
        ref.read(complaintsTrackingNotifierProvider.notifier).fetchComplaints(
              mobileUserId: id,
              forceRefresh: forceRefresh,
            );
        break;
    }
  }

  /// Handle tab changes
  void _handleTabChange(int index) {
    if (_selectedTab == index) return;
    
    setState(() => _selectedTab = index);
    _loadData();
    widget.onTabChanged?.call(index);
  }

  /// Handle pull-to-refresh
  Future<void> _handleRefresh() async {
    _loadData(forceRefresh: true);
    // Wait a bit to show the refresh animation
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Format date to MM/dd/yyyy
  String _formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return DateFormat("MM/dd/yyyy").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showNavigation) _buildNavigation(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppColors.primary,
            child: Padding(
              padding: widget.padding ?? EdgeInsets.all(16.w),
              child: _buildTabContent(),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // NAVIGATION
  // ============================================================================

  Widget _buildNavigation() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: [
            _buildTab('Programs', 0),
            12.gapW,
            _buildTab('Badges', 1),
            12.gapW,
            _buildTab('Services', 2),
            12.gapW,
            _buildTab('Complaints', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => _handleTabChange(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: D.textSM,
            fontWeight: isSelected ? D.semiBold : D.regular,
            color: isSelected ? Colors.white : AppColors.grey,
            fontFamily: 'Segoe UI',
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // TAB CONTENT
  // ============================================================================

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildProgramTab();
      case 1:
        return _buildBadgeTab();
      case 2:
        return _buildServiceTab();
      case 3:
        return _buildComplaintTab();
      default:
        return _buildProgramTab();
    }
  }

  // ============================================================================
  // PROGRAMS TAB
  // ============================================================================

  Widget _buildProgramTab() {
    final state = ref.watch(programsTrackingNotifierProvider);
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      success: (response) {
        final items = response.data.expand((program) => program.postings).toList();
        if (items.isEmpty) {
          return _buildEmptyState(
            "No program requests found.",
            "Your program applications will appear here.",
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return TrackCaseCard(
              caseId: item.postingId,
              title: item.postingTitle,
              status: item.overallStatus,
              description: _getStatusDescription(item.overallStatus),
              updatedDate: _formatDate(item.requestedAt),
              showRateButton: item.overallStatus.toLowerCase() == "approved",
            );
          },
        );
      },
      error: (msg) => _buildErrorState(msg ?? "Failed to load programs"),
      started: () => const SizedBox(),
    );
  }

  // ============================================================================
  // BADGES TAB
  // ============================================================================

  Widget _buildBadgeTab() {
    final state = ref.watch(badgeTrackingNotifierProvider);
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      success: (response) {
        if (response.data.isEmpty) {
          return _buildEmptyState(
            "No badge requests found.",
            "Your badge applications will appear here.",
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: response.data.length,
          itemBuilder: (context, index) {
            final item = response.data[index];
            return TrackCaseCard(
              caseId: item.id,
              title: item.type ?? "Badge Request",
              status: item.statusLabel,
              description: _getStatusDescription(item.statusLabel),
              updatedDate: _formatDate(item.updatedAt),
              showRateButton: item.statusLabel.toLowerCase() == "verified",
            );
          },
        );
      },
      error: (msg) => _buildErrorState(msg ?? "Failed to load badge requests"),
      started: () => const SizedBox(),
    );
  }

  // ============================================================================
  // SERVICES TAB
  // ============================================================================

  Widget _buildServiceTab() {
    final state = ref.watch(servicesTrackingNotifierProvider);
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      success: (response) {
        final items = response.data.expand((service) => service.postings).toList();
        if (items.isEmpty) {
          return _buildEmptyState(
            "No service requests found.",
            "Your service applications will appear here.",
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return TrackCaseCard(
              caseId: item.postingId,
              title: item.postingTitle,
              status: item.overallStatus,
              description: _getStatusDescription(item.overallStatus),
              updatedDate: _formatDate(item.requestedAt),
              showRateButton: item.overallStatus.toLowerCase() == "approved",
            );
          },
        );
      },
      error: (msg) => _buildErrorState(msg ?? "Failed to load services"),
      started: () => const SizedBox(),
    );
  }

  // ============================================================================
  // COMPLAINTS TAB
  // ============================================================================

  Widget _buildComplaintTab() {
    final state = ref.watch(complaintsTrackingNotifierProvider);
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      success: (response) {
        if (response.data.isEmpty) {
          return _buildEmptyState(
            "No complaints found.",
            "Your filed complaints will appear here.",
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: response.data.length,
          itemBuilder: (context, index) {
            final item = response.data[index];
            return TrackCaseCard(
              caseId: item.id,
              title: item.subject ?? "Complaint",
              status: item.statusLabel,
              description: _getStatusDescription(item.statusLabel),
              updatedDate: _formatDate(item.updatedAt),
              showRateButton: item.statusLabel.toLowerCase() == "resolved",
            );
          },
        );
      },
      error: (msg) => _buildErrorState(msg ?? "Failed to load complaints"),
      started: () => const SizedBox(),
    );
  }

  // ============================================================================
  // EMPTY & ERROR STATES
  // ============================================================================

  Widget _buildEmptyState(String title, String subtitle) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64.w,
                  color: AppColors.grey.withOpacity(0.5),
                ),
                16.gapH,
                Text(
                  title,
                  style: TextStyle(
                    fontSize: D.textBase,
                    fontWeight: D.semiBold,
                    color: Colors.black87,
                    fontFamily: 'Segoe UI',
                  ),
                  textAlign: TextAlign.center,
                ),
                8.gapH,
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: D.textSM,
                    color: AppColors.grey,
                    fontFamily: 'Segoe UI',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.w,
                  color: Colors.red.withOpacity(0.7),
                ),
                16.gapH,
                Text(
                  "Oops! Something went wrong",
                  style: TextStyle(
                    fontSize: D.textBase,
                    fontWeight: D.semiBold,
                    color: Colors.black87,
                    fontFamily: 'Segoe UI',
                  ),
                  textAlign: TextAlign.center,
                ),
                8.gapH,
                Text(
                  message,
                  style: TextStyle(
                    fontSize: D.textSM,
                    color: AppColors.grey,
                    fontFamily: 'Segoe UI',
                  ),
                  textAlign: TextAlign.center,
                ),
                24.gapH,
                ElevatedButton.icon(
                  onPressed: () => _loadData(forceRefresh: true),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Try Again"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(D.radiusLG),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // STATUS DESCRIPTIONS
  // ============================================================================

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
        return "Your request was rejected. Contact support for details.";
      case "cancelled":
        return "Your request has been cancelled.";
      default:
        return "Your request is being processed.";
    }
  }
}