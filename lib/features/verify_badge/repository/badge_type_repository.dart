import 'package:mynagalaga_mobile_app/features/verify_badge/models/badge_type_model.dart';

abstract class BadgeTypeRepository {
  Future<List<BadgeType>> fetchBadgeTypes();
}