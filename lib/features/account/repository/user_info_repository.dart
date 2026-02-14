import '../models/user.dart';

abstract class UserInfoRepository {
  Future<User> fetchUserInfo();
}