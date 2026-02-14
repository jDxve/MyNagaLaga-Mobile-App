import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/user_info_service.dart';
import 'user_info_repository.dart';

final userInfoRepositoryProvider = Provider<UserInfoRepository>((ref) {
  final service = ref.read(userInfoProvider);
  return UserInfoRepositoryImpl(service);
});

class UserInfoRepositoryImpl implements UserInfoRepository {
  final UserInfoService _service;
  User? _cacheUserInfo;

  UserInfoRepositoryImpl(this._service);

  @override
  Future<User> fetchUserInfo() async {
    if (_cacheUserInfo != null) return _cacheUserInfo!;

    final response = await _service.getUserInfo();

    if (response.response.statusCode == 200) {
      final rawData = response.data as Map<String, dynamic>;
      final userJson = rawData['data']?['mobile_user'] ?? rawData['data'];
      final user = User.fromJson(userJson);

      _cacheUserInfo = user;
      return user;
    } else {
      throw Exception('Failed to fetch user info');
    }
  }
}
