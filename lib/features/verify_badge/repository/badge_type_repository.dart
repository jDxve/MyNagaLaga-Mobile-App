import '../models/badge_type_model.dart';

abstract class BadgeTypeRepository {
  Future<List<BadgeType>> fetchBadgeTypes();
}