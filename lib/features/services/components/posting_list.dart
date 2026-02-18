import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/utils/ui_utils.dart';
import '../models/welfare_program_model.dart';
import '../notifier/welfare_program_notifier.dart';
import 'programs_page/posting_detailed_page.dart';

class PostingHorizontalList extends ConsumerStatefulWidget {
  final String searchQuery;

  const PostingHorizontalList({super.key, this.searchQuery = ''});

  @override
  ConsumerState<PostingHorizontalList> createState() =>
      _PostingHorizontalListState();
}

class _PostingHorizontalListState
    extends ConsumerState<PostingHorizontalList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(allPostingsNotifierProvider.notifier).fetchAllPostings();
    });
  }

  Future<void> _refresh() async {
    await ref
        .read(allPostingsNotifierProvider.notifier)
        .fetchAllPostings(forceRefresh: true);
  }

  List<WelfarePostingModel> _filtered(List<WelfarePostingModel> all) {
    final q = widget.searchQuery.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((p) {
      return p.title.toLowerCase().contains(q) ||
          (p.programName?.toLowerCase().contains(q) ?? false) ||
          (p.serviceName?.toLowerCase().contains(q) ?? false) ||
          (p.description?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  void _openDetail(WelfarePostingModel posting) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostingDetailPage(posting: posting),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postingsState = ref.watch(allPostingsNotifierProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return postingsState.when(
      started: () => const SizedBox.shrink(),
      loading: () => SizedBox(
        height: 210.h,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (message) => Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Text(
          message ?? 'Failed to load postings.',
          style: TextStyle(color: AppColors.red, fontSize: 14.f),
        ),
      ),
      success: (postings) {
        final filtered = _filtered(postings);

        if (filtered.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Text(
                  widget.searchQuery.isEmpty
                      ? 'No available postings yet.'
                      : 'No postings match "${widget.searchQuery}".',
                  style: TextStyle(color: AppColors.grey, fontSize: 14.f),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: SizedBox(
            height: 210.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(right: 20.w),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => SizedBox(width: 16.w),
              itemBuilder: (context, index) {
                final post = filtered[index];
                return _PostingCard(
                  posting: post,
                  theme: UIUtils.getProgramTheme(post.programName),
                  cardWidth: screenWidth * 0.85,
                  onTap: () => _openDetail(post),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _PostingCard extends StatefulWidget {
  final WelfarePostingModel posting;
  final ProgramTheme theme;
  final VoidCallback? onTap;
  final double cardWidth;

  const _PostingCard({
    required this.posting,
    required this.theme,
    required this.cardWidth,
    this.onTap,
  });

  @override
  State<_PostingCard> createState() => _PostingCardState();
}

class _PostingCardState extends State<_PostingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isUrgent => UIUtils.isUrgent(widget.posting.endAt);
  bool get _isFull => UIUtils.isFull(widget.posting.slotsRemaining);
  String get _daysLeft => UIUtils.daysLeft(widget.posting.endAt);
  String get _slotsText => UIUtils.slotsText(widget.posting.slotsRemaining);

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;

    return GestureDetector(
      onTap: _isFull ? null : widget.onTap,
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Opacity(
          opacity: _isFull ? 0.6 : 1,
          child: Container(
            width: widget.cardWidth,
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [t.surface, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: t.accent.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: t.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          t.iconAsset,
                          width: 24.w,
                          height: 24.w,
                          colorFilter:
                              ColorFilter.mode(t.accent, BlendMode.srcIn),
                        ),
                      ),
                    ),
                    12.gapW,
                    Expanded(
                      child: Text(
                        widget.posting.programName ?? 'Welfare Program',
                        style: TextStyle(
                          fontSize: 14.f,
                          fontWeight: FontWeight.w600,
                          color: t.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                16.gapH,
                Text(
                  widget.posting.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17.f,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                    height: 1.3,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    if (_daysLeft.isNotEmpty) ...[
                      Icon(
                        Icons.access_time_rounded,
                        size: 18.w,
                        color: _isUrgent ? AppColors.red : AppColors.grey,
                      ),
                      6.gapW,
                      Text(
                        _daysLeft,
                        style: TextStyle(
                          fontSize: 13.f,
                          fontWeight: FontWeight.w500,
                          color: _isUrgent ? AppColors.red : AppColors.grey,
                        ),
                      ),
                      20.gapW,
                    ],
                    Icon(
                      Icons.people_outline_rounded,
                      size: 18.w,
                      color: _isFull ? AppColors.red : AppColors.grey,
                    ),
                    6.gapW,
                    Text(
                      _slotsText,
                      style: TextStyle(
                        fontSize: 13.f,
                        fontWeight: FontWeight.w500,
                        color: _isFull ? AppColors.red : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}