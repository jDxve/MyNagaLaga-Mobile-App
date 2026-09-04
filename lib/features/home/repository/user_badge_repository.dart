import 'package:mynagalaga_mobile_app/core/network/data_state.dart';
import 'package:mynagalaga_mobile_app/features/home/models/user_badge_model.dart';

abstract class BadgeRepository {
  Future<DataState<BadgesResponse>> getApprovedBadges({
    required String mobileUserId,
  });

  void clearCache();
}