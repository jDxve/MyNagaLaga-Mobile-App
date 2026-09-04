import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mynagalaga_mobile_app/core/network/dio_factory.dart';

part 'badge_requirement_service.g.dart';

final badgeRequirementServiceProvider =
    Provider.autoDispose<BadgeRequirementService>((ref) {
  final dio = ref.watch(dioProvider);
  return BadgeRequirementService(dio);
});

@RestApi()
abstract class BadgeRequirementService {
  factory BadgeRequirementService(Dio dio, {String? baseUrl}) =
      _BadgeRequirementService;

  @GET('/badge-requests/types/{badgeTypeId}/requirements')
  Future<HttpResponse> getBadgeRequirements(
    @Path('badgeTypeId') String badgeTypeId,
  );
}