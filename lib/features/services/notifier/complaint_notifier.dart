// lib/features/services/notifier/complaint_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/api_client.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/complaint_model.dart';
import '../repository/complaint_repository.dart';
import '../repository/complaint_repository_impl.dart';
import '../services/complaint_service.dart';

// Provider for complaint types
final complaintTypesNotifierProvider =
    NotifierProvider<ComplaintTypesNotifier, DataState<List<ComplaintTypeModel>>>(
  ComplaintTypesNotifier.new,
);

class ComplaintTypesNotifier extends Notifier<DataState<List<ComplaintTypeModel>>> {
  late final ComplaintRepository _repository;

  @override
  DataState<List<ComplaintTypeModel>> build() {
    final dio = ApiClient.fromEnv().create();
    final service = ComplaintService(dio);
    _repository = ComplaintRepositoryImpl(service: service);
    return const DataState.started();
  }

  Future<void> fetchComplaintTypes() async {
    state = const DataState.loading();
    final result = await _repository.getComplaintTypes();
    if (ref.mounted) {
      state = result;
    }
  }

  void reset() {
    state = const DataState.started();
  }
}

// Provider for submitting complaints
final submitComplaintNotifierProvider =
    NotifierProvider<SubmitComplaintNotifier, DataState<ComplaintResponseModel>>(
  SubmitComplaintNotifier.new,
);

class SubmitComplaintNotifier extends Notifier<DataState<ComplaintResponseModel>> {
  late final ComplaintRepository _repository;

  @override
  DataState<ComplaintResponseModel> build() {
    final dio = ApiClient.fromEnv().create();
    final service = ComplaintService(dio);
    _repository = ComplaintRepositoryImpl(service: service);
    return const DataState.started();
  }

  Future<bool> submitComplaint(ComplaintModel complaint) async {
    state = const DataState.loading();
    final result = await _repository.submitComplaint(complaint);
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