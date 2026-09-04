import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynagalaga_mobile_app/features/verify_badge/models/badge_type_model.dart';
import 'package:mynagalaga_mobile_app/features/verify_badge/services/badge_type_service.dart';
import 'package:mynagalaga_mobile_app/features/verify_badge/repository/badge_type_repository.dart';

final badgeTypeRepositoryProvider = Provider<BadgeTypeRepository>((ref) {
  final service = ref.read(badgeTypeServiceProvider);
  return BadgeTypeRepositoryImpl(service);
});

class BadgeTypeRepositoryImpl implements BadgeTypeRepository {
  final BadgeTypeService _service;
  List<BadgeType>? _cachedBadgeTypes;

  BadgeTypeRepositoryImpl(this._service);

  @override
  Future<List<BadgeType>> fetchBadgeTypes() async {
    if (_cachedBadgeTypes != null) return _cachedBadgeTypes!;

    try {
      final response = await _service.getBadgeTypes();
      
      if (response.response.statusCode == 200) {
        final Map<String, dynamic> rawData = response.data;
        final badgeResponse = BadgeTypesResponse.fromJson(rawData);
        
        _cachedBadgeTypes = badgeResponse.data;
        return badgeResponse.data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}