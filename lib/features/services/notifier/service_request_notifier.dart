// lib/features/services/notifier/service_request_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/api_client.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/service_request_model.dart';
import '../repository/service_request_repository.dart';
import '../repository/service_request_repository_impl.dart';
import '../services/service_request_service.dart';

// Provider for case types
final caseTypesNotifierProvider =
    NotifierProvider<CaseTypesNotifier, DataState<List<CaseTypeModel>>>(
  CaseTypesNotifier.new,
);

class CaseTypesNotifier extends Notifier<DataState<List<CaseTypeModel>>> {
  late final ServiceRequestRepository _repository;

  @override
  DataState<List<CaseTypeModel>> build() {
    final dio = ApiClient.fromEnv().create();
    final service = ServiceRequestService(dio);
    _repository = ServiceRequestRepositoryImpl(service: service);
    return const DataState.started();
  }

  Future<void> fetchCaseTypes() async {
    state = const DataState.loading();
    final result = await _repository.getCaseTypes();
    if (ref.mounted) {
      state = result;
    }
  }

  void reset() {
    state = const DataState.started();
  }
}

// Provider for submitting service requests
final submitServiceRequestNotifierProvider = NotifierProvider<
    SubmitServiceRequestNotifier,
    DataState<ServiceRequestResponseModel>>(
  SubmitServiceRequestNotifier.new,
);

class SubmitServiceRequestNotifier
    extends Notifier<DataState<ServiceRequestResponseModel>> {
  late final ServiceRequestRepository _repository;

  @override
  DataState<ServiceRequestResponseModel> build() {
    final dio = ApiClient.fromEnv().create();
    final service = ServiceRequestService(dio);
    _repository = ServiceRequestRepositoryImpl(service: service);
    return const DataState.started();
  }

  Future<bool> submitServiceRequest(ServiceRequestModel request) async {
    state = const DataState.loading();
    final result = await _repository.submitServiceRequest(request);
    if (ref.mounted) {
      state = result;
    }
    return result.when(
      started: () => false,
      loading: () => false,
      success: (data) => true,
      error: (error) => false,
    );
  }

  void reset() {
    state = const DataState.started();
  }
}

// Provider for user's service requests
final myServiceRequestsNotifierProvider = NotifierProvider<
    MyServiceRequestsNotifier,
    DataState<List<ServiceRequestResponseModel>>>(
  MyServiceRequestsNotifier.new,
);

class MyServiceRequestsNotifier
    extends Notifier<DataState<List<ServiceRequestResponseModel>>> {
  late final ServiceRequestRepository _repository;

  @override
  DataState<List<ServiceRequestResponseModel>> build() {
    final dio = ApiClient.fromEnv().create();
    final service = ServiceRequestService(dio);
    _repository = ServiceRequestRepositoryImpl(service: service);
    return const DataState.started();
  }

  Future<void> fetchMyRequests({
    String? status,
    String? search,
    int page = 1,
  }) async {
    state = const DataState.loading();
    final result = await _repository.getMyServiceRequests(
      status: status,
      search: search,
      page: page,
    );
    if (ref.mounted) {
      state = result;
    }
  }

  void reset() {
    state = const DataState.started();
  }
}