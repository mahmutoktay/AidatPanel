import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/iban_utils.dart';
import '../../../sites/data/sites_store.dart';
import '../../../sites/domain/entities/site_entity.dart';
import '../../data/buildings_store.dart';
import '../../domain/entities/building_entity.dart';
import '../../domain/entities/collection_preset_entity.dart';
import '../../domain/entities/saved_iban_item.dart';

/// `collection-presets` + `GET /buildings` eşlemesi.
final savedIbansListProvider =
    FutureProvider.autoDispose<List<SavedIbanItem>>((ref) async {
  final repository = ref.watch(buildingRepositoryProvider);
  final presets = await repository.fetchCollectionPresets();
  final buildings = await repository.fetchBuildings();
  final sites = await ref.watch(siteRepositoryProvider).fetchSites();
  return SavedIbanMatcher.merge(presets, buildings, sites);
});

class SavedIbanMatcher {
  SavedIbanMatcher._();

  static List<SavedIbanItem> merge(
    List<CollectionPresetEntity> presets,
    List<BuildingEntity> buildings,
    List<SiteEntity> sites,
  ) {
    return presets.map((preset) {
      final key = IbanUtils.normalize(preset.collectionIban);
      final matchedBuildings = buildings
          .where((b) => IbanUtils.normalize(b.collectionIban ?? '') == key)
          .toList();
      final matchedSites = sites
          .where((s) => IbanUtils.normalize(s.collectionIban ?? '') == key)
          .toList();
      return SavedIbanItem(
        preset: preset,
        buildings: matchedBuildings,
        sites: matchedSites,
      );
    }).toList();
  }
}
