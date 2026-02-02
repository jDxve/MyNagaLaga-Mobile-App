import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/primary_button.dart';

import '../../auth/notifier/auth_session_notifier.dart';
import '../componets/family_ledger_banner.dart';
import '../componets/family_tree_page.dart';

class FamilyLedgerScreen extends ConsumerStatefulWidget {
  static const String routeName = '/family-ledger';
  
  const FamilyLedgerScreen({super.key});

  @override
  ConsumerState<FamilyLedgerScreen> createState() => _FamilyLedgerScreenState();
}

class _FamilyLedgerScreenState extends ConsumerState<FamilyLedgerScreen> {
  String? _householdId;
  bool _isLoadingHousehold = true;

  @override
  void initState() {
    super.initState();
    // Load household after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserHousehold();
    });
  }

  Future<void> _loadUserHousehold() async {
    setState(() {
      _isLoadingHousehold = true;
    });

    // Get authenticated user ID from session
    final authSession = ref.read(authSessionProvider);
    final userId = authSession.userId;

    if (userId == null) {
      debugPrint('❌ No authenticated user');
      setState(() {
        _isLoadingHousehold = false;
      });
      return;
    }

    debugPrint('📤 Fetching household for user: $userId');

    // TODO: Call your repository to get user's household
    // For now, you can hardcode or make an API call
    // Example:
    // final repository = ref.read(familyLedgerRepositoryProvider);
    // final result = await repository.getMyHousehold();
    
    // Temporary: Set household ID (replace with actual API call)
    setState(() {
      _householdId = '7'; // Replace with actual household ID from API
      _isLoadingHousehold = false;
    });

    debugPrint('✅ User household ID: $_householdId');
  }

  void _navigateToFamilyTree() {
    final authSession = ref.read(authSessionProvider);
    
    if (!authSession.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_householdId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You are not part of any household yet'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FamilyTreePage(
          householdId: _householdId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);

    // Watch auth session for changes
    final authSession = ref.watch(authSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              100.gapH,
              
              // Family Ledger Title
              Text(
                'Family Ledger',
                style: TextStyle(
                  fontSize: D.textLG,
                  fontWeight: D.bold,
                  color: AppColors.textlogo,
                ),
              ),
              16.gapH,
              
              const FamilyLedgerBanner(),

              // Show user info
              if (authSession.isAuthenticated) ...[
                16.gapH,
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary,
                    borderRadius: BorderRadius.circular(D.radiusMD),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logged in as:',
                        style: TextStyle(
                          fontSize: D.textXS,
                          color: AppColors.grey,
                        ),
                      ),
                      4.gapH,
                      Text(
                        authSession.fullName ?? authSession.email ?? 'User',
                        style: TextStyle(
                          fontSize: D.textBase,
                          fontWeight: D.semiBold,
                          color: AppColors.textlogo,
                        ),
                      ),
                      if (_householdId != null) ...[
                        8.gapH,
                        Row(
                          children: [
                            Icon(
                              Icons.home,
                              size: 16.w,
                              color: AppColors.primary,
                            ),
                            6.gapW,
                            Text(
                              'Household: $_householdId',
                              style: TextStyle(
                                fontSize: D.textSM,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              24.gapH,

              // Button
              _isLoadingHousehold
                  ? const CircularProgressIndicator()
                  : PrimaryButton(
                      text: _householdId != null 
                          ? 'View Family Tree' 
                          : 'No Household Found',
                      onPressed: _householdId != null 
                          ? _navigateToFamilyTree 
                          : () {}, // Empty function instead of null
                    ),
              
              24.gapH,
            ],
          ),
        ),
      ),
    );
  }
}