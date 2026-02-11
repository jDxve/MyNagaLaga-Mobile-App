import '../models/badge_requirement_model.dart';

abstract class BadgeRequirementRepository {
  Future<BadgeRequirementsData?> fetchBadgeRequirements(String badgeTypeId);
}