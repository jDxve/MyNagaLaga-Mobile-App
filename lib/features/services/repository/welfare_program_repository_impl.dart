import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/models/dio/data_state.dart';
import '../../../common/models/responses/error_response.dart';

import '../models/welfare_program_model.dart';
import '../services/welfare_programs_service.dart';
import 'welfare_program_repository.dart';

final welfareProgramRepositoryProvider =
    Provider.autoDispose<WelfareProgramRepositoryImpl>((ref) {
  final service = ref.watch(welfareProgramsServiceProvider);
  return WelfareProgramRepositoryImpl(service: service);
});

class WelfareProgramRepositoryImpl implements WelfareProgramRepository {
  final WelfareProgramsService _service;

  WelfareProgramRepositoryImpl({required WelfareProgramsService service})
      : _service = service;

  @override
  Future<DataState<List<WelfarePostingModel>>> getPostings({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      debugPrint("📤 Fetching Welfare Postings...");

      final response = await _service.fetchPostings(
        status: status,
        page: page,
        limit: limit,
      );

      final raw = response.data;

      // Backend returns { data: [...] }
      final List<dynamic> list = raw["data"];

      final postings = list
          .map((json) => WelfarePostingModel.fromJson(json))
          .toList();

      debugPrint("✅ Loaded ${postings.length} postings");

      return DataState.success(data: postings);
    } on DioException catch (e) {
      debugPrint("❌ Dio Error: ${e.response?.data}");

      if (e.response?.data != null) {
        final errorResponse =
            ErrorResponse.fromMap(e.response!.data as Map<String, dynamic>);

        return DataState.error(
          error: errorResponse.message ?? "Failed to fetch postings",
        );
      }

      return DataState.error(
        error: e.message ?? "Network error occurred",
      );
    } catch (e) {
      return DataState.error(error: "Unexpected error: $e");
    }
  }
}
