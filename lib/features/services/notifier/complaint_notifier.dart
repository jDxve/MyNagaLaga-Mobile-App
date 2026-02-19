import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/api_client.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/complaint_model.dart';
import '../repository/complaint_repository_impl.dart';
import '../services/complaint_service.dart';

final complaintTypesNotifierProvider =
    NotifierProvider<
      ComplaintTypesNotifier,
      DataState<List<ComplaintTypeModel>>
    >(ComplaintTypesNotifier.new);

class ComplaintTypesNotifier
    extends Notifier<DataState<List<ComplaintTypeModel>>> {
  late final _repository = ComplaintRepositoryImpl(
    service: ComplaintService(ApiClient.fromEnv().create()),
  );

  @override
  DataState<List<ComplaintTypeModel>> build() {
    Future.microtask(() => fetchComplaintTypes());
    return const DataState.loading();
  }

  Future<void> fetchComplaintTypes({bool forceRefresh = false}) async {
    if (!forceRefresh && state is Success) return;

    state = const DataState.loading();
    final result = await _repository.getComplaintTypes();
    if (ref.mounted) state = result;
  }

  void reset() => state = const DataState.started();
}

final submitComplaintNotifierProvider =
    NotifierProvider<
      SubmitComplaintNotifier,
      DataState<ComplaintResponseModel>
    >(SubmitComplaintNotifier.new);

class SubmitComplaintNotifier
    extends Notifier<DataState<ComplaintResponseModel>> {
  late final _repository = ComplaintRepositoryImpl(
    service: ComplaintService(ApiClient.fromEnv().create()),
  );

  @override
  DataState<ComplaintResponseModel> build() => const DataState.started();

  Future<bool> submitComplaint(ComplaintModel complaint) async {
    state = const DataState.loading();
    final result = await _repository.submitComplaint(complaint);
    if (ref.mounted) state = result;
    return result.maybeWhen(success: (_) => true, orElse: () => false);
  }

  void reset() => state = const DataState.started();
}
