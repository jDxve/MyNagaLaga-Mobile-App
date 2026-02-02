import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/models/responses/error_response.dart';
import '../models/shelter_data_model.dart';
import '../services/shelter_service.dart';
import 'shelter_repository.dart';

final shelterRepositoryProvider = Provider.autoDispose<ShelterRepositoryImpl>((ref) {
  final service = ref.watch(shelterServiceProvider);
  return ShelterRepositoryImpl(service: service);
});

class ShelterRepositoryImpl implements ShelterRepository {
  final ShelterService _service;

  ShelterRepositoryImpl({required ShelterService service}) : _service = service;

  @override
  Future<DataState<SheltersResponse>> getAllShelters() async {
    try {
      debugPrint("📤 Fetching all evacuation centers");
      final response = await _service.getAllEvacuationCenters();
      final raw = response.data;

      if (raw is String) {
        debugPrint("❌ Received HTML response instead of JSON");
        return const DataState.error(
          error: "API endpoint not found. Please check the server configuration.",
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
          error: raw['message'] ?? "Failed to fetch evacuation centers",
        );
      }

      // ✅ FIXED: Pass the entire response object, not just raw['data']
      final sheltersResponse = SheltersResponse.fromJson(raw);
      
      debugPrint("✅ Loaded ${sheltersResponse.totalShelters} evacuation centers");
      return DataState.success(data: sheltersResponse);
      
    } on DioException catch (e) {
      debugPrint("❌ Dio Error: ${e.response?.statusCode} - ${e.message}");
      
      if (e.response?.statusCode == 404) {
        return const DataState.error(
          error: "Evacuation centers endpoint not found. Please contact support.",
        );
      }

      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        try {
          final errorResponse = ErrorResponse.fromMap(
            e.response!.data as Map<String, dynamic>,
          );
          return DataState.error(
            error: errorResponse.message ?? "Failed to fetch evacuation centers",
          );
        } catch (_) {
          // Parsing failed, fall through
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