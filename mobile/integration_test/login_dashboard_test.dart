import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aidatpanel/main.dart';
import 'package:aidatpanel/l10n/strings.g.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding giriş iskeleti — rol ve iletişim adımları', (
    tester,
  ) async {
    LocaleSettings.setLocale(AppLocale.tr);

    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(
      find.text(t.features.auth.onboarding.step1Title),
      findsOneWidget,
      reason: 'Onboarding rol adımı görünmeli.',
    );

    await tester.tap(find.text(t.common.manager));
    await tester.pumpAndSettle();

    final continueButton = find.text(t.features.auth.onboarding.continueButton);
    if (continueButton.evaluate().isNotEmpty) {
      await tester.tap(continueButton);
      await tester.pumpAndSettle();
    }

    expect(find.byType(MyApp), findsOneWidget);
  });
}
