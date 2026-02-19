import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../../common/models/dio/api_client.dart';

part 'tracking_service.g.dart';

final trackingServiceProvider = Provider.autoDispose<TrackingService>((ref) {
  return TrackingService(ApiClient.fromEnv().create());
});

@RestApi()
abstract class TrackingService {
  factory TrackingService(Dio dio, {String? baseUrl}) = _TrackingService;

  @GET('/mobile-tracking/{mobileUserId}/all')
  Future<HttpResponse<dynamic>> getAllTracking(
    @Path('mobileUserId') String mobileUserId, {
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('module') String? module,
    @Query('status') String? status,
    @Query('search') String? search,
  });

  @GET('/mobile-tracking/{mobileUserId}/programs')
  Future<HttpResponse<dynamic>> getPrograms(
    @Path('mobileUserId') String mobileUserId, {
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('status') String? status,
    @Query('search') String? search,
  });

  @GET('/mobile-tracking/{mobileUserId}/services')
  Future<HttpResponse<dynamic>> getServices(
    @Path('mobileUserId') String mobileUserId, {
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('status') String? status,
    @Query('search') String? search,
  });

  @GET('/mobile-tracking/{mobileUserId}/complaints')
  Future<HttpResponse<dynamic>> getComplaints(
    @Path('mobileUserId') String mobileUserId, {
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('status') String? status,
    @Query('search') String? search,
  });

  @GET('/mobile-tracking/{mobileUserId}/badge-requests')
  Future<HttpResponse<dynamic>> getBadgeRequests(
    @Path('mobileUserId') String mobileUserId, {
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('status') String? status,
    @Query('search') String? search,
  });

  @POST('/feedbacks/mobile')
  Future<HttpResponse<dynamic>> createFeedback(
    @Body() Map<String, dynamic> body,
  );

  @PUT('/feedbacks/mobile/{id}')
  Future<HttpResponse<dynamic>> updateFeedback(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @GET('/feedbacks/mobile/pending')
  Future<HttpResponse<dynamic>> getPendingFeedbackRequests();
}