import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../repository/verify_badge_repository_impl.dart';

final verifyBadgeNotifierProvider =
    NotifierProvider.autoDispose<VerifyBadgeNotifier, DataState<dynamic>>(
  VerifyBadgeNotifier.new,
);

class VerifyBadgeNotifier extends Notifier<DataState<dynamic>> {
  @override
  DataState<dynamic> build() {
    return const DataState.started();
  }

  Future<void> submitBadge({
    required String residentId,
    required String badgeTypeId,
    required String fullName,
    required String birthdate,
    required String gender,
    required String homeAddress,
    required String contactNumber,
    required String typeOfId,
    required File frontId,
    required File backId,
    File? supportingFile,
    String? typeOfDisability,
    int? numberOfDependents,
    String? estimatedMonthlyHouseholdIncome,
    String? schoolName,
    String? educationLevel,
    String? yearOrGradeLevel,
    String? schoolIdNumber,
  }) async {
    state = const DataState.loading();

    final repository = ref.read(verifyBadgeRepositoryProvider);

    final result = await repository.submitBadgeApplication(
      residentId: residentId,
      badgeTypeId: badgeTypeId,
      fullName: fullName,
      birthdate: birthdate,
      gender: gender,
      homeAddress: homeAddress,
      contactNumber: contactNumber,
      typeOfId: typeOfId,
      frontId: frontId,
      backId: backId,
      supportingFile: supportingFile,
      typeOfDisability: typeOfDisability,
      numberOfDependents: numberOfDependents,
      estimatedMonthlyHouseholdIncome: estimatedMonthlyHouseholdIncome,
      schoolName: schoolName,
      educationLevel: educationLevel,
      yearOrGradeLevel: yearOrGradeLevel,
      schoolIdNumber: schoolIdNumber,
    );

    state = result;
  }

  void reset() {
    state = const DataState.started();
  }
}

