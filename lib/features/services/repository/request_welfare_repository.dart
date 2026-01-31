// request_welfare_repository.dart
import '../../../common/models/dio/data_state.dart';
import '../models/welfare_request_model.dart';

abstract class RequestWelfareRepository {
  Future<DataState<WelfareRequestResponseModel>> submitServiceRequest(
    WelfareRequestModel request,
  );
}