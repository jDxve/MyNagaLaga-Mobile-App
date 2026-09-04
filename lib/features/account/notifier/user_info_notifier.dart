import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynagalaga_mobile_app/core/network/data_state.dart';
import 'package:mynagalaga_mobile_app/features/account/models/user.dart';
import 'package:mynagalaga_mobile_app/features/account/repository/user_info_repository_impl.dart';

final userInfoNotifierProvider =
    NotifierProvider<UserInfoNotifier, DataState<User>>(
  UserInfoNotifier.new,
);

class UserInfoNotifier extends Notifier<DataState<User>> {
  @override
  DataState<User> build() => const DataState.started();

  Future<void> fetchUserInfo() async {
    if (state is Success<User>) return;

    state = const DataState.loading();

    try {
      final repository = ref.read(userInfoRepositoryProvider);
      final user = await repository.fetchUserInfo();

      state = DataState.success(data: user);
    } catch (e) {
      state = DataState.error(error: e.toString());
    }
  }

  void reset() {
    state = const DataState.started();
  }
}