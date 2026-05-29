import 'package:equatable/equatable.dart';

import '../../../../core/utils/iban_utils.dart';
import 'building_entity.dart';
import 'collection_preset_entity.dart';

/// Ayarlar → Kayıtlı IBAN: preset + bu seti kullanan binalar.
class SavedIbanItem extends Equatable {
  final CollectionPresetEntity preset;
  final List<BuildingEntity> buildings;

  const SavedIbanItem({
    required this.preset,
    required this.buildings,
  });

  String get ibanKey => IbanUtils.normalize(preset.collectionIban);

  @override
  List<Object?> get props => [preset, buildings];
}
