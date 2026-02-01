// lib/features/services/services/service_request_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../../common/models/dio/api_client.dart';

part 'service_request_service.g.dart';

final serviceRequestServiceProvider = Provider.autoDispose<ServiceRequestService>((ref) {
  final dio = ApiClient.fromEnv().create();
  return ServiceRequestService(dio);
});

@RestApi()
abstract class ServiceRequestService {
  factory ServiceRequestService(Dio dio, {String? baseUrl}) = _ServiceRequestService;

  @GET('/welfare-cases/types')
  Future<HttpResponse<dynamic>> getCaseTypes();

  @POST('/welfare-cases/mobile')
  Future<HttpResponse<dynamic>> submitServiceRequest(
    @Body() FormData formData,
  );

  @GET('/welfare-cases/mobile')
  Future<HttpResponse<dynamic>> getMyServiceRequests(
    @Query('status') String? status,
    @Query('search') String? search,
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @GET('/welfare-cases/mobile/{id}')
  Future<HttpResponse<dynamic>> getServiceRequestById(
    @Path('id') String id,
  );
}