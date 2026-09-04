import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynagalaga_mobile_app/core/network/data_state.dart';
import 'package:mynagalaga_mobile_app/features/home/models/user_badge_model.dart';
import 'package:mynagalaga_mobile_app/features/home/repository/user_badge_repository_impl.dart';

final badgesNotifierProvider =
    NotifierProvider<BadgesNotifier, DataState<BadgesResponse>>(
  BadgesNotifier.new,
);

class BadgesNotifier extends Notifier<DataState<BadgesResponse>> {
  @override
  DataState<BadgesResponse> build() {
    return const DataState.started();
  }

  Future<void> fetchBadges({
    required String mobileUserId,
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      ref.read(badgeRepositoryProvider).clearCache();
    }

    state = const DataState.loading();

    final repository = ref.read(badgeRepositoryProvider);
    final result = await repository.getApprovedBadges(
      mobileUserId: mobileUserId,
    );

    state = result;
  }

  void reset() {
    ref.read(badgeRepositoryProvider).clearCache();
    state = const DataState.started();
  }
}