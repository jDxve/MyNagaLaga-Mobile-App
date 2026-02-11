import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/models/responses/error_response.dart';
import '../models/user_badge_model.dart';
import '../services/user_badge_service.dart';
import 'user_badge_repository.dart';

final badgeRepositoryProvider = Provider<BadgeRepositoryImpl>((ref) {
  final service = ref.read(badgeServiceProvider);
  return BadgeRepositoryImpl(service);
});

class BadgeRepositoryImpl implements BadgeRepository {
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

    try {
      final response = await _service.getApprovedBadges(
        mobileUserId: mobileUserId,
      );

      final raw = response.data;

      if (raw is String) {
        return const DataState.error(error: "API endpoint not found");
      }

      if (raw is! Map<String, dynamic>) {
        return const DataState.error(error: "Unexpected response format");
      }

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['error']?.toString() ?? "Failed to fetch badges",
        );
      }

      final data = raw['data'];

      if (data is! List) {
        return const DataState.error(error: "Invalid data format");
      }

      final badgesResponse = BadgesResponse.fromJson(data);

      _cachedBadges = badgesResponse;
      _cachedUserId = mobileUserId;

      return DataState.success(data: badgesResponse);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const DataState.error(error: "Badge endpoint not found");
      }

      if (e.response?.data != null &&
          e.response?.data is Map<String, dynamic>) {
        try {
          final errorResponse = ErrorResponse.fromMap(
            e.response!.data as Map<String, dynamic>,
          );
          return DataState.error(
            error: errorResponse.message ?? "Failed to fetch badges",
          );
        } catch (_) {}
      }

      return DataState.error(error: e.message ?? "Network error occurred");
    } catch (e) {
      return DataState.error(error: "Unexpected error: $e");
    }
  }

  @override
  void clearCache() {
    _cachedBadges = null;
    _cachedUserId = null;
  }
}
