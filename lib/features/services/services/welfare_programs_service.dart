import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

import '../../../common/models/dio/api_client.dart';

part 'welfare_programs_service.g.dart';

final welfareProgramsServiceProvider =
    Provider.autoDispose<WelfareProgramsService>((ref) {
  final dio = ApiClient.fromEnv().create();
  return WelfareProgramsService(dio);
});

@RestApi()
abstract class WelfareProgramsService {
  factory WelfareProgramsService(Dio dio, {String? baseUrl}) =
      _WelfareProgramsService;

  @GET('/welfare-programs/programs')
  Future<HttpResponse<dynamic>> fetchPrograms({
    @Query('isActive') bool? isActive,
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  @GET('/welfare-programs/postings')
  Future<HttpResponse<dynamic>> fetchPostings({
    @Query('programId') String? programId,
    @Query('serviceId') String? serviceId,
    @Query('status') String? status,
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  @GET('/welfare-programs/postings/{id}')
  Future<HttpResponse<dynamic>> fetchPosting({
    @Path('id') required String postingId,
  });
}