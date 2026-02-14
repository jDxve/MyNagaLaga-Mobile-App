import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../../common/models/dio/api_client.dart';

part 'user_info_service.g.dart';

final userInfoProvider = Provider.autoDispose<UserInfoService>((ref) {
  final apiClient = ApiClient.fromEnv();
  final dio = apiClient.create();
  return UserInfoService(dio);
});

@RestApi()
abstract class UserInfoService {
  factory UserInfoService(Dio dio, {String? baseUrl}) = _UserInfoService;

  @GET('/mobile-auth/profile')
  Future<HttpResponse> getUserInfo();
}
