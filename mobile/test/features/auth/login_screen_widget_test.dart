import 'package:aidatpanel/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aidatpanel/features/auth/domain/entities/user_entity.dart';
import 'package:aidatpanel/features/auth/presentation/providers/auth_provider.dart';
import 'package:aidatpanel/features/auth/presentation/screens/login_screen.dart';
import 'package:aidatpanel/l10n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.tr);
  });

  testWidgets('LoginScreen temel bileşenleri render eder', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [GoRoute(path: '/', builder: (_, _) => const LoginScreen())],
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

    expect(find.byKey(const ValueKey('email')), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text(t.features.auth.login), findsWidgets);
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
    String email,
    String password,
    String name,
    String? phone,
  ) async {}

  @override
  Future<void> resetPassword(String token, String password) async {}

  @override
  Future<UserEntity?> restoreSession() async => null;
}
