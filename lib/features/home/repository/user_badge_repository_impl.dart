import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/models/responses/error_response.dart';
import '../models/user_badge_model.dart';
import '../services/user_badge_service.dart';
import 'user_badge_repository.dart';

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

      // Handle if response.data is a String (HTML error page)
      if (raw is String) {
        debugPrint("❌ Received HTML response instead of JSON");
        return const DataState.error(
          error: "API endpoint not found. Please check the server configuration.",
        );
      }

      // Ensure raw is a Map
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
      
      // Handle 404 specifically
      if (e.response?.statusCode == 404) {
        return const DataState.error(
          error: "Badge endpoint not found. Please contact support.",
        );
      }

      // Try to parse error response if it's JSON
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        try {
          final errorResponse = ErrorResponse.fromMap(
            e.response!.data as Map<String, dynamic>,
          );
          return DataState.error(
            error: errorResponse.message ?? "Failed to fetch badges",
          );
        } catch (_) {
          // If parsing fails, fall through to generic error
        }
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