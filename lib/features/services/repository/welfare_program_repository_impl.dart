import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mynagalaga_mobile_app/core/network/data_state.dart';
import 'package:mynagalaga_mobile_app/core/network/repository_guard.dart';
import 'package:mynagalaga_mobile_app/features/services/models/welfare_program_model.dart';
import 'package:mynagalaga_mobile_app/features/services/services/welfare_programs_service.dart';

// ─── Abstract ───────────────────────────────────────────────

abstract class WelfareProgramRepository {
  Future<DataState<List<WelfareProgramModel>>> getPrograms({
    bool? isActive,
    int page,
    int limit,
  });

  Future<DataState<List<WelfarePostingModel>>> getPostings({
    String? programId,
    String? serviceId,
    String? status,
    int page,
    int limit,
  });

  Future<DataState<WelfarePostingModel>> getPosting(String postingId);
}

// ─── Provider ───────────────────────────────────────────────

final welfareProgramRepositoryProvider =
    Provider.autoDispose<WelfareProgramRepositoryImpl>((ref) {
  final service = ref.watch(welfareProgramsServiceProvider);
  return WelfareProgramRepositoryImpl(service: service);
});

// ─── Implementation ─────────────────────────────────────────

class WelfareProgramRepositoryImpl
    with RepositoryGuard
    implements WelfareProgramRepository {
  final WelfareProgramsService _service;

  WelfareProgramRepositoryImpl({required WelfareProgramsService service})
      : _service = service;

  @override
  Future<DataState<List<WelfareProgramModel>>> getPrograms({
    bool? isActive,
    int page = 1,
    int limit = 100,
  }) =>
      guard(
        () async {
          debugPrint('📤 Fetching programs — isActive: $isActive');
          final response = await _service.fetchPrograms(
            isActive: isActive,
            page: page,
            limit: limit,
          );
          final List<dynamic> list = response.data['data'] ?? [];
          final programs = list
              .map((json) => WelfareProgramModel.fromJson(json as Map<String, dynamic>))
              .toList();
          debugPrint('✅ Loaded ${programs.length} programs');
          return programs;
        },
        fallbackMessage: 'Failed to fetch programs',
      );

  @override
  Future<DataState<List<WelfarePostingModel>>> getPostings({
    String? programId,
    String? serviceId,
    String? status,
    int page = 1,
    int limit = 50,
  }) =>
      guard(
        () async {
          debugPrint(
              '📤 Fetching postings — programId: $programId, serviceId: $serviceId, status: $status');
          final response = await _service.fetchPostings(
            programId: programId,
            serviceId: serviceId,
            status: status,
            page: page,
            limit: limit,
          );
          final List<dynamic> list = response.data['data'] ?? [];
          final postings = list
              .map((json) => WelfarePostingModel.fromJson(json as Map<String, dynamic>))
              .toList();
          debugPrint('✅ Loaded ${postings.length} postings');
          return postings;
        },
        fallbackMessage: 'Failed to fetch postings',
      );

  @override
  Future<DataState<WelfarePostingModel>> getPosting(String postingId) => guard(
        () async {
          debugPrint('📤 Fetching posting detail — id: $postingId');
          final response = await _service.fetchPosting(postingId: postingId);
          final json = response.data['data'] as Map<String, dynamic>;
          final posting = WelfarePostingModel.fromJson(json);
          debugPrint('✅ Loaded posting: ${posting.title} '
              'with ${posting.requiredBadges.length} required badge(s)');
          return posting;
        },
        fallbackMessage: 'Failed to fetch posting',
      );
}
