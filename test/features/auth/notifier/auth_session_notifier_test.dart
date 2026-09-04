// Reference test proving the Phase C dual-secure-storage fix actually
// works: before that fix, AuthSessionNotifier constructed its own private
// FlutterSecureStorage internally, so overriding secureStorageProvider here
// would have had zero effect and this test could not have been written at
// all. Now the notifier reads the same shared provider dioProvider's
// AuthInterceptor uses, so overriding it lets us assert on calls that reach
// the mock instead of a real keystore.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mynagalaga_mobile_app/core/network/dio_factory.dart';
import 'package:mynagalaga_mobile_app/features/auth/notifier/auth_session_notifier.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage storage;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    storage = _MockSecureStorage();
    when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    when(() => storage.deleteAll()).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [secureStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);

    // Let build()'s fire-and-forget _checkSession() settle before each test
    // drives an intent, so it can't race a later state assignment.
    container.read(authSessionProvider);
    await Future<void>.delayed(const Duration(milliseconds: 10));
  });

  test('saveSession writes through the overridden secureStorageProvider', () async {
    await container.read(authSessionProvider.notifier).saveSession(
          accessToken: 'tok',
          email: 'a@b.com',
          userId: 'u1',
        );

    verify(() => storage.write(key: 'access_token', value: 'tok')).called(1);
    verify(() => storage.write(key: 'user_email', value: 'a@b.com')).called(1);
    verify(() => storage.write(key: 'user_id', value: 'u1')).called(1);

    final state = container.read(authSessionProvider);
    expect(state.isAuthenticated, isTrue);
    expect(state.accessToken, 'tok');
  });

  test('logout clears the same shared storage instance', () async {
    await container.read(authSessionProvider.notifier).saveSession(
          accessToken: 'tok',
          email: 'a@b.com',
          userId: 'u1',
        );

    await container.read(authSessionProvider.notifier).logout();

    verify(() => storage.deleteAll()).called(1);
    expect(container.read(authSessionProvider).isAuthenticated, isFalse);
  });
}
