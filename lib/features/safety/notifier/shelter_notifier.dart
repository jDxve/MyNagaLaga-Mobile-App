import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynagalaga_mobile_app/core/network/data_state.dart';
import 'package:mynagalaga_mobile_app/features/safety/models/shelter_data_model.dart';
import 'package:mynagalaga_mobile_app/features/safety/repository/shelter_repository_impl.dart';

/// Nearest-first ordering for the evacuation-center list. Shelters with no
/// known distance yet sort last rather than first.
List<ShelterData> sortSheltersByDistance(
  List<ShelterData> shelters,
  Map<String, double> distances,
) {
  if (distances.isEmpty) return shelters;
  final sorted = List<ShelterData>.from(shelters);
  sorted.sort((a, b) {
    final distA = distances[a.id] ?? double.infinity;
    final distB = distances[b.id] ?? double.infinity;
    return distA.compareTo(distB);
  });
  return sorted;
}

/// The assigned-center banner needs a `ShelterData` to render even when the
/// user's assigned center isn't present in the fetched shelters list (e.g.
/// it's outside the current query). This synthesizes one from the assigned-
/// center response so the banner always has something to show.
ShelterData fallbackShelterFromAssignedCenter(AssignedCenterData assigned) {
  return ShelterData(
    id: assigned.centerId,
    name: assigned.centerName,
    address: assigned.address,
    capacity: '${assigned.currentOccupancy}/${assigned.maxCapacity}',
    currentOccupancy: assigned.currentOccupancy,
    maxCapacity: assigned.maxCapacity,
    status: ShelterStatus.available,
    latitude: assigned.latitude,
    longitude: assigned.longitude,
    seniors: 0,
    infants: 0,
    pwd: 0,
    barangayName: assigned.barangayName,
  );
}

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