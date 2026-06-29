import 'package:aidatpanel/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aidatpanel/features/auth/domain/entities/user_entity.dart';
import 'package:aidatpanel/features/auth/domain/entities/saved_login_hint.dart';
import 'package:aidatpanel/features/auth/presentation/onboarding/auth_onboarding_screen.dart';
import 'package:aidatpanel/features/auth/presentation/providers/auth_provider.dart';
import 'package:aidatpanel/l10n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.tr);
  });

  testWidgets('AuthOnboardingScreen temel bileşenleri render eder', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const AuthOnboardingScreen()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        ],
        child: TranslationProvider(
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(t.features.auth.onboarding.step1Title), findsOneWidget);
    expect(find.text(t.common.manager), findsOneWidget);
    expect(find.text(t.common.resident), findsOneWidget);
  });
}

class _FakeAuthRepository implements AuthRepository {
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
  Future<UserEntity> login(String identifier, String password) async {
    return const UserEntity(
      id: 'u1',
      email: 'test@aidatpanel.com',
      name: 'Test',
      role: UserRole.resident,
    );
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
  Future<void> resetPassword(String token, String password) async {}

  @override
  Future<UserEntity?> restoreSession() async => null;

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
}
