import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/models/dio/data_state.dart';
import '../../../auth/notifier/auth_session_notifier.dart';
import '../../../home/notifier/user_badge_notifier.dart';
import '../../components/programs_page/program_list_page.dart';
import '../../components/programs_page/sanggawadan_page.dart';
import '../../models/posting_requirement_model.dart';
import '../../notifier/user_badge_info_notifier.dart';
import '../../notifier/welfare_program_notifier.dart';
import '../../services/posting_service.dart';

class ChildrenYouthScreen extends ConsumerStatefulWidget {
  static const routeName = '/children-youth';
  static const String programId = '1';

  const ChildrenYouthScreen({super.key});

  @override
  ConsumerState<ChildrenYouthScreen> createState() => _ChildrenYouthScreenState();
}

class _ChildrenYouthScreenState extends ConsumerState<ChildrenYouthScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(welfarePostingsNotifierProvider.notifier).fetchPostings(
            programId: ChildrenYouthScreen.programId,
            status: 'Published',
          );
    });
  }

  Future<void> _handleProgramTap(String postingId, String postingTitle) async {
    if (_isProcessing) return;

    final session = ref.read(authSessionProvider);

    if (session.userId == null) {
      if (!mounted) return;
      _showSnackBar('Please log in first');
      return;
    }

    setState(() => _isProcessing = true);

    if (!mounted) return;
    _showLoadingDialog();

    try {
      await ref
          .read(badgeInfoNotifierProvider.notifier)
          .fetchBadgeInfo(mobileUserId: session.userId!);

      await ref
          .read(badgesNotifierProvider.notifier)
          .fetchBadges(mobileUserId: session.userId!);

      if (!mounted) return;

      final postingService = ref.read(postingServiceProvider);
      final postingResponse = await postingService.getPosting(postingId);

      if (!mounted) return;

      Navigator.pop(context);

      final postingData = postingResponse.data['data'] as Map<String, dynamic>? ??
          postingResponse.data;
      final requirementsList =
          postingData['assistance_posting_requirements'] as List?;

      final requirementIds = <int>[];
      final requirements = <PostingRequirement>[];

      if (requirementsList != null) {
        for (int index = 0; index < requirementsList.length; index++) {
          try {
            final req = requirementsList[index] as Map<String, dynamic>;
            var requirement = PostingRequirement.fromJson(req);

            if (requirement.order == 0) {
              requirement = PostingRequirement(
                id: requirement.id,
                label: requirement.label,
                category: requirement.category,
                type: requirement.type,
                required: requirement.required,
                notes: requirement.notes,
                order: index + 1,
              );
            }

            requirementIds.add(requirement.id);
            requirements.add(requirement);
          } catch (e) {
            continue;
          }
        }
      }

      final badgeInfoState = ref.read(badgeInfoNotifierProvider);
      final badgesState = ref.read(badgesNotifierProvider);

      int? userBadgeId;
      String? userBadgeType;

      badgesState.when(
        started: () {},
        loading: () {},
        success: (badgesResponse) {
          if (badgesResponse.badges.isNotEmpty) {
            final firstBadge = badgesResponse.badges.first;
            userBadgeId = int.tryParse(firstBadge.id.toString());
            userBadgeType = firstBadge.badgeTypeName;
          }
        },
        error: (_) {},
      );

      badgeInfoState.when(
        started: () {
          if (mounted) {
            _showSnackBar('Data not loaded. Please try again.');
            setState(() => _isProcessing = false);
          }
        },
        loading: () {
          if (mounted) {
            _showSnackBar('Still loading. Please wait.');
            setState(() => _isProcessing = false);
          }
        },
        success: (badgeInfo) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SanggawadanPage(
                  postingId: postingId,
                  postingTitle: postingTitle,
                  userName: badgeInfo.fullName,
                  userAge: badgeInfo.age,
                  userSchool: badgeInfo.schoolName ?? 'Not provided',
                  userGradeLevel: badgeInfo.yearOrGradeLevel ?? 'Not provided',
                  userBadgeType: userBadgeType,
                  userBadgeId: userBadgeId,
                  requirementIds: requirementIds,
                  requirements: requirements,
                ),
              ),
            ).then((_) {
              if (mounted) setState(() => _isProcessing = false);
            });
          }
        },
        error: (message) {
          if (mounted) {
            _showSnackBar('Error: $message');
            setState(() => _isProcessing = false);
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar('Unexpected error: $e');
      setState(() => _isProcessing = false);
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postingsState = ref.watch(welfarePostingsNotifierProvider);

    return postingsState.when(
      started: () => const Scaffold(
        body: Center(child: Text('Getting started...')),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      success: (postings) {
        if (postings.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Children & Youth Welfare')),
            body: const Center(
              child: Text('No programs available at the moment'),
            ),
          );
        }

        final programs = postings
            .map(
              (posting) => {
                'id': posting.id,
                'title': posting.title,
                'description': posting.description ?? 'No description available',
              },
            )
            .toList();

        return ProgramListPage(
          title: 'Children & Youth Welfare',
          subtitle: 'Programs for children and young adults',
          onProgramTap: (programTitle) {
            final posting = postings.firstWhere(
              (p) => p.title == programTitle,
              orElse: () => postings.first,
            );
            _handleProgramTap(posting.id, posting.title);
          },
          programs: programs,
        );
      },
      error: (message) => Scaffold(
        appBar: AppBar(title: const Text('Children & Youth Welfare')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $message'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(welfarePostingsNotifierProvider.notifier).fetchPostings(
                        programId: ChildrenYouthScreen.programId,
                        status: 'Published',
                      );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}