import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/models/dio/data_state.dart';
import '../../../auth/notifier/auth_session_notifier.dart';
import '../../../home/notifier/user_badge_notifier.dart';
import '../../components/programs_page/program_list_page.dart';
import '../../components/programs_page/sanggawadan_page.dart';
import '../../models/posting_requirement_model.dart'; // Add this import
import '../../notifier/user_badge_info_notifier.dart';
import '../../notifier/welfare_program_notifier.dart';
import '../../services/posting_service.dart';

class ChildrenYouthScreen extends ConsumerStatefulWidget {
  static const routeName = '/children-youth';
  static const String programId = '1';

  const ChildrenYouthScreen({super.key});

  @override
  ConsumerState<ChildrenYouthScreen> createState() =>
      _ChildrenYouthScreenState();
}

class _ChildrenYouthScreenState extends ConsumerState<ChildrenYouthScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(welfarePostingsNotifierProvider.notifier)
          .fetchPostings(
            programId: ChildrenYouthScreen.programId,
            status: 'Published',
          );
    });
  }

  void _handleProgramTap(String postingId, String postingTitle) async {
    if (_isProcessing) {
      debugPrint('⚠️ Already processing, ignoring tap');
      return;
    }

    final session = ref.read(authSessionProvider);

    if (session.userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }

    setState(() => _isProcessing = true);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      debugPrint('🔄 Fetching badge info for user: ${session.userId}');

      // Fetch badge info
      await ref
          .read(badgeInfoNotifierProvider.notifier)
          .fetchBadgeInfo(mobileUserId: session.userId!);

      // Fetch approved badges
      debugPrint('🎖️ Fetching approved badges for user: ${session.userId}');
      await ref
          .read(badgesNotifierProvider.notifier)
          .fetchBadges(mobileUserId: session.userId!);

      if (!mounted) return;

      // Fetch posting requirements
      debugPrint('📋 Fetching posting requirements for posting: $postingId');
      final postingService = ref.read(postingServiceProvider);
      final postingResponse = await postingService.getPosting(postingId);

      if (!mounted) return;

      Navigator.pop(context); // Close loading dialog

      // Extract requirements with full details
      final postingData =
          postingResponse.data['data'] as Map<String, dynamic>? ??
          postingResponse.data;
      final requirementsList =
          postingData['assistance_posting_requirements'] as List?;

      final requirementIds = <int>[];
      final requirements = <PostingRequirement>[];

      if (requirementsList != null) {
        for (int index = 0; index < requirementsList.length; index++) {
          try {
            final req = requirementsList[index] as Map<String, dynamic>;

            // DEBUG: Print the raw JSON structure
            debugPrint('📦 Raw requirement JSON [${index + 1}]: $req');

            var requirement = PostingRequirement.fromJson(req);

            // If order is 0, use the index + 1
            if (requirement.order == 0) {
              debugPrint('⚠️ Order was 0, using index ${index + 1}');
              requirement = PostingRequirement(
                id: requirement.id,
                label: requirement.label,
                category: requirement.category,
                type: requirement.type,
                required: requirement.required,
                notes: requirement.notes,
                order: index + 1, // Use 1-based index
              );
            }

            requirementIds.add(requirement.id);
            requirements.add(requirement);
            debugPrint(
              '📄 Requirement ${requirement.order}: ${requirement.label} (Required: ${requirement.required})',
            );
          } catch (e) {
            debugPrint('⚠️ Failed to parse requirement: $e');
          }
        }
      }

      debugPrint('✅ Found ${requirements.length} requirements');

      // Get badge info
      final badgeInfoState = ref.read(badgeInfoNotifierProvider);

      // Get approved badges
      final badgesState = ref.read(badgesNotifierProvider);

      int? userBadgeId;
      String? userBadgeType;

      badgesState.when(
        started: () => debugPrint('⚠️ Badges state: STARTED'),
        loading: () => debugPrint('⚠️ Badges state: LOADING'),
        success: (badgesResponse) {
          if (badgesResponse.badges.isNotEmpty) {
            final firstBadge = badgesResponse.badges.first;
            userBadgeId = int.tryParse(firstBadge.id.toString());
            userBadgeType = firstBadge.badgeTypeName;
            debugPrint(
              '🎖️ Found badge: ${firstBadge.badgeTypeName} (ID: ${firstBadge.id})',
            );
          }
        },
        error: (error) => debugPrint('❌ Badges error: $error'),
      );

      debugPrint('📊 Badge Info State: ${badgeInfoState.runtimeType}');

      badgeInfoState.when(
        started: () {
          debugPrint('⚠️ State is STARTED - this shouldn\'t happen');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data not loaded. Please try again.'),
              ),
            );
            setState(() => _isProcessing = false);
          }
        },
        loading: () {
          debugPrint('⚠️ State is LOADING - this shouldn\'t happen');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Still loading. Please wait.')),
            );
            setState(() => _isProcessing = false);
          }
        },
        success: (badgeInfo) {
          debugPrint('✅ Success! Navigating to SanggawadanPage');
          debugPrint('   Name: ${badgeInfo.fullName}');
          debugPrint('   Age: ${badgeInfo.age}');
          debugPrint('   School: ${badgeInfo.schoolName ?? 'Not provided'}');
          debugPrint(
            '   Grade: ${badgeInfo.yearOrGradeLevel ?? 'Not provided'}',
          );
          debugPrint('   Badge ID: $userBadgeId');
          debugPrint('   Badge Type: $userBadgeType');
          debugPrint('   Requirements: ${requirements.length}');

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
                  requirements: requirements, // Pass the full requirements list
                ),
              ),
            ).then((_) {
              if (mounted) setState(() => _isProcessing = false);
            });
          }
        },
        error: (message) {
          debugPrint('❌ Error state: $message');
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $message')));
            setState(() => _isProcessing = false);
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postingsState = ref.watch(welfarePostingsNotifierProvider);

    return postingsState.when(
      started: () =>
          const Scaffold(body: Center(child: Text('Getting started...'))),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
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
                'description':
                    posting.description ?? 'No description available',
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
                  ref
                      .read(welfarePostingsNotifierProvider.notifier)
                      .fetchPostings(
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
