import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/user_badge_info_model.dart';
import '../repository/user_badge_repository_impl.dart';

final badgeInfoNotifierProvider =
    NotifierProvider<BadgeInfoNotifier, DataState<UserBadgeInfo>>(
  BadgeInfoNotifier.new,
);

class BadgeInfoNotifier extends Notifier<DataState<UserBadgeInfo>> {
  String? _cachedUserId;

  @override
  DataState<UserBadgeInfo> build() {
    ref.keepAlive();
    return const DataState.started();
  }

  Future<void> fetchBadgeInfo({
    required String mobileUserId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && mobileUserId == _cachedUserId && _hasValidData()) {
      return;
    }

    _cachedUserId = mobileUserId;
    state = const DataState.loading();

    final repository = ref.read(badgeRepositoryProvider);
    final result = await repository.getBadgeInfo(mobileUserId: mobileUserId);

    state = result;
  }

  bool _hasValidData() {
    return state.when(
      started: () => false,
      loading: () => false,
      success: (_) => true,
      error: (_) => false,
    );
  }

  void reset() {
    state = const DataState.started();
    _cachedUserId = null;
  }
}