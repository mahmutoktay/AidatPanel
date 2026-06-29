import 'package:aidatpanel/features/auth/domain/entities/user_entity.dart';
import 'package:aidatpanel/features/auth/presentation/onboarding/auth_onboarding_models.dart';
import 'package:aidatpanel/features/auth/presentation/onboarding/auth_onboarding_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthOnboardingNotifier visibleSteps', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('giriş e-posta yolunda 3 adım', () {
      final n = container.read(authOnboardingProvider.notifier);
      n.selectRole(UserRole.manager);
      n.startReturningLogin();
      n.setContactChannel(AuthContactChannel.email);
      n.setContactValue('yonetici@ornek.com');

      final steps = container.read(authOnboardingProvider).visibleSteps;
      expect(steps.length, 3);
      expect(steps, [
        AuthOnboardingStepId.role,
        AuthOnboardingStepId.contact,
        AuthOnboardingStepId.verification,
      ]);
    });

    test('yönetici kartı Adım 2 iletişime geçer', () {
      final n = container.read(authOnboardingProvider.notifier);
      n.pickManagerRole();

      final state = container.read(authOnboardingProvider);
      expect(state.currentStepId, AuthOnboardingStepId.contact);
      expect(state.role, UserRole.manager);
      expect(state.flow, AuthOnboardingFlow.register);
      expect(state.visibleSteps.length, 6);
    });

    test('sakin join deep link rol adımını atlar', () {
      final n = container.read(authOnboardingProvider.notifier);
      n.applyInitialQuery(
        role: UserRole.resident,
        flow: AuthOnboardingFlow.join,
        skipRoleStep: true,
      );

      final state = container.read(authOnboardingProvider);
      expect(state.currentStepId, AuthOnboardingStepId.contact);
      expect(state.visibleSteps.first, AuthOnboardingStepId.contact);
    });
  });
}
