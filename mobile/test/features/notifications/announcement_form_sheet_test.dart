import 'package:aidatpanel/core/network/api_exception.dart';
import 'package:aidatpanel/features/buildings/data/repositories/building_repository.dart';
import 'package:aidatpanel/features/buildings/data/buildings_store.dart';
import 'package:aidatpanel/features/buildings/domain/entities/building_entity.dart';
import 'package:aidatpanel/features/notifications/presentation/widgets/announcement_form_sheet.dart';
import 'package:aidatpanel/l10n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slang_flutter/slang_flutter.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.tr);
  });

  Widget wrap(Widget child, {required BuildingRepository repository}) {
    return ProviderScope(
      overrides: [
        buildingRepositoryProvider.overrideWithValue(repository),
      ],
      child: TranslationProvider(
        child: MaterialApp(home: Scaffold(body: child)),
      ),
    );
  }

  group('AnnouncementFormSheet', () {
    testWidgets('empty building list shows add building CTA', (tester) async {
      await tester.pumpWidget(
        wrap(
          const AnnouncementFormSheet(),
          repository: _EmptyBuildingsRepository(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Önce bir bina ekleyin'), findsOneWidget);
      expect(find.text('Bina Ekle'), findsOneWidget);
      expect(find.text('Gönder'), findsNothing);
    });

    testWidgets('load error shows retry not add building', (tester) async {
      await tester.pumpWidget(
        wrap(
          const AnnouncementFormSheet(),
          repository: _FailingBuildingsRepository(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(t.features.auth.splashConnectionError), findsWidgets);
      expect(find.text('Tekrar Dene'), findsOneWidget);
      expect(find.text('Bina Ekle'), findsNothing);
    });
  });
}

class _EmptyBuildingsRepository implements BuildingRepository {
  @override
  Future<List<BuildingEntity>> fetchBuildings() async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FailingBuildingsRepository implements BuildingRepository {
  @override
  Future<List<BuildingEntity>> fetchBuildings() async {
    throw ApiException(message: 'Sunucuya bağlanılamadı');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
