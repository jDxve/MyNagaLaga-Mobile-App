import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/models/responses/error_response.dart';
import '../../home/models/user_badge_model.dart';
import '../../home/repository/user_badge_repository.dart';
import '../models/user_badge_info_model.dart';
import '../services/user_badge_service.dart';

final badgeRepositoryProvider = Provider<BadgeRepositoryImpl>((ref) {
  final service = ref.read(badgeServiceProvider);
  return BadgeRepositoryImpl(service: service);
});

class BadgeRepositoryImpl implements BadgeRepository {
  final UserBadgeService _service;
  
  BadgesResponse? _cachedBadges;
  String? _cachedBadgesUserId;
  
  UserBadgeInfo? _cachedBadgeInfo;
  String? _cachedBadgeInfoUserId;

  BadgeRepositoryImpl({required UserBadgeService service}) : _service = service;

  @override
  Future<DataState<BadgesResponse>> getApprovedBadges({
    required String mobileUserId,
  }) async {
    if (_cachedBadges != null && _cachedBadgesUserId == mobileUserId) {
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
      _cachedBadgesUserId = mobileUserId;

      return DataState.success(data: badgesResponse);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const DataState.error(error: "Badge endpoint not found");
      }

      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        try {
          final errorResponse = ErrorResponse.fromMap(
            e.response!.data as Map<String, dynamic>,
          );
          return DataState.error(
            error: errorResponse.message ?? "Failed to fetch badges",
          );
        } catch (_) {}
      }

      return DataState.error(
        error: e.message ?? "Network error occurred",
      );
    } catch (e) {
      return DataState.error(error: "Unexpected error: $e");
    }
  }

  Future<DataState<UserBadgeInfo>> getBadgeInfo({
    required String mobileUserId,
  }) async {
    if (_cachedBadgeInfo != null && _cachedBadgeInfoUserId == mobileUserId) {
      return DataState.success(data: _cachedBadgeInfo!);
    }

    try {
      final response = await _service.getBadgeInfo(
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
          error: raw['error']?.toString() ?? "Failed to fetch badge info",
        );
      }

      final badgeInfo = UserBadgeInfo.fromJson(raw['data']);
      
      _cachedBadgeInfo = badgeInfo;
      _cachedBadgeInfoUserId = mobileUserId;

      return DataState.success(data: badgeInfo);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const DataState.error(error: "No badge info found");
      }

      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        try {
          final errorResponse = ErrorResponse.fromMap(
            e.response!.data as Map<String, dynamic>,
          );
          return DataState.error(
            error: errorResponse.message ?? "Failed to fetch badge info",
          );
        } catch (_) {}
      }

      return DataState.error(
        error: e.message ?? "Network error occurred",
      );
    } catch (e) {
      return DataState.error(error: "Unexpected error: $e");
    }
  }

  @override
  void clearCache() {
    _cachedBadges = null;
    _cachedBadgesUserId = null;
    _cachedBadgeInfo = null;
    _cachedBadgeInfoUserId = null;
  }
}