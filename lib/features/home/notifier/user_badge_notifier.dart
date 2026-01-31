import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/user_badge_model.dart';
import '../repository/user_badge_repository_impl.dart';

final badgesNotifierProvider = 
    NotifierProvider.autoDispose<BadgesNotifier, DataState<BadgesResponse>>(
  BadgesNotifier.new,
);

class BadgesNotifier extends Notifier<DataState<BadgesResponse>> {
  
  @override
  DataState<BadgesResponse> build() {
    // Don't auto-fetch since we need mobileUserId parameter
    return const DataState.started();
  }

  Future<void> fetchBadges({required String mobileUserId}) async {
    state = const DataState.loading();

    final repository = ref.read(badgeRepositoryProvider);
    final result = await repository.getApprovedBadges(
      mobileUserId: mobileUserId,
    );

    state = result;
  }

  void reset() {
    state = const DataState.started();
  }
}