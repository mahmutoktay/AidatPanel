import 'package:flutter/material.dart';

import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/sliding_segmented_control.dart';

enum PropertyType { sites, buildings }

/// Binalar | Siteler görünüm geçişi — dolgulu pill segment kontrol.
class PropertyTypeSegmentedTab extends StatelessWidget {
  const PropertyTypeSegmentedTab({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  final PropertyType selectedType;
  final ValueChanged<PropertyType> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;
    final selectedIndex = selectedType == PropertyType.buildings ? 0 : 1;

    return SlidingSegmentedControl(
      segments: [t.tabBuildings, t.tabSites],
      selectedIndex: selectedIndex,
      onChanged: (index) {
        onChanged(index == 0 ? PropertyType.buildings : PropertyType.sites);
      },
      height: 44,
      fontSize: 15,
    );
  }
}
