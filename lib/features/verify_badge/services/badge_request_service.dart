import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mynagalaga_mobile_app/core/network/dio_factory.dart';

part 'badge_request_service.g.dart';

final badgeRequestServiceProvider =
    Provider.autoDispose<BadgeRequestService>((ref) {
  final dio = ref.watch(dioProvider);
  return BadgeRequestService(dio);
});

@RestApi()
abstract class BadgeRequestService {
  factory BadgeRequestService(Dio dio, {String? baseUrl}) =
      _BadgeRequestService;

  @POST('/badge-requests/apply')
  Future<HttpResponse> submitBadgeRequest(@Body() FormData formData);
}