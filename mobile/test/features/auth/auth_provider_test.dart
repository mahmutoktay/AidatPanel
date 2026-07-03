import 'package:aidatpanel/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aidatpanel/features/auth/domain/entities/user_entity.dart';
import 'package:aidatpanel/features/auth/domain/entities/saved_login_hint.dart';
import 'package:aidatpanel/features/auth/presentation/providers/auth_provider.dart';
import 'package:aidatpanel/l10n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.tr);
  });

  group('AuthNotifier submitLogin validation', () {
    testWidgets('boş şifre için hata döner ve login çağırmaz', (tester) async {
      final fakeRepo = _FakeAuthRepository();

      late WidgetRef capturedRef;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(fakeRepo)],
          child: TranslationProvider(
            child: MaterialApp(
              home: Consumer(
                builder: (_, ref, _) {
                  capturedRef = ref;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      final notifier = capturedRef.read(authStateProvider.notifier);
      await notifier.submitLogin('kullanici@ornek.com', '', capturedRef);

      final state = capturedRef.read(authStateProvider);
      expect(state.error, contains(t.features.auth.passwordRequired));
      expect(fakeRepo.loginCallCount, 0);
    });

    testWidgets('geçersiz email için hata döner ve login çağırmaz', (
      tester,
    ) async {
      final fakeRepo = _FakeAuthRepository();

      late WidgetRef capturedRef;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(fakeRepo)],
          child: TranslationProvider(
            child: MaterialApp(
              home: Consumer(
                builder: (_, ref, _) {
                  capturedRef = ref;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      final notifier = capturedRef.read(authStateProvider.notifier);
      await notifier.submitLogin(
        'bad@',
        'Deneme123!',
        capturedRef,
      );

      final state = capturedRef.read(authStateProvider);
      expect(state.error, contains(t.validation.emailInvalid));
      expect(fakeRepo.loginCallCount, 0);
    });
  });
}

class _FakeAuthRepository implements AuthRepository {
  int loginCallCount = 0;

  @override
  Future<UserEntity> login(String identifier, String password) async {
    loginCallCount++;
    return const UserEntity(
      id: 'u1',
      email: 'test@aidatpanel.com',
      name: 'Test',
      role: UserRole.resident,
    );
  }

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<UserEntity?> getStoredUser() async => null;

  @override
  Future<UserEntity> join(
    String inviteCode,
    String email,
    String password,
    String name,
    String? phone,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> logoutAllDevices() async {}

  @override
  Future<void> persistUser(UserEntity user) async {}

  @override
  Future<void> register(
    String? email,
    String password,
    String name,
    String? phone,
  ) async {}

  @override
  Future<void> sendOtp({
    String? phone,
    String? email,
    required String purpose,
  }) async {}

  @override
  Future<UserEntity> verifyOtp({
    String? phone,
    String? email,
    required String code,
    required String purpose,
    Map<String, dynamic>? payload,
    String? name,
    String? password,
    String? inviteCode,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String> validateInvite(String inviteCode) async => 'Test';

  @override
  Future<SavedLoginHint?> getSavedLoginHint(UserRole role) async => null;

  @override
  Future<void> resetPassword(String token, String password) async {}

  @override
  Future<UserEntity?> restoreSession() async => null;
}
