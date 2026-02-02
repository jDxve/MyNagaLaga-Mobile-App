import '../../../common/models/dio/data_state.dart';
import '../models/shelter_data_model.dart';

abstract class ShelterRepository {
  Future<DataState<SheltersResponse>> getAllShelters();
}