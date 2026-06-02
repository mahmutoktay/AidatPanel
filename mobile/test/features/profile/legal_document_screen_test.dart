import 'package:aidatpanel/features/profile/presentation/screens/legal_document_screen.dart';
import 'package:aidatpanel/l10n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slang_flutter/slang_flutter.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.tr);
  });

  Future<void> pumpLegal(
    WidgetTester tester,
    LegalDocumentKind kind,
  ) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: LegalDocumentScreen(kind: kind),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder footerEmailFinder() => find.byWidgetPredicate(
        (w) => w is SelectableText && w.data == t.legal.contactEmail,
      );

  Future<void> expectContactFooter(WidgetTester tester) async {
    final email = footerEmailFinder();
    await tester.scrollUntilVisible(email, 200);
    expect(find.text(t.legal.companyName), findsOneWidget);
    expect(email, findsOneWidget);
  }

  group('LegalDocumentScreen', () {
    testWidgets('privacy shows company and contact email', (tester) async {
      await pumpLegal(tester, LegalDocumentKind.privacy);
      expect(find.text(t.common.privacyPolicy), findsOneWidget);
      await expectContactFooter(tester);
    });

    testWidgets('kvkk shows company and contact email', (tester) async {
      await pumpLegal(tester, LegalDocumentKind.kvkk);
      expect(find.text(t.common.kvkk), findsOneWidget);
      await expectContactFooter(tester);
    });

    testWidgets('help placeholder mentions support email', (tester) async {
      await pumpLegal(tester, LegalDocumentKind.help);
      expect(find.text(t.common.helpSupport), findsOneWidget);
      expect(find.text(t.legal.helpIntro), findsOneWidget);
      expect(find.textContaining(t.legal.contactEmail), findsWidgets);
      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.text(t.legal.companyName), findsOneWidget);
    });
  });
}
