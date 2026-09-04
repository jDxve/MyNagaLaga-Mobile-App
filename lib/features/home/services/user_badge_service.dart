import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../../core/network/dio_factory.dart';

part 'user_badge_service.g.dart';

final badgeServiceProvider = Provider.autoDispose<UserBadgeService>((ref) {
  final dio = ref.watch(dioProvider);
  return UserBadgeService(dio);
});

@RestApi()
abstract class UserBadgeService {
  factory UserBadgeService(Dio dio, {String? baseUrl}) = _UserBadgeService;

  @GET('/badge-requests/mobile-user/{mobileUserId}/badges')
  Future<HttpResponse<dynamic>> getApprovedBadges({
    @Path("mobileUserId") required String mobileUserId,
  });
}
