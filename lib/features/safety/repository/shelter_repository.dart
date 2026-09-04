import 'package:mynagalaga_mobile_app/core/network/data_state.dart';
import 'package:mynagalaga_mobile_app/features/safety/models/shelter_data_model.dart';

abstract class ShelterRepository {
  Future<DataState<SheltersResponse>> getAllShelters();
  Future<DataState<AssignedCenterData>> getAssignedCenter();
}