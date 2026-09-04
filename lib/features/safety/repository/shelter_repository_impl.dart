import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/models/responses/error_response.dart';
import '../models/shelter_data_model.dart';
import '../services/shelter_service.dart';
import 'shelter_repository.dart';

final shelterRepositoryProvider =
    Provider.autoDispose<ShelterRepositoryImpl>((ref) {
  final service = ref.watch(shelterServiceProvider);
  return ShelterRepositoryImpl(service: service);
});

class ShelterRepositoryImpl implements ShelterRepository {
  final ShelterService _service;

  ShelterRepositoryImpl({required ShelterService service})
      : _service = service;

  @override
  Future<DataState<SheltersResponse>> getAllShelters() async {
    try {
      final response = await _service.getAllEvacuationCenters();
      final raw = response.data;

      if (raw is! Map<String, dynamic>) {
        return const DataState.error(
          error: 'Unexpected response format from server',
        );
      }

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['message'] ?? 'Failed to fetch evacuation centers',
        );
      }

      final sheltersResponse = SheltersResponse.fromJson(raw);
      return DataState.success(data: sheltersResponse);
    } on DioException catch (e) {
      if (e.response?.data != null &&
          e.response?.data is Map<String, dynamic>) {
        try {
          final errorResponse =
              ErrorResponse.fromMap(e.response!.data as Map<String, dynamic>);
          return DataState.error(
            error: errorResponse.message ?? 'Failed to fetch evacuation centers',
          );
        } catch (_) {}
      }
      return DataState.error(error: e.message ?? 'Network error occurred');
    } catch (e) {
      return DataState.error(error: 'Unexpected error: $e');
    }
  }

  @override
  Future<DataState<AssignedCenterData>> getAssignedCenter() async {
    try {
      final response = await _service.getAssignedCenter();
      final raw = response.data;

      if (raw is! Map<String, dynamic>) {
        return const DataState.error(error: 'Unexpected response format');
      }

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['message'] ?? 'No assigned center found',
        );
      }

      final data = raw['data'] as Map<String, dynamic>?;
      if (data == null) {
        return const DataState.error(error: 'No assigned center found');
      }

      return DataState.success(data: AssignedCenterData.fromJson(data));
    } on DioException catch (e) {
      return DataState.error(error: e.message ?? 'Network error occurred');
    } catch (e) {
      return DataState.error(error: 'Unexpected error: $e');
    }
  }
}