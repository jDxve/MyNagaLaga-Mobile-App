import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/user.dart';
import '../repository/user_info_repository_impl.dart';

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