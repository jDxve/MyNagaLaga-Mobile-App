import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynagalaga_mobile_app/core/network/dio_factory.dart';
import 'package:mynagalaga_mobile_app/core/network/data_state.dart';
import 'package:mynagalaga_mobile_app/features/services/models/complaint_model.dart';
import 'package:mynagalaga_mobile_app/features/services/repository/complaint_repository_impl.dart';
import 'package:mynagalaga_mobile_app/features/services/services/complaint_service.dart';

final complaintTypesNotifierProvider =
    NotifierProvider<
      ComplaintTypesNotifier,
      DataState<List<ComplaintTypeModel>>
    >(ComplaintTypesNotifier.new);

class ComplaintTypesNotifier
    extends Notifier<DataState<List<ComplaintTypeModel>>> {
  late final _repository = ComplaintRepositoryImpl(
    service: ComplaintService(ref.watch(dioProvider)),
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
    service: ComplaintService(ref.watch(dioProvider)),
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
