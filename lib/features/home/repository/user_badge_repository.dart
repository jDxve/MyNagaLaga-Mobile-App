import '../../../common/models/dio/data_state.dart';
import '../models/user_badge_model.dart';

abstract class BadgeRepository {
  Future<DataState<BadgesResponse>> getApprovedBadges({
    required String mobileUserId,
  });
}