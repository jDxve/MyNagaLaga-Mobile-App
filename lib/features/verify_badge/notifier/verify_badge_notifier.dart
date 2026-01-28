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
    required String mobileUserId,
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
    String? submittedByUserProfileId,
    String? existingSeniorCitizenId,
    String? typeOfDisability,
    int? numberOfDependents,
    String? estimatedMonthlyHouseholdIncome,
    String? schoolName,
    String? educationLevel,
    String? yearOrGradeLevel,
    String? schoolIdNumber,
  }) async {
    print('🔔 VerifyBadgeNotifier: submitBadge called');
    print('📋 Notifier State: Setting to loading...');
    state = const DataState.loading();

    final repository = ref.read(verifyBadgeRepositoryProvider);
    print('📞 Notifier: Calling repository...');

    final result = await repository.submitBadgeApplication(
      mobileUserId: mobileUserId,
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
      submittedByUserProfileId: submittedByUserProfileId,
      existingSeniorCitizenId: existingSeniorCitizenId,
      typeOfDisability: typeOfDisability,
      numberOfDependents: numberOfDependents,
      estimatedMonthlyHouseholdIncome: estimatedMonthlyHouseholdIncome,
      schoolName: schoolName,
      educationLevel: educationLevel,
      yearOrGradeLevel: yearOrGradeLevel,
      schoolIdNumber: schoolIdNumber,
    );

    print('📦 Notifier: Repository returned result');
    result.when(
      started: () => print('⚪ Result: started'),
      loading: () => print('🔄 Result: loading'),
      success: (data) {
        print('✅ Result: SUCCESS');
        print('📦 Data: $data');
      },
      error: (error) {
        print('❌ Result: ERROR');
        print('❌ Error: $error');
      },
    );

    state = result;
    print('📋 Notifier State updated');
  }

  void reset() {
    print('🔄 Notifier: Resetting state');
    state = const DataState.started();
  }
}