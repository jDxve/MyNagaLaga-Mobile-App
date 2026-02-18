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

  Future<void> fetchPrefill({
    required String postingId,
    required List<String> attachedBadgeTypeIds,
    required WelfarePostingModel posting,
  }) async {
    state = const DataState.loading();
    final result =
        await ref.read(welfareServiceRepositoryProvider).fetchPrefill(
              postingId: postingId,
              attachedBadgeTypeIds: attachedBadgeTypeIds,
              posting: posting,
            );
    state = result;
  }

  Future<void> submitApplication({
    required String postingId,
    required String mobileUserId,
    required String description,
    required Map<String, String> textFields,
    required Map<String, File?> files,
    required WelfarePostingModel posting,
    required List<String> attachedBadgeTypeIds,
  }) async {
    state = const DataState.loading();
    final result =
        await ref.read(welfareServiceRepositoryProvider).submitServiceRequest(
              postingId: postingId,
              mobileUserId: mobileUserId,
              description: description,
              textFields: textFields,
              files: files,
              posting: posting,
              attachedBadgeTypeIds: attachedBadgeTypeIds,
            );
    state = result;
  }

  void reset(String postingId) {
    ref.read(welfareServiceRepositoryProvider).clearCache(postingId);
    state = const DataState.started();
  }
}