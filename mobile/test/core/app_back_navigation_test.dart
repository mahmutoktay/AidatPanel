import 'package:aidatpanel/core/navigation/app_back_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AppBackNavigation.handleSecondaryScreenBack', () {
    testWidgets('pops when navigation stack has history', (tester) async {
      final router = GoRouter(
        initialLocation: '/list',
        routes: [
          GoRoute(
            path: '/list',
            builder: (context, _) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.push('/detail'),
                child: const Text('open'),
              ),
            ),
          ),
          GoRoute(
            path: '/detail',
            builder: (context, _) => Scaffold(
              body: ElevatedButton(
                key: const ValueKey('back'),
                onPressed: () => AppBackNavigation.handleSecondaryScreenBack(
                  context,
                  fallbackPath: '/list',
                ),
                child: const Text('back'),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('back')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('back')));
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('goes to fallback when stack cannot pop', (tester) async {
      final router = GoRouter(
        initialLocation: '/detail',
        routes: [
          GoRoute(
            path: '/list',
            builder: (_, _) => const Scaffold(body: Text('list')),
          ),
          GoRoute(
            path: '/detail',
            builder: (context, _) => Scaffold(
              body: ElevatedButton(
                key: const ValueKey('back'),
                onPressed: () => AppBackNavigation.handleSecondaryScreenBack(
                  context,
                  fallbackPath: '/list',
                ),
                child: const Text('back'),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('back')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('back')));
      await tester.pumpAndSettle();
      expect(find.text('list'), findsOneWidget);
    });

    testWidgets('returns false when cannot pop and no fallback', (tester) async {
      var handled = false;

      final router = GoRouter(
        initialLocation: '/only',
        routes: [
          GoRoute(
            path: '/only',
            builder: (context, _) => Scaffold(
              body: ElevatedButton(
                key: const ValueKey('back'),
                onPressed: () {
                  handled = AppBackNavigation.handleSecondaryScreenBack(context);
                },
                child: const Text('back'),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('back')));
      await tester.pumpAndSettle();
      expect(handled, isFalse);
      expect(find.byKey(const ValueKey('back')), findsOneWidget);
    });
  });
}
