import 'package:aidatpanel/core/theme/app_colors.dart';
import 'package:aidatpanel/l10n/strings.g.dart';
import 'package:aidatpanel/shared/widgets/premium_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.tr);
  });

  Widget wrap(Widget child) {
    return TranslationProvider(
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  group('PremiumBottomSheetScaffold', () {
    testWidgets('defaults to sheetBackground color', (tester) async {
      await tester.pumpWidget(
        wrap(
          const PremiumBottomSheetScaffold(
            body: Text('Zemin'),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(
        find.byType(Container),
      );
      final sheetShell = containers.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color == AppColors.sheetBackground,
      );
      final decoration = sheetShell.decoration! as BoxDecoration;
      expect(decoration.color, AppColors.sheetBackground);
    });

    testWidgets('closeEnabled false disables close button', (tester) async {
      var popped = false;

      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  PremiumBottomSheetScaffold.show<void>(
                    context: context,
                    builder: (sheetContext) => PremiumBottomSheetScaffold(
                      title: 'Test',
                      showCloseButton: true,
                      closeEnabled: false,
                      onClose: () => Navigator.pop(sheetContext),
                      body: const Text('İçerik'),
                    ),
                  ).then((_) => popped = true);
                },
                child: const Text('Aç'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Aç'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      final closeButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.close_rounded),
          matching: find.byType(IconButton),
        ),
      );
      expect(closeButton.onPressed, isNull);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(popped, isFalse);
      expect(find.text('İçerik'), findsOneWidget);
    });

    testWidgets('scrollable picker fits small screen without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  PremiumBottomSheetScaffold.show<void>(
                    context: context,
                    builder: (_) => PremiumBottomSheetScaffold(
                      title: 'Gün seçin',
                      scrollable: true,
                      body: PremiumActionSheetList(
                        children: [
                          for (var day = 1; day <= 28; day++)
                            PremiumActionSheetTile(
                              icon: Icons.calendar_today_outlined,
                              label: '$day',
                              onTap: () {},
                            ),
                        ],
                      ),
                    ),
                  );
                },
                child: const Text('Picker'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Picker'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('28'), findsOneWidget);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
