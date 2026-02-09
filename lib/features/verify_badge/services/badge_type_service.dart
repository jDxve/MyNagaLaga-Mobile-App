import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../../common/models/dio/api_client.dart';

part 'badge_type_service.g.dart';

final badgeTypeServiceProvider = Provider.autoDispose<BadgeTypeService>((
  ref,
) {
  final apiClient = ApiClient.fromEnv();
  final dio = apiClient.create();
  return BadgeTypeService(dio);
});

@RestApi()
abstract class BadgeTypeService {
  factory BadgeTypeService(Dio dio, {String? baseUrl}) = _BadgeTypeService;

  @GET('/badge-requests/types')
  Future<HttpResponse> getBadgeTypes();
}
