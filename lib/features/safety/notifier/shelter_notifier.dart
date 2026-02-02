import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/shelter_data_model.dart';
import '../repository/shelter_repository._impl.dart';

final sheltersNotifierProvider =
    NotifierProvider<SheltersNotifier, DataState<SheltersResponse>>(
  SheltersNotifier.new,
);

class SheltersNotifier extends Notifier<DataState<SheltersResponse>> {
  @override
  DataState<SheltersResponse> build() {
    return const DataState.started();
  }

  Future<void> fetchAllShelters({bool forceRefresh = false}) async {
    // Don't reload if we already have data (unless force refresh)
    if (!forceRefresh) {
      state.whenOrNull(
        success: (_) => null, // Already has data, return early
      );
      // ignore: unnecessary_type_check
      if (state is! DataState<SheltersResponse> || 
          state.toString().contains('success')) {
        return;
      }
    }

    state = const DataState.loading();
    final repository = ref.read(shelterRepositoryProvider);
    final result = await repository.getAllShelters();
    state = result;
  }

  Future<void> refresh() async {
    await fetchAllShelters(forceRefresh: true);
  }

  void reset() {
    state = const DataState.started();
  }
}