import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../../core/network/dio_factory.dart';
part 'shelter_service.g.dart';

final shelterServiceProvider = Provider.autoDispose<ShelterService>((ref) {
  final dio = ref.watch(dioProvider);
  return ShelterService(dio);
});

@RestApi()
abstract class ShelterService {
  factory ShelterService(Dio dio, {String? baseUrl}) = _ShelterService;

  @GET('/evacuation-centers/')
  Future<HttpResponse<dynamic>> getAllEvacuationCenters();

  @GET('/camp-manager/assigned-center')
  Future<HttpResponse<dynamic>> getAssignedCenter();

  @GET('/camp-manager/evacuees')
  Future<HttpResponse<dynamic>> getRegisteredEvacuees({
    @Query('centerId') required String centerId,
    @Query('disasterEventId') required String disasterEventId,
    @Query('page') int page = 1,
    @Query('limit') int limit = 100,
  });
}