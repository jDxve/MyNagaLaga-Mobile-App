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
  ConsumerState<AllRequestsListWidget> createState() =>
      _AllRequestsListWidgetState();
}

class _AllRequestsListWidgetState extends ConsumerState<AllRequestsListWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_loadData);
  }

  void _loadData() {
    final userId = ref.read(authSessionProvider).userId;
    if (userId != null) {
      ref
          .read(allTrackingNotifierProvider.notifier)
          .fetch(mobileUserId: userId.toString());
    }
  }

  String _formatDate(DateTime? date) =>
      date == null ? "N/A" : DateFormat("MM/dd/yyyy").format(date);

  String _getStatusDesc(String status) {
    final s = status.toLowerCase();
    if (s.contains('pending') || s.contains('submitted'))
      return "Request submitted and pending review.";
    if (s.contains('review') || s.contains('progress'))
      return "Social Worker is verifying documents.";
    if (s.contains('action')) return "Additional information required.";
    if (s.contains('ready')) return "Ready for pickup at the office.";
    if (s.contains('approved') || s.contains('verified'))
      return "Your request has been approved.";
    if (s.contains('resolved') || s.contains('closed'))
      return "Processed and closed.";
    return "Your request is being processed.";
  }

  String _moduleLabel(String module) {
    switch (module) {
      case 'applications':
        return 'Application';
      case 'cases':
        return 'Welfare Case';
      case 'complaints':
        return 'Complaint';
      case 'badge_requests':
        return 'Badge';
      default:
        return module;
    }
  }

  bool _canRate(String module, String statusLabel) {
    final s = statusLabel.toLowerCase();
    switch (module) {
      case 'applications':
        return s == 'approved';
      case 'cases':
        return s == 'ready';
      case 'complaints':
        return s == 'resolved';
      // ✅ Badges not in backend FeedbackableTypeEnum — disable
      case 'badge_requests':
        return false;
      default:
        return false;
    }
  }

  /// Map module to the feedbackable_type the backend expects.
  /// Backend FeedbackableTypeEnum: 'case' | 'complaint' | 'assistance_posting'
  String _feedbackableType(String module) {
    switch (module) {
      case 'applications':
        return 'assistance_posting';
      case 'cases':
        return 'case';
      case 'complaints':
        // ✅ FIX: was missing 'complaint' — must be 'complaint' not 'assistance_posting'
        return 'complaint';
      default:
        return 'assistance_posting';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(allTrackingNotifierProvider);
    return state.when(
      started: () => const SizedBox.shrink(),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (errorMessage) =>
          Center(child: Text(errorMessage ?? 'An unexpected error occurred')),
      success: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 64.w, color: AppColors.grey.withOpacity(0.5)),
                  16.gapH,
                  Text(
                    'No requests found',
                    style: TextStyle(fontSize: D.textSM, color: AppColors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        final unrated = requests.where((r) => !r.hasRated).toList();
        final rated = requests.where((r) => r.hasRated).toList();
        final sorted = [...unrated, ...rated];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showHeader)
              Padding(
                padding:
                    widget.padding ?? EdgeInsets.symmetric(horizontal: 32.w),
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
                padding:
                    widget.padding ?? EdgeInsets.symmetric(horizontal: 24.w),
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final item = sorted[index];
                  final canRate =
                      _canRate(item.module, item.statusLabel) && !item.hasRated;
                  return TrackCaseCard(
                    caseId: item.id,
                    title: item.title ?? "Request",
                    subtitle: item.code,
                    tag: _moduleLabel(item.module),
                    status: item.statusLabel,
                    description: _getStatusDesc(item.statusLabel),
                    updatedDate: _formatDate(item.updatedAt),
                    showRateButton: canRate,
                    hasRated: item.hasRated,
                    // ✅ FIX: pass correct feedbackable_type per module
                    feedbackableType: _feedbackableType(item.module),
                    onRated: () {
                      ref
                          .read(allTrackingNotifierProvider.notifier)
                          .markAsRated(
                            itemId: item.id,
                            module: item.module,
                          );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}