import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynagalaga_mobile_app/common/utils/ui_utils.dart';
import 'package:mynagalaga_mobile_app/core/network/data_state.dart';
import 'package:mynagalaga_mobile_app/features/verify_badge/models/badge_request_model.dart';
import 'package:mynagalaga_mobile_app/features/verify_badge/repository/badge_request_repository_impl.dart';

final badgeRequestNotifierProvider =
    NotifierProvider.autoDispose<BadgeRequestNotifier, DataState<BadgeRequestData>>(
  BadgeRequestNotifier.new,
);

/// Optional field text is trimmed and coalesced to null when empty, so
/// callers never have to repeat that ternary at every call site.
String? _trimmedOrNull(String? value) {
  final trimmed = value?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}

class BadgeRequestNotifier extends Notifier<DataState<BadgeRequestData>> {
  @override
  DataState<BadgeRequestData> build() => const DataState.started();

  /// Takes the raw form values as entered (unconverted date/gender/ID-type,
  /// unsanitized income) and owns turning them into the wire format the
  /// repository expects — that shaping is this notifier's job, not the
  /// screen's.
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
    String? numberOfDependents,
    String? estimatedMonthlyHouseholdIncome,
    String? schoolName,
    String? educationLevel,
    String? yearOrGradeLevel,
    String? schoolIdNumber,
    required Map<String, List<File>> uploadedFiles,
  }) async {
    if (gender.isEmpty) {
      state = const DataState.error(error: 'Please select your gender before submitting.');
      return;
    }
    if (typeOfId.isEmpty) {
      state = const DataState.error(error: 'Please select an ID type before submitting.');
      return;
    }
    if (birthdate.isEmpty) {
      state = const DataState.error(error: 'Please enter your date of birth.');
      return;
    }

    state = const DataState.loading();

    final cleanIncome = estimatedMonthlyHouseholdIncome?.replaceAll(RegExp(r'[^\d]'), '');

    try {
      final repository = ref.read(badgeRequestRepositoryProvider);
      final result = await repository.submitBadgeRequest(
        badgeTypeId: badgeTypeId,
        fullName: fullName.trim(),
        birthdate: UIUtils.convertDateToApiFormat(birthdate),
        gender: UIUtils.convertGenderToApiFormat(gender),
        homeAddress: homeAddress.trim(),
        contactNumber: contactNumber.trim(),
        typeOfId: UIUtils.convertIdTypeToApiFormat(typeOfId),
        existingSeniorCitizenId: _trimmedOrNull(existingSeniorCitizenId),
        typeOfDisability: _trimmedOrNull(typeOfDisability),
        numberOfDependents: int.tryParse(numberOfDependents?.trim() ?? ''),
        estimatedMonthlyHouseholdIncome:
            (cleanIncome == null || cleanIncome.isEmpty) ? null : cleanIncome,
        schoolName: _trimmedOrNull(schoolName),
        educationLevel: _trimmedOrNull(educationLevel),
        yearOrGradeLevel: _trimmedOrNull(yearOrGradeLevel),
        schoolIdNumber: _trimmedOrNull(schoolIdNumber),
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
