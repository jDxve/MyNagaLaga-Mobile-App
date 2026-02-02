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

  Future<void> fetchAllShelters() async {
    state = const DataState.loading();
    final repository = ref.read(shelterRepositoryProvider);
    final result = await repository.getAllShelters();

    // Update state - no need to check mounted in Notifier
    state = result;
  }

  void reset() {
    state = const DataState.started();
  }
}