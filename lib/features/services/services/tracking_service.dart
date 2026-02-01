// lib/features/tracking/services/tracking_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../../common/models/dio/api_client.dart';

part 'tracking_service.g.dart';

final trackingServiceProvider = Provider.autoDispose<TrackingService>((ref) {
  final dio = ApiClient.fromEnv().create();
  return TrackingService(dio);
});

@RestApi()
abstract class TrackingService {
  factory TrackingService(Dio dio, {String? baseUrl}) = _TrackingService;

  // Get all tracking items (unified feed)
  @GET('/mobile-tracking/{mobileUserId}/all')
  Future<HttpResponse<dynamic>> getAllTracking(
    @Path('mobileUserId') String mobileUserId, {
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('module') String? module,
    @Query('status') String? status,
    @Query('search') String? search,
  });

  // Get applications
  @GET('/mobile-tracking/{mobileUserId}/applications')
  Future<HttpResponse<dynamic>> getApplications(
    @Path('mobileUserId') String mobileUserId, {
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('status') String? status,
    @Query('search') String? search,
  });

  // Get programs
  @GET('/mobile-tracking/{mobileUserId}/programs')
  Future<HttpResponse<dynamic>> getPrograms(
    @Path('mobileUserId') String mobileUserId, {
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('status') String? status,
    @Query('search') String? search,
  });

  // Get services
  @GET('/mobile-tracking/{mobileUserId}/services')
  Future<HttpResponse<dynamic>> getServices(
    @Path('mobileUserId') String mobileUserId, {
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('status') String? status,
    @Query('search') String? search,
  });

  // Get cases
  @GET('/mobile-tracking/{mobileUserId}/cases')
  Future<HttpResponse<dynamic>> getCases(
    @Path('mobileUserId') String mobileUserId, {
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('status') String? status,
    @Query('search') String? search,
  });

  // Get complaints
  @GET('/mobile-tracking/{mobileUserId}/complaints')
  Future<HttpResponse<dynamic>> getComplaints(
    @Path('mobileUserId') String mobileUserId, {
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('status') String? status,
    @Query('search') String? search,
  });

  // Get badge requests
  @GET('/mobile-tracking/{mobileUserId}/badge-requests')
  Future<HttpResponse<dynamic>> getBadgeRequests(
    @Path('mobileUserId') String mobileUserId, {
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('status') String? status,
    @Query('search') String? search,
  });
}