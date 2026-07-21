import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/strings.g.dart';
import '../../../dues/presentation/widgets/dues_segment_toggle.dart';

enum PropertyType { sites, buildings }

/// Mülkler sekmesindeki Siteler | Binalar seçimi (oluşturma sonrası doğru panele dönmek için).
class PropertyTypeNotifier extends Notifier<PropertyType> {
  @override
  PropertyType build() => PropertyType.buildings;

  void update(PropertyType type) => state = type;
}

final propertyTypeProvider =
    NotifierProvider<PropertyTypeNotifier, PropertyType>(
  PropertyTypeNotifier.new,
);

/// Binalar | Siteler — sakin aidatlar sekmesindeki [DuesSegmentToggle] tasarımı.
class PropertyTypeSegmentedTab extends ConsumerWidget {
  const PropertyTypeSegmentedTab({
    super.key,
    this.onChanged,
  });

  final ValueChanged<PropertyType>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t.features.sites;
    final selectedType = ref.watch(propertyTypeProvider);
    final selectedIndex = selectedType == PropertyType.buildings ? 0 : 1;

    return DuesSegmentToggle(
      segments: [t.tabBuildings, t.tabSites],
      selectedIndex: selectedIndex,
      onChanged: (index) {
        final type =
            index == 0 ? PropertyType.buildings : PropertyType.sites;
        ref.read(propertyTypeProvider.notifier).update(type);
        onChanged?.call(type);
      },
    );
  }
}
