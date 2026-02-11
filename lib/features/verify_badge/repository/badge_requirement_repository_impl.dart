import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge_requirement_model.dart';
import '../services/badge_requirement_service.dart';
import 'badge_requirement_repository.dart';

final badgeRequirementRepositoryProvider =
    Provider<BadgeRequirementRepository>((ref) {
  final service = ref.read(badgeRequirementServiceProvider);
  return BadgeRequirementRepositoryImpl(service);
});

class BadgeRequirementRepositoryImpl implements BadgeRequirementRepository {
  final BadgeRequirementService _service;
  final Map<String, BadgeRequirementsData> _cache = {};

  BadgeRequirementRepositoryImpl(this._service);

  @override
  Future<BadgeRequirementsData?> fetchBadgeRequirements(
      String badgeTypeId) async {
    if (_cache.containsKey(badgeTypeId)) return _cache[badgeTypeId];

    try {
      final response = await _service.getBadgeRequirements(badgeTypeId);
      if (response.response.statusCode == 200) {
        final Map<String, dynamic> rawData = response.data;
        final requirementsResponse =
            BadgeRequirementsResponse.fromJson(rawData);
        _cache[badgeTypeId] = requirementsResponse.data;
        return requirementsResponse.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}