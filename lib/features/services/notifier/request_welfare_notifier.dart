// request_welfare_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/api_client.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/welfare_request_model.dart';
import '../repository/request_welfare_repository.dart';
import '../repository/request_welfare_repository_impl.dart';
import '../services/request_welfare_service.dart';

final requestWelfareNotifierProvider =
    NotifierProvider<RequestWelfareNotifier, DataState<WelfareRequestResponseModel>>(
  RequestWelfareNotifier.new,
);

class RequestWelfareNotifier extends Notifier<DataState<WelfareRequestResponseModel>> {
  late final RequestWelfareRepository _repository;

  @override
  DataState<WelfareRequestResponseModel> build() {
    final dio = ApiClient.fromEnv().create();
    final service = RequestWelfareService(dio);
    _repository = RequestWelfareRepositoryImpl(service: service);
    
    return const DataState.started();
  }

  Future<bool> submitRequest(WelfareRequestModel request) async {
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