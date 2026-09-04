import 'package:mynagalaga_mobile_app/features/verify_badge/models/badge_requirement_model.dart';

abstract class BadgeRequirementRepository {
  Future<BadgeRequirementsData?> fetchBadgeRequirements(String badgeTypeId);
}