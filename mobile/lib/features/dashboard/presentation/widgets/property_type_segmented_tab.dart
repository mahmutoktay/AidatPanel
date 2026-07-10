import 'package:flutter/material.dart';

import '../../../../l10n/strings.g.dart';
import '../../../dues/presentation/widgets/dues_segment_toggle.dart';

enum PropertyType { sites, buildings }

/// Binalar | Siteler — sakin aidatlar sekmesindeki [DuesSegmentToggle] tasarımı.
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

    return DuesSegmentToggle(
      segments: [t.tabBuildings, t.tabSites],
      selectedIndex: selectedIndex,
      onChanged: (index) {
        onChanged(index == 0 ? PropertyType.buildings : PropertyType.sites);
      },
    );
  }
}
