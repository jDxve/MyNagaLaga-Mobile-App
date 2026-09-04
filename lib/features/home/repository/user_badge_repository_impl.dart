import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynagalaga_mobile_app/core/network/app_exception.dart';
import 'package:mynagalaga_mobile_app/core/network/data_state.dart';
import 'package:mynagalaga_mobile_app/core/network/repository_guard.dart';
import 'package:mynagalaga_mobile_app/features/home/models/user_badge_model.dart';
import 'package:mynagalaga_mobile_app/features/home/services/user_badge_service.dart';
import 'package:mynagalaga_mobile_app/features/home/repository/user_badge_repository.dart';

final badgeRepositoryProvider = Provider<BadgeRepositoryImpl>((ref) {
  final service = ref.read(badgeServiceProvider);
  return BadgeRepositoryImpl(service);
});

class BadgeRepositoryImpl with RepositoryGuard implements BadgeRepository {
  final UserBadgeService _service;
  BadgesResponse? _cachedBadges;
  String? _cachedUserId;

  BadgeRepositoryImpl(this._service);

  @override
  Future<DataState<BadgesResponse>> getApprovedBadges({
    required String mobileUserId,
  }) async {
    if (_cachedBadges != null && _cachedUserId == mobileUserId) {
      return DataState.success(data: _cachedBadges!);
    }

    return guard(
      () async {
        final response = await _service.getApprovedBadges(mobileUserId: mobileUserId);
        final raw = response.data;

        if (raw is String) {
          throw const AppException(message: 'API endpoint not found');
        }
        if (raw is! Map<String, dynamic>) {
          throw const AppException(message: 'Unexpected response format');
        }
        if (raw['success'] != true) {
          throw AppException(message: raw['error']?.toString() ?? 'Failed to fetch badges');
        }
        final data = raw['data'];
        if (data is! List) {
          throw const AppException(message: 'Invalid data format');
        }

        final badgesResponse = BadgesResponse.fromJson(data);
        _cachedBadges = badgesResponse;
        _cachedUserId = mobileUserId;
        return badgesResponse;
      },
      mapError: (e) => e.response?.statusCode == 404
          ? const AppException(statusCode: 404, message: 'Badge endpoint not found')
          : AppException.fromDioException(e, fallbackMessage: 'Failed to fetch badges'),
    );
  }

  @override
  void clearCache() {
    _cachedBadges = null;
    _cachedUserId = null;
  }
}
