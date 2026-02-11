import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/badge_request_model.dart';
import '../repository/badge_request_repository_impl.dart';

final badgeRequestNotifierProvider =
    NotifierProvider.autoDispose<BadgeRequestNotifier, DataState<BadgeRequestData>>(
  BadgeRequestNotifier.new,
);

class BadgeRequestNotifier extends Notifier<DataState<BadgeRequestData>> {
  @override
  DataState<BadgeRequestData> build() => const DataState.started();

  Future<void> submit({
    required String badgeTypeId,
    required String fullName,
    required String birthdate,
    required String gender,
    required String homeAddress,
    required String contactNumber,
    required String typeOfId,
    String? existingSeniorCitizenId,
    String? typeOfDisability,
    int? numberOfDependents,
    String? estimatedMonthlyHouseholdIncome,
    String? schoolName,
    String? educationLevel,
    String? yearOrGradeLevel,
    String? schoolIdNumber,
    required Map<String, List<File>> uploadedFiles,
  }) async {
    state = const DataState.loading();

    try {
      final repository = ref.read(badgeRequestRepositoryProvider);
      final result = await repository.submitBadgeRequest(
        badgeTypeId: badgeTypeId,
        fullName: fullName,
        birthdate: birthdate,
        gender: gender,
        homeAddress: homeAddress,
        contactNumber: contactNumber,
        typeOfId: typeOfId,
        existingSeniorCitizenId: existingSeniorCitizenId,
        typeOfDisability: typeOfDisability,
        numberOfDependents: numberOfDependents,
        estimatedMonthlyHouseholdIncome: estimatedMonthlyHouseholdIncome,
        schoolName: schoolName,
        educationLevel: educationLevel,
        yearOrGradeLevel: yearOrGradeLevel,
        schoolIdNumber: schoolIdNumber,
        uploadedFiles: uploadedFiles,
      );

      if (result != null) {
        state = DataState.success(data: result);
      } else {
        state = const DataState.error(error: 'Failed to submit badge request');
      }
    } catch (e) {
      state = DataState.error(error: e.toString());
    }
  }

  void reset() {
    state = const DataState.started();
  }
}