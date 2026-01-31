import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/models/responses/error_response.dart';
import '../../home/models/user_badge_model.dart';
import '../../home/repository/user_badge_repository.dart';
import '../models/user_badge_info_model.dart';
import '../services/user_badge_service.dart';

final badgeRepositoryProvider = Provider.autoDispose<BadgeRepositoryImpl>((ref) {
  final service = ref.watch(badgeServiceProvider);
  return BadgeRepositoryImpl(service: service);
});

class BadgeRepositoryImpl implements BadgeRepository {
  final UserBadgeService _service;

  BadgeRepositoryImpl({required UserBadgeService service}) : _service = service;

  @override
  Future<DataState<BadgesResponse>> getApprovedBadges({
    required String mobileUserId,
  }) async {
    try {
      debugPrint("📤 Fetching Approved Badges for user: $mobileUserId");
      final response = await _service.getApprovedBadges(
        mobileUserId: mobileUserId,
      );

      final raw = response.data;

      if (raw is String) {
        debugPrint("❌ Received HTML response instead of JSON");
        return const DataState.error(
          error: "API endpoint not found.",
        );
      }

      if (raw is! Map<String, dynamic>) {
        debugPrint("❌ Unexpected response type: ${raw.runtimeType}");
        return const DataState.error(
          error: "Unexpected response format from server",
        );
      }

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['message'] ?? "Failed to fetch badges",
        );
      }

      final badgesResponse = BadgesResponse.fromJson(raw['data']);
      debugPrint("✅ Loaded ${badgesResponse.totalBadges} badges");
      return DataState.success(data: badgesResponse);
    } on DioException catch (e) {
      debugPrint("❌ Dio Error: ${e.response?.statusCode} - ${e.message}");

      if (e.response?.statusCode == 404) {
        return const DataState.error(
          error: "Badge endpoint not found.",
        );
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
      debugPrint("❌ Unexpected Error: $e");
      return DataState.error(error: "Unexpected error: $e");
    }
  }

  Future<DataState<UserBadgeInfo>> getBadgeInfo({
    required String mobileUserId,
  }) async {
    try {
      debugPrint("📤 Fetching Badge Info for user: $mobileUserId");
      final response = await _service.getBadgeInfo(
        mobileUserId: mobileUserId,
      );

      final raw = response.data;

      if (raw is String) {
        debugPrint("❌ Received HTML response instead of JSON");
        return const DataState.error(
          error: "API endpoint not found.",
        );
      }

      if (raw is! Map<String, dynamic>) {
        debugPrint("❌ Unexpected response type: ${raw.runtimeType}");
        return const DataState.error(
          error: "Unexpected response format from server",
        );
      }

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['error'] ?? "Failed to fetch badge info",
        );
      }

      final badgeInfo = UserBadgeInfo.fromJson(raw['data']);
      debugPrint("✅ Loaded badge info for ${badgeInfo.fullName}");
      return DataState.success(data: badgeInfo);
    } on DioException catch (e) {
      debugPrint("❌ Dio Error: ${e.response?.statusCode} - ${e.message}");

      if (e.response?.statusCode == 404) {
        return const DataState.error(
          error: "No badge info found for this user.",
        );
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
      debugPrint("❌ Unexpected Error: $e");
      return DataState.error(error: "Unexpected error: $e");
    }
  }
}
