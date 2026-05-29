import 'package:equatable/equatable.dart';

/// Kayıtlı IBAN silme sonucu.
class SavedIbanDeleteResult extends Equatable {
  final int buildingsCleared;
  final bool orphanPresetRemoved;

  const SavedIbanDeleteResult({
    required this.buildingsCleared,
    required this.orphanPresetRemoved,
  });

  bool get hadEffect => buildingsCleared > 0 || orphanPresetRemoved;

  @override
  List<Object?> get props => [buildingsCleared, orphanPresetRemoved];
}

class SavedIbanBulkDeleteResult extends Equatable {
  final int presetsRemoved;
  final int buildingsCleared;

  const SavedIbanBulkDeleteResult({
    required this.presetsRemoved,
    required this.buildingsCleared,
  });

  @override
  List<Object?> get props => [presetsRemoved, buildingsCleared];
}
