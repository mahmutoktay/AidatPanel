import 'package:equatable/equatable.dart';

import '../../../../core/utils/iban_utils.dart';
import '../../../sites/domain/entities/site_entity.dart';
import 'building_entity.dart';
import 'collection_preset_entity.dart';

/// Ayarlar → Kayıtlı IBAN: preset + bu seti kullanan bina ve siteler.
class SavedIbanItem extends Equatable {
  final CollectionPresetEntity preset;
  final List<BuildingEntity> buildings;
  final List<SiteEntity> sites;

  const SavedIbanItem({
    required this.preset,
    required this.buildings,
    this.sites = const [],
  });

  String get ibanKey => IbanUtils.normalize(preset.collectionIban);

  int get usageCount => buildings.length + sites.length;

  bool get hasUsages => usageCount > 0;

  /// Bina ve site adlarını tek listede (silme/güncelleme uyarıları için).
  List<String> get usagePlaceNames => [
        ...buildings.map((b) => b.name),
        ...sites.map((s) => s.name),
      ];

  @override
  List<Object?> get props => [preset, buildings, sites];
}
