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

  @GET('/welfare-programs/postings')
  Future<HttpResponse<dynamic>> fetchPostings({
    @Query("programId") String? programId,  // ✅ Add this
    @Query("status") String? status,
    @Query("page") int page = 1,
    @Query("limit") int limit = 10,
  });
}
