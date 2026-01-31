// lib/features/services/repository/complaint_repository.dart

import '../../../common/models/dio/data_state.dart';
import '../models/complaint_model.dart';

abstract class ComplaintRepository {
  Future<DataState<List<ComplaintTypeModel>>> getComplaintTypes();
  Future<DataState<ComplaintResponseModel>> submitComplaint(ComplaintModel complaint);
}