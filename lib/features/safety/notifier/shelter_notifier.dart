import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynagalaga_mobile_app/core/network/data_state.dart';
import 'package:mynagalaga_mobile_app/features/safety/models/shelter_data_model.dart';
import 'package:mynagalaga_mobile_app/features/safety/repository/shelter_repository_impl.dart';

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
    if (!forceRefresh && state is Success) return;

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

final assignedCenterNotifierProvider = NotifierProvider<
    AssignedCenterNotifier, DataState<AssignedCenterData>>(
  AssignedCenterNotifier.new,
);

class AssignedCenterNotifier
    extends Notifier<DataState<AssignedCenterData>> {
  @override
  DataState<AssignedCenterData> build() {
    return const DataState.started();
  }

  Future<void> fetch({bool forceRefresh = false}) async {
    if (!forceRefresh && state is Success) return;

    state = const DataState.loading();
    final repository = ref.read(shelterRepositoryProvider);
    final result = await repository.getAssignedCenter();
    state = result;
  }

  void reset() {
    state = const DataState.started();
  }
}