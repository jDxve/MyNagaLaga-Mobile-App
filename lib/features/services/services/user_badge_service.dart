import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../../common/models/dio/api_client.dart';

part 'user_badge_service.g.dart';

final badgeServiceProvider = Provider.autoDispose<UserBadgeService>((ref) {
  final dio = ApiClient.fromEnv().create();
  return UserBadgeService(dio);
});

@RestApi()
abstract class UserBadgeService {
  factory UserBadgeService(Dio dio, {String? baseUrl}) = _UserBadgeService;

  @GET('/badge-requests/approved/badges')
  Future<HttpResponse<dynamic>> getApprovedBadges({
    @Query("mobileUserId") required String mobileUserId,
  });

  @GET('/badge-requests/badge-info')
  Future<HttpResponse<dynamic>> getBadgeInfo({
    @Query("mobileUserId") required String mobileUserId,
  });
}