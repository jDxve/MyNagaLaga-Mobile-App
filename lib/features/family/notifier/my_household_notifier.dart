import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/household_model.dart';
import '../repository/family_ledger_repository_impl.dart';

final myHouseholdNotifierProvider =
    NotifierProvider<MyHouseholdNotifier, DataState<Household?>>(
  MyHouseholdNotifier.new,
);

class MyHouseholdNotifier extends Notifier<DataState<Household?>> {
  @override
  DataState<Household?> build() => const DataState.started();

  Future<void> getMyHousehold({bool forceRefresh = false}) async {
    if (state is Success<Household?> && !forceRefresh) return;

    state = const DataState.loading();

    try {
      final repository = ref.read(familyLedgerRepositoryProvider);
      
      if (forceRefresh) {
        repository.clearCache();
      }

      final result = await repository.fetchMyHousehold();
      state = DataState.success(data: result);
    } catch (e) {
      state = DataState.error(error: e.toString());
    }
  }

  void reset() {
    final repository = ref.read(familyLedgerRepositoryProvider);
    repository.clearCache();
    state = const DataState.started();
  }
}