import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_sizes.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../widgets/manager_buildings_tab.dart';
import 'property_type_selector.dart';
import '../../../sites/presentation/widgets/buildings_expandable_fab.dart';
import '../../../sites/presentation/widgets/manager_sites_tab.dart';
import 'property_type_picker_sheet.dart';

/// Siteler | Binalar geçişi için premium seçici.
class ManagerPropertiesTab extends ConsumerStatefulWidget {
  final AsyncValue<List<BuildingEntity>> standaloneBuildingsAsync;

  const ManagerPropertiesTab({
    super.key,
    required this.standaloneBuildingsAsync,
  });

  @override
  ConsumerState<ManagerPropertiesTab> createState() =>
      _ManagerPropertiesTabState();
}

class _ManagerPropertiesTabState extends ConsumerState<ManagerPropertiesTab> {
  PropertyType _selectedType = PropertyType.sites;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: PropertyTypeSelector(
                  selectedType: _selectedType,
                  onChanged: (type) => setState(() => _selectedType = type),
                ),
              ),
              const SizedBox(height: 8.0),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: _selectedType == PropertyType.sites
                    ? ManagerSitesTab(
                        key: const ValueKey(PropertyType.sites),
                      )
                    : ManagerBuildingsTab(
                        key: const ValueKey(PropertyType.buildings),
                        buildingsAsync: widget.standaloneBuildingsAsync,
                      ),
              ),
            ),
          ],
        ),
        Positioned(
          right: AppSizes.spacingL,
          bottom: AppSizes.spacingL,
          child: const BuildingsExpandableFab(),
        ),
      ],
    );
  }
}
