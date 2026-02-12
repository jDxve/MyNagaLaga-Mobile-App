import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../components/household_info_card.dart';
import '../components/empty_state_widget.dart';
import '../components/family_registry_section.dart';
import '../notitier/my_household_notifier.dart';

class FamilyLedgerScreen extends ConsumerStatefulWidget {
  static const String routeName = '/family-ledger';

  const FamilyLedgerScreen({super.key});

  @override
  ConsumerState<FamilyLedgerScreen> createState() =>
      _FamilyLedgerScreenState();
}

class _FamilyLedgerScreenState extends ConsumerState<FamilyLedgerScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(myHouseholdNotifierProvider.notifier).getMyHousehold(),
    );
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);

    final state = ref.watch(myHouseholdNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: state.when(
          started: () => const Center(child: Text('Initializing...')),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $error'),
                16.gapH,
                ElevatedButton(
                  onPressed: () => ref
                      .read(myHouseholdNotifierProvider.notifier)
                      .getMyHousehold(forceRefresh: true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          success: (household) {
            if (household == null) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        16.gapH,
                        Text(
                          'Family Ledger',
                          style: TextStyle(
                            fontSize: 24.f,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Segoe UI',
                            color: AppColors.textlogo,
                          ),
                        ),
                        4.gapH,
                        Text(
                          'View and manage your household members',
                          style: TextStyle(
                            fontSize: 14.f,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Segoe UI',
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: EmptyStateWidget(
                      icon: Icons.family_restroom,
                      title: 'No Household Found',
                      message:
                          'You are not currently part of any household.',
                    ),
                  ),
                ],
              );
            }

            return RefreshIndicator(
              onRefresh: () => ref
                  .read(myHouseholdNotifierProvider.notifier)
                  .getMyHousehold(forceRefresh: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      16.gapH,
                      Text(
                        'Family Ledger',
                        style: TextStyle(
                          fontSize: 24.f,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Segoe UI',
                          color: AppColors.textlogo,
                        ),
                      ),
                      4.gapH,
                      Text(
                        'View and manage your household members',
                        style: TextStyle(
                          fontSize: 14.f,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Segoe UI',
                          color: AppColors.grey,
                        ),
                      ),
                      20.gapH,
                      HouseholdInfoCard(
                        householdCode: household.householdCode,
                        barangay: household.barangays.name,
                        memberCount: household.memberCount,
                      ),
                      32.gapH,
                      FamilyRegistrySection(
                        members: household.householdMembers,
                        currentUserMemberId: household.myMemberId,
                      ),
                      24.gapH,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
