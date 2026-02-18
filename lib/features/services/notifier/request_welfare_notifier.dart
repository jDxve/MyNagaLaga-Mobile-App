import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/welfare_program_model.dart';
import '../models/welfare_request_model.dart';
import '../repository/request_welfare_repository_impl.dart';

final welfareServiceNotifierProvider =
    NotifierProvider<WelfareServiceNotifier, DataState<WelfareRequestModel>>(
  WelfareServiceNotifier.new,
);

class WelfareServiceNotifier extends Notifier<DataState<WelfareRequestModel>> {
  @override
  DataState<WelfareRequestModel> build() => const DataState.started();

  Future<void> submitApplication({
    required String postingId,
    required String mobileUserId,
    required String description,
    required Map<String, String> textFields,
    required Map<String, File?> files,
    required WelfarePostingModel posting,
  }) async {
    final repo = ref.read(welfareServiceRepositoryProvider);

    final cached = repo.getCached(postingId);
    if (cached != null) {
      state = DataState.success(data: cached);
      return;
    }

    state = const DataState.loading();

    final result = await repo.submitServiceRequest(
      postingId: postingId,
      mobileUserId: mobileUserId,
      description: description,
      textFields: textFields,
      files: files,
      posting: posting,
    );

    state = result;
  }

  void reset(String postingId) {
    ref.read(welfareServiceRepositoryProvider).clearCache(postingId);
    state = const DataState.started();
  }
}