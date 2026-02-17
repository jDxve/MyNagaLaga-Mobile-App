import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/models/dio/data_state.dart';
import '../../../common/models/responses/error_response.dart';
import '../models/welfare_program_model.dart';
import '../services/welfare_programs_service.dart';

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

class WelfareProgramRepositoryImpl implements WelfareProgramRepository {
  final WelfareProgramsService _service;

  WelfareProgramRepositoryImpl({required WelfareProgramsService service})
      : _service = service;

  @override
  Future<DataState<List<WelfareProgramModel>>> getPrograms({
    bool? isActive,
    int page = 1,
    int limit = 100,
  }) async {
    try {
      debugPrint('📤 Fetching programs — isActive: $isActive');
      final response = await _service.fetchPrograms(
        isActive: isActive,
        page: page,
        limit: limit,
      );
      final List<dynamic> list = response.data['data'] ?? [];
      final programs = list
          .map((json) =>
              WelfareProgramModel.fromJson(json as Map<String, dynamic>))
          .toList();
      debugPrint('✅ Loaded ${programs.length} programs');
      return DataState.success(data: programs);
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.response?.data}');
      if (e.response?.data != null) {
        final error = ErrorResponse.fromMap(
          e.response!.data as Map<String, dynamic>,
        );
        return DataState.error(
            error: error.message ?? 'Failed to fetch programs');
      }
      return DataState.error(error: e.message ?? 'Network error');
    } catch (e) {
      return DataState.error(error: 'Unexpected error: $e');
    }
  }

  @override
  Future<DataState<List<WelfarePostingModel>>> getPostings({
    String? programId,
    String? serviceId,
    String? status,
    int page = 1,
    int limit = 50,
  }) async {
    try {
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
          .map((json) =>
              WelfarePostingModel.fromJson(json as Map<String, dynamic>))
          .toList();
      debugPrint('✅ Loaded ${postings.length} postings');
      return DataState.success(data: postings);
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.response?.data}');
      if (e.response?.data != null) {
        final error = ErrorResponse.fromMap(
          e.response!.data as Map<String, dynamic>,
        );
        return DataState.error(
            error: error.message ?? 'Failed to fetch postings');
      }
      return DataState.error(error: e.message ?? 'Network error');
    } catch (e) {
      return DataState.error(error: 'Unexpected error: $e');
    }
  }

  @override
  Future<DataState<WelfarePostingModel>> getPosting(String postingId) async {
    try {
      debugPrint('📤 Fetching posting detail — id: $postingId');
      final response = await _service.fetchPosting(postingId: postingId);
      final json = response.data['data'] as Map<String, dynamic>;
      final posting = WelfarePostingModel.fromJson(json);
      debugPrint('✅ Loaded posting: ${posting.title} '
          'with ${posting.requiredBadges.length} required badge(s)');
      return DataState.success(data: posting);
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.response?.data}');
      if (e.response?.data != null) {
        final error = ErrorResponse.fromMap(
          e.response!.data as Map<String, dynamic>,
        );
        return DataState.error(
            error: error.message ?? 'Failed to fetch posting');
      }
      return DataState.error(error: e.message ?? 'Network error');
    } catch (e) {
      return DataState.error(error: 'Unexpected error: $e');
    }
  }
}