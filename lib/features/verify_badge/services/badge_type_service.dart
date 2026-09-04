import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../../core/network/dio_factory.dart';

part 'badge_type_service.g.dart';

final badgeTypeServiceProvider = Provider.autoDispose<BadgeTypeService>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return BadgeTypeService(dio);
});

@RestApi()
abstract class BadgeTypeService {
  factory BadgeTypeService(Dio dio, {String? baseUrl}) = _BadgeTypeService;

  @GET('/badge-requests/types')
  Future<HttpResponse> getBadgeTypes();
}
