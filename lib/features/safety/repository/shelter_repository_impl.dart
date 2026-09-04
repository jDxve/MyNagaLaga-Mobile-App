import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynagalaga_mobile_app/core/network/app_exception.dart';
import 'package:mynagalaga_mobile_app/core/network/data_state.dart';
import 'package:mynagalaga_mobile_app/core/network/repository_guard.dart';
import 'package:mynagalaga_mobile_app/features/safety/models/shelter_data_model.dart';
import 'package:mynagalaga_mobile_app/features/safety/services/shelter_service.dart';
import 'package:mynagalaga_mobile_app/features/safety/repository/shelter_repository.dart';

final shelterRepositoryProvider =
    Provider.autoDispose<ShelterRepositoryImpl>((ref) {
  final service = ref.watch(shelterServiceProvider);
  return ShelterRepositoryImpl(service: service);
});

class ShelterRepositoryImpl with RepositoryGuard implements ShelterRepository {
  final ShelterService _service;

  ShelterRepositoryImpl({required ShelterService service})
      : _service = service;

  @override
  Future<DataState<SheltersResponse>> getAllShelters() => guard(() async {
        final response = await _service.getAllEvacuationCenters();
        final raw = response.data;

        if (raw is! Map<String, dynamic>) {
          throw const AppException(message: 'Unexpected response format from server');
        }
        if (raw['success'] != true) {
          throw AppException(message: raw['message'] ?? 'Failed to fetch evacuation centers');
        }
        return SheltersResponse.fromJson(raw);
      });

  @override
  Future<DataState<AssignedCenterData>> getAssignedCenter() => guard(() async {
        final response = await _service.getAssignedCenter();
        final raw = response.data;

        if (raw is! Map<String, dynamic>) {
          throw const AppException(message: 'Unexpected response format');
        }
        if (raw['success'] != true) {
          throw AppException(message: raw['message'] ?? 'No assigned center found');
        }
        final data = raw['data'] as Map<String, dynamic>?;
        if (data == null) {
          throw const AppException(message: 'No assigned center found');
        }
        return AssignedCenterData.fromJson(data);
      });
}
