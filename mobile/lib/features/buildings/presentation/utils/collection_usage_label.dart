import 'package:flutter/widgets.dart';

import '../../domain/entities/collection_preset_entity.dart';
import '../../domain/entities/saved_iban_item.dart';
import '../../../../l10n/strings.g.dart';

/// Kayıtlı IBAN kullanım sayısı / yer isimleri etiketleri.
class CollectionUsageLabel {
  CollectionUsageLabel._();

  /// Örn. "2 bina, 1 sitede kullanılıyor" / "3 binada kullanılıyor".
  static String? usageSummary(
    BuildContext context, {
    required int buildingCount,
    required int siteCount,
  }) {
    final t = context.t.features.buildings.collection;
    if (buildingCount <= 0 && siteCount <= 0) return null;
    if (buildingCount > 0 && siteCount > 0) {
      return t.detailUsedInBuildingsAndSites
          .replaceAll('{buildingCount}', '$buildingCount')
          .replaceAll('{siteCount}', '$siteCount');
    }
    if (siteCount > 0) {
      return t.detailUsedInSites.replaceAll('{count}', '$siteCount');
    }
    if (buildingCount > 1) {
      return t.detailUsedInBuildings.replaceAll('{count}', '$buildingCount');
    }
    // Tek bina: özet satırı gösterme (isim listesi yeterli); picker chip için
    // caller count eşiğini kendisi kontrol eder.
    if (buildingCount == 1 && siteCount == 0) return null;
    return t.detailUsedInBuildings.replaceAll('{count}', '$buildingCount');
  }

  /// Preset kart/chip için: toplam kullanım > 1 ise özet.
  static String? usageSummaryForPreset(
    BuildContext context,
    CollectionPresetEntity preset,
  ) {
    final total = preset.buildingCount + preset.siteCount;
    if (total <= 1) return null;
    return usageSummary(
      context,
      buildingCount: preset.buildingCount,
      siteCount: preset.siteCount,
    );
  }

  static String? usageSummaryForItem(
    BuildContext context,
    SavedIbanItem item,
  ) {
    final total = item.usageCount;
    if (total <= 1) {
      // Tek kullanımda isim satırları yeter; sayı özeti gösterme.
      return null;
    }
    return usageSummary(
      context,
      buildingCount: item.buildings.length,
      siteCount: item.sites.length,
    );
  }

  /// "Binalar: …" / "Siteler: …" satırları (boş olanlar atlanır).
  static List<String> placeNameLines(
    BuildContext context,
    SavedIbanItem item,
  ) {
    final t = context.t.features.buildings.collection;
    final lines = <String>[];
    if (item.buildings.isNotEmpty) {
      lines.add(
        t.savedIbansBuildingNames.replaceAll(
          '{names}',
          item.buildings.map((b) => b.name).join(', '),
        ),
      );
    }
    if (item.sites.isNotEmpty) {
      lines.add(
        t.savedIbansSiteNames.replaceAll(
          '{names}',
          item.sites.map((s) => s.name).join(', '),
        ),
      );
    }
    return lines;
  }

  /// Tek satır: bina + site adları (virgülle); boşsa null.
  static String? flatPlaceNames(SavedIbanItem item) {
    final names = item.usagePlaceNames;
    if (names.isEmpty) return null;
    return names.join(', ');
  }

  /// Birden fazla item için tüm yer adları (silme diyaloğu).
  static String flatPlaceNamesForItems(List<SavedIbanItem> items) {
    final names = <String>[];
    for (final item in items) {
      names.addAll(item.usagePlaceNames);
    }
    return names.join(', ');
  }

  static int totalUsageCount(List<SavedIbanItem> items) =>
      items.fold<int>(0, (sum, i) => sum + i.usageCount);
}
