import 'package:mynagalaga_mobile_app/features/account/models/user.dart';

abstract class UserInfoRepository {
  Future<User> fetchUserInfo();
}