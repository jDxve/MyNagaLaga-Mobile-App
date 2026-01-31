import '../../../common/models/dio/data_state.dart';
import '../../home/models/user_badge_model.dart' show BadgesResponse;

import '../models/user_badge_info_model.dart';

abstract class BadgeRepository {
  Future<DataState<BadgesResponse>> getApprovedBadges({
    required String mobileUserId,
  });

  Future<DataState<UserBadgeInfo>> getBadgeInfo({
    required String mobileUserId,
  });
}