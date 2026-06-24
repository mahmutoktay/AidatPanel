import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/iban_utils.dart';
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
  return SavedIbanMatcher.merge(presets, buildings);
});

class SavedIbanMatcher {
  SavedIbanMatcher._();

  static List<SavedIbanItem> merge(
    List<CollectionPresetEntity> presets,
    List<BuildingEntity> buildings,
  ) {
    return presets.map((preset) {
      final key = IbanUtils.normalize(preset.collectionIban);
      final matched = buildings
          .where(
            (b) =>
                IbanUtils.normalize(
                  b.effectiveCollectionIban ?? b.collectionIban ?? '',
                ) ==
                key,
          )
          .toList();
      return SavedIbanItem(preset: preset, buildings: matched);
    }).toList();
  }
}
