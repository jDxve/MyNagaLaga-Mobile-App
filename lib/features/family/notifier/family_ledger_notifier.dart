import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/household_access_model.dart';
import '../repository/family_ledger_repository_impl.dart';

final familyLedgerNotifierProvider =
    NotifierProvider<FamilyLedgerNotifier, DataState<HouseholdAccessModel>>(
  FamilyLedgerNotifier.new,
);

class FamilyLedgerNotifier extends Notifier<DataState<HouseholdAccessModel>> {
  @override
  DataState<HouseholdAccessModel> build() {
    return const DataState.started();
  }

  Future<void> fetchMyHousehold() async {
    state = const DataState.loading();
    
    final repository = ref.read(familyLedgerRepositoryProvider);
    final result = await repository.getMyHousehold();
    
    // Check if still mounted before updating state
    if (ref.mounted) {
      state = result;
    }
  }

  Future<void> addMember({
    required String householdId,
    required String residentId,
    required String relationshipToHead,
  }) async {
    final repository = ref.read(familyLedgerRepositoryProvider);
    final result = await repository.addHouseholdMember(
      householdId: householdId,
      residentId: residentId,
      relationshipToHead: relationshipToHead,
    );

    result.when(
      started: () {},
      loading: () {},
      success: (_) {
        // Refresh household data
        if (ref.mounted) {
          fetchMyHousehold();
        }
      },
      error: (message) {
        // Handle error - you can show snackbar here
      },
    );
  }

  Future<void> removeMember(String memberId) async {
    final repository = ref.read(familyLedgerRepositoryProvider);
    final result = await repository.removeHouseholdMember(memberId);

    result.when(
      started: () {},
      loading: () {},
      success: (_) {
        // Refresh household data
        if (ref.mounted) {
          fetchMyHousehold();
        }
      },
      error: (message) {
        // Handle error
      },
    );
  }

  void reset() {
    state = const DataState.started();
  }
}