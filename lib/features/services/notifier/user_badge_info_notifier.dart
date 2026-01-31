import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/user_badge_info_model.dart';
import '../repository/user_badge_repository_impl.dart';

// REMOVED .autoDispose here
final badgeInfoNotifierProvider =
    NotifierProvider<BadgeInfoNotifier, DataState<UserBadgeInfo>>(
  BadgeInfoNotifier.new,
);

class BadgeInfoNotifier extends Notifier<DataState<UserBadgeInfo>> {
  @override
  DataState<UserBadgeInfo> build() {
    return const DataState.started();
  }

  Future<void> fetchBadgeInfo({required String mobileUserId}) async {
    state = const DataState.loading();
    
    final repository = ref.read(badgeRepositoryProvider);
    final result = await repository.getBadgeInfo(
      mobileUserId: mobileUserId,
    );
    
    // Check if still mounted before updating state
    if (ref.mounted) {
      state = result;
    }
  }

  void reset() {
    state = const DataState.started();
  }
}