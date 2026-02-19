import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../common/models/dio/data_state.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../auth/notifier/auth_session_notifier.dart';
import '../../notifier/tracking_notifier.dart';
import '../../models/tracking_model.dart';
import 'track_case_card.dart';

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

  // Tab config: index → label
  static const _tabs = ['Program', 'Service', 'Complaint', 'Badge'];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    Future.microtask(() => _loadData());
  }

  String? _getUserId() {
    final session = ref.read(authSessionProvider);
    return session.userId;
  }

  void _loadData({bool forceRefresh = false}) {
    final id = _getUserId();
    if (id == null) return;

    switch (_selectedTab) {
      case 0:
        // → GET /mobile-tracking/{id}/programs
        ref.read(programsTrackingNotifierProvider.notifier).fetch(
              mobileUserId: id,
              forceRefresh: forceRefresh,
            );
        break;
      case 1:
        // → GET /mobile-tracking/{id}/services
        ref.read(servicesTrackingNotifierProvider.notifier).fetch(
              mobileUserId: id,
              forceRefresh: forceRefresh,
            );
        break;
      case 2:
        // → GET /mobile-tracking/{id}/complaints
        ref.read(complaintsTrackingNotifierProvider.notifier).fetch(
              mobileUserId: id,
              forceRefresh: forceRefresh,
            );
        break;
      case 3:
        // → GET /mobile-tracking/{id}/badge-requests
        ref.read(badgeTrackingNotifierProvider.notifier).fetch(
              mobileUserId: id,
              forceRefresh: forceRefresh,
            );
        break;
    }
  }

  void _handleTabChange(int index) {
    if (_selectedTab == index) return;
    setState(() => _selectedTab = index);
    _loadData();
    widget.onTabChanged?.call(index);
  }

  Future<void> _handleRefresh() async {
    _loadData(forceRefresh: true);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MM/dd/yyyy').format(date);
  }

  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'submitted':
        return 'Your request has been submitted and is pending review.';
      case 'under review':
      case 'in progress':
        return 'Your request is currently being reviewed.';
      case 'action required':
        return 'Please provide additional documents or information.';
      case 'ready':
        return 'Ready for pickup. Please visit the office.';
      case 'approved':
        return 'Your request has been approved.';
      case 'verified':
        return 'Your badge is verified and ready.';
      case 'resolved':
      case 'closed':
        return 'Your request has been processed and closed.';
      case 'rejected':
        return 'Your request was rejected. Contact support for details.';
      case 'cancelled':
        return 'Your request has been cancelled.';
      default:
        return 'Your request is being processed.';
    }
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────

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

  // ── NAV ────────────────────────────────────────────────────────────────────

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
          children: List.generate(_tabs.length, (i) {
            return Padding(
              padding: EdgeInsets.only(right: i < _tabs.length - 1 ? 12.w : 0),
              child: _buildTab(_tabs[i], i),
            );
          }),
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

  // ── TAB CONTENT ROUTER ─────────────────────────────────────────────────────

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildProgramTab();
      case 1:
        return _buildServiceTab();
      case 2:
        return _buildComplaintTab();
      case 3:
        return _buildBadgeTab();
      default:
        return _buildProgramTab();
    }
  }

  // ── PROGRAM TAB ────────────────────────────────────────────────────────────
  // Source: GET /mobile-tracking/{id}/programs
  // Returns: List<ProgramTrackingModel>
  //   ProgramTrackingModel { program, postings: List<ProgramPostingModel>, ... }
  //   ProgramPostingModel  { postingId, postingTitle, overallStatus, requestedAt,
  //                          service, hasRated, ... }

  Widget _buildProgramTab() {
    final state = ref.watch(programsTrackingNotifierProvider);

    return state.when(
      started: () => const SizedBox.shrink(),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (msg) => _buildErrorState(msg ?? 'Failed to load programs'),
      success: (programs) {
        // Flatten: each program → its postings, carrying program name
        final items = <_ProgramPostingRow>[];
        for (final program in programs) {
          for (final posting in program.postings) {
            items.add(_ProgramPostingRow(
              posting: posting,
              programName: program.program.name ?? 'Unknown Program',
            ));
          }
        }

        if (items.isEmpty) {
          return _buildEmptyState(
            'No program applications found.',
            'Your program applications will appear here.',
          );
        }

        // Unrated first, then rated
        final sorted = [
          ...items.where((r) => !r.posting.hasRated),
          ...items.where((r) => r.posting.hasRated),
        ];

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: sorted.length,
          itemBuilder: (_, i) {
            final row = sorted[i];
            final p = row.posting;
            final canRate =
                p.overallStatus.toLowerCase() == 'approved' && !p.hasRated;

            return TrackCaseCard(
              caseId: p.postingId,
              title: row.programName,
              subtitle: p.postingTitle.isNotEmpty ? p.postingTitle : null,
              tag: p.service?.name,
              status: p.overallStatus,
              description: _getStatusDescription(p.overallStatus),
              updatedDate: _formatDate(p.requestedAt),
              showRateButton: canRate,
              hasRated: p.hasRated,
              feedbackableType: 'assistance_posting',
              onRated: () {
                ref
                    .read(programsTrackingNotifierProvider.notifier)
                    .markPostingAsRated(postingId: p.postingId);
              },
            );
          },
        );
      },
    );
  }

  // ── SERVICE TAB ────────────────────────────────────────────────────────────
  // Source: GET /mobile-tracking/{id}/services   ← SEPARATE endpoint from programs
  // Returns: List<ServiceTrackingModel>
  //   ServiceTrackingModel { service, program?, postings: List<ServicePostingModel>, ... }
  //   ServicePostingModel  { postingId, overallStatus, requestedAt, barangay,
  //                          hasRated, ... }

  Widget _buildServiceTab() {
    final state = ref.watch(servicesTrackingNotifierProvider);

    return state.when(
      started: () => const SizedBox.shrink(),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (msg) => _buildErrorState(msg ?? 'Failed to load services'),
      success: (services) {
        // Flatten: each service → its postings, carrying service + program names
        final items = <_ServicePostingRow>[];
        for (final service in services) {
          for (final posting in service.postings) {
            items.add(_ServicePostingRow(
              posting: posting,
              serviceName: service.service.name ?? 'Unknown Service',
              programName: service.program?.name,
            ));
          }
        }

        if (items.isEmpty) {
          return _buildEmptyState(
            'No service applications found.',
            'Your service applications will appear here.',
          );
        }

        final sorted = [
          ...items.where((r) => !r.posting.hasRated),
          ...items.where((r) => r.posting.hasRated),
        ];

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: sorted.length,
          itemBuilder: (_, i) {
            final row = sorted[i];
            final p = row.posting;
            final canRate =
                p.overallStatus.toLowerCase() == 'approved' && !p.hasRated;

            return TrackCaseCard(
              caseId: p.postingId,
              title: row.serviceName,
              // Show program name as subtitle if available (services belong to programs)
              subtitle: row.programName != null
                  ? 'Program: ${row.programName}'
                  : null,
              tag: p.barangay?.name,
              status: p.overallStatus,
              description: _getStatusDescription(p.overallStatus),
              updatedDate: _formatDate(p.requestedAt),
              showRateButton: canRate,
              hasRated: p.hasRated,
              feedbackableType: 'assistance_posting',
              onRated: () {
                ref
                    .read(servicesTrackingNotifierProvider.notifier)
                    .markPostingAsRated(postingId: p.postingId);
              },
            );
          },
        );
      },
    );
  }

  // ── COMPLAINT TAB ──────────────────────────────────────────────────────────
  // Source: GET /mobile-tracking/{id}/complaints
  // Returns: List<ComplaintModel>
  //   ComplaintModel { id, code, subject, type, statusLabel,
  //                    barangay, updatedAt, hasRated }

  Widget _buildComplaintTab() {
    final state = ref.watch(complaintsTrackingNotifierProvider);

    return state.when(
      started: () => const SizedBox.shrink(),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (msg) => _buildErrorState(msg ?? 'Failed to load complaints'),
      success: (complaints) {
        if (complaints.isEmpty) {
          return _buildEmptyState(
            'No complaints found.',
            'Your filed complaints will appear here.',
          );
        }

        final sorted = [
          ...complaints.where((c) => !c.hasRated),
          ...complaints.where((c) => c.hasRated),
        ];

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: sorted.length,
          itemBuilder: (_, i) {
            final item = sorted[i];
            final canRate =
                item.statusLabel.toLowerCase() == 'resolved' && !item.hasRated;

            return TrackCaseCard(
              caseId: item.id,
              title: item.subject ?? item.type ?? 'Complaint',
              subtitle: item.code,
              tag: item.barangay?.name,
              status: item.statusLabel,
              description: _getStatusDescription(item.statusLabel),
              updatedDate: _formatDate(item.updatedAt),
              showRateButton: canRate,
              hasRated: item.hasRated,
              feedbackableType: 'complaint',
              onRated: () {
                ref
                    .read(complaintsTrackingNotifierProvider.notifier)
                    .markAsRated(id: item.id);
              },
            );
          },
        );
      },
    );
  }

  // ── BADGE TAB ──────────────────────────────────────────────────────────────
  // Source: GET /mobile-tracking/{id}/badge-requests
  // Returns: List<BadgeRequestModel>
  //   BadgeRequestModel { id, code, type, statusLabel, updatedAt, hasRated }

  Widget _buildBadgeTab() {
    final state = ref.watch(badgeTrackingNotifierProvider);

    return state.when(
      started: () => const SizedBox.shrink(),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (msg) => _buildErrorState(msg ?? 'Failed to load badge requests'),
      success: (badges) {
        if (badges.isEmpty) {
          return _buildEmptyState(
            'No badge requests found.',
            'Your badge applications will appear here.',
          );
        }

        final sorted = [
          ...badges.where((b) => !b.hasRated),
          ...badges.where((b) => b.hasRated),
        ];

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: sorted.length,
          itemBuilder: (_, i) {
            final item = sorted[i];

            return TrackCaseCard(
              caseId: item.id,
              title: item.type ?? 'Badge Request',
              subtitle: item.code,
              status: item.statusLabel,
              description: _getStatusDescription(item.statusLabel),
              updatedDate: _formatDate(item.updatedAt),
              // Badge feedback not yet supported by backend enum
              // (backend only allows: 'case', 'complaint', 'assistance_posting')
              showRateButton: false,
              hasRated: item.hasRated,
              feedbackableType: 'assistance_posting', // unused
              onRated: () {
                ref
                    .read(badgeTrackingNotifierProvider.notifier)
                    .markAsRated(id: item.id);
              },
            );
          },
        );
      },
    );
  }

  // ── EMPTY / ERROR STATES ───────────────────────────────────────────────────

  Widget _buildEmptyState(String title, String subtitle) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 80.h),
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
        SizedBox(height: 80.h),
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
                  'Oops! Something went wrong',
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
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
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
}

// ── Private row helpers (no overlap between tabs) ─────────────────────────────

/// Holds one row for the Program tab.
/// Data comes exclusively from /programs endpoint → ProgramTrackingModel.postings
class _ProgramPostingRow {
  final ProgramPostingModel posting;
  final String programName;

  const _ProgramPostingRow({
    required this.posting,
    required this.programName,
  });
}

/// Holds one row for the Service tab.
/// Data comes exclusively from /services endpoint → ServiceTrackingModel.postings
class _ServicePostingRow {
  final ServicePostingModel posting;
  final String serviceName;
  final String? programName;

  const _ServicePostingRow({
    required this.posting,
    required this.serviceName,
    this.programName,
  });
}