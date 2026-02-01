// lib/features/services/repository/service_request_repository.dart

import '../../../common/models/dio/data_state.dart';
import '../models/service_request_model.dart';

abstract class ServiceRequestRepository {
  Future<DataState<List<CaseTypeModel>>> getCaseTypes();
  
  Future<DataState<ServiceRequestResponseModel>> submitServiceRequest(
    ServiceRequestModel request,
  );
  
  Future<DataState<List<ServiceRequestResponseModel>>> getMyServiceRequests({
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  });
  
  Future<DataState<ServiceRequestResponseModel>> getServiceRequestById(
    String id,
  );
}