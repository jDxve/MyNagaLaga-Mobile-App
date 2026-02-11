import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/badge_requirement_model.dart';
import '../repository/badge_requirement_repository_impl.dart';

final badgeRequirementsNotifierProvider =
    NotifierProvider.autoDispose<
      BadgeRequirementsNotifier,
      Map<String, DataState<BadgeRequirementsData>>
    >(BadgeRequirementsNotifier.new);

class BadgeRequirementsNotifier
    extends Notifier<Map<String, DataState<BadgeRequirementsData>>> {
  @override
  Map<String, DataState<BadgeRequirementsData>> build() => {};

  Future<void> fetch(String badgeTypeId) async {
    final currentState = state[badgeTypeId];
    if (currentState is Success) return;

    state = {...state, badgeTypeId: const DataState.loading()};

    try {
      final repository = ref.read(badgeRequirementRepositoryProvider);
      final result = await repository.fetchBadgeRequirements(badgeTypeId);

      if (result != null) {
        state = {...state, badgeTypeId: DataState.success(data: result)};
      } else {
        state = {
          ...state,
          badgeTypeId: const DataState.error(
            error: 'Failed to load requirements',
          ),
        };
      }
    } catch (e) {
      state = {...state, badgeTypeId: DataState.error(error: e.toString())};
    }
  }

  void reset(String badgeTypeId) {
    final newState = Map<String, DataState<BadgeRequirementsData>>.from(state);
    newState.remove(badgeTypeId);
    state = newState;
  }

  void clearAll() {
    state = {};
  }
}
