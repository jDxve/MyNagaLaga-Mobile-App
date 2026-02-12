import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../components/family_tree_view.dart';
import '../components/household_info_card.dart';
import '../components/empty_state_widget.dart';

class FamilyLedgerScreen extends ConsumerStatefulWidget {
  static const String routeName = '/family-ledger';

  const FamilyLedgerScreen({super.key});

  @override
  ConsumerState<FamilyLedgerScreen> createState() => _FamilyLedgerScreenState();
}

class _FamilyLedgerScreenState extends ConsumerState<FamilyLedgerScreen> {
  bool _isLoading = true;
  bool _hasHousehold = false;
  Map<String, dynamic>? _householdData;

  @override
  void initState() {
    super.initState();
    _loadUserHousehold();
  }

  Future<void> _loadUserHousehold() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _hasHousehold = true;
      _householdData = _getMockData();
      _isLoading = false;
    });
  }

  Map<String, dynamic> _getMockData() {
    return {
      'id': '1',
      'household_code': 'HH-001',
      'barangay': {'id': '1', 'name': 'Cabasan'},
      'household_members': [
        _createMember('1', 'John', 'Dela Cruz', 'Head', true, 'Active'),
        _createMember('2', 'Maria', 'Dela Cruz', 'Spouse', false, 'Active'),
        _createMember('3', 'Alice', 'Dela Cruz', 'Child', false, 'Active'),
        _createMember('4', 'Bob', 'Dela Cruz', 'Child', false, 'Active'),
        _createMember('5', 'Charlie', 'Dela Cruz', 'Child', false, 'Active'),
        _createMember('6', 'Pedro', 'Dela Cruz', 'Child', false, 'Active'),
        _createMember('7', 'Prince', 'Dela Cruz', 'Grandchild', false, 'Active'),
        _createMember('8', 'Mary', 'Dela Cruz', 'Grandchild', false, 'Active'),
        _createMember('9', 'Jay', 'Dela Cruz', 'Grandchild', false, 'Active'),
      ],
    };
  }

  Map<String, dynamic> _createMember(
    String id,
    String firstName,
    String lastName,
    String relationship,
    bool isHead,
    String status,
  ) {
    return {
      'id': id,
      'is_head': isHead,
      'relationship_to_head': relationship,
      'status': status,
      'residents': {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'birthdate': '2000-01-01',
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return _hasHousehold ? _buildHouseholdView() : _buildNoHouseholdView();
  }

  Widget _buildHouseholdView() {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    20.gapH,
                    HouseholdInfoCard(
                      householdCode: _householdData!['household_code'],
                      barangay: _householdData!['barangay']['name'],
                      memberCount: _householdData!['household_members'].length,
                    ),
                    32.gapH,
                    _buildFamilyRegistry(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Family Ledger',
            style: TextStyle(
              fontSize: D.textXL,
              fontWeight: D.bold,
              color: AppColors.textlogo,
            ),
          ),
          4.gapH,
          Text(
            'View and manage your household members',
            style: TextStyle(fontSize: D.textSM, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyRegistry() {
    return Container(
      color: AppColors.white,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        children: [
          Text(
            'Family Registry',
            style: TextStyle(
              fontSize: D.textXL,
              fontWeight: D.bold,
              color: AppColors.textlogo,
            ),
          ),
          8.gapH,
          Text(
            'Your household members',
            style: TextStyle(fontSize: D.textSM, color: AppColors.grey),
          ),
          32.gapH,
          FamilyTreeView(members: _householdData!['household_members']),
          40.gapH,
        ],
      ),
    );
  }

  Widget _buildNoHouseholdView() {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: EmptyStateWidget(
                icon: Icons.family_restroom,
                title: 'No Household Found',
                message: 'You are not currently part of any household.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}