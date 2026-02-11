import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/badge_type_model.dart';
import '../repository/badge_type_repository_impl.dart';

final badgeTypesNotifierProvider =
    NotifierProvider<BadgeTypesNotifier, DataState<List<BadgeType>>>(
  BadgeTypesNotifier.new,
);

class BadgeTypesNotifier extends Notifier<DataState<List<BadgeType>>> {
  @override
  DataState<List<BadgeType>> build() => const DataState.started();

  Future<void> getBadgeTypes() async {
    if (state is Success<List<BadgeType>>) return;
    state = const DataState.loading();

    final repository = ref.read(badgeTypeRepositoryProvider);
    final result = await repository.fetchBadgeTypes();

    if (result.isNotEmpty) {
      state = DataState.success(data: result);
    } else {
      state = const DataState.error(error: 'Failed to load badge types');
    }
  }

  void reset() {
    state = const DataState.started();
  }
}