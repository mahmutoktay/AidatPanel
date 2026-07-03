import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_sizes.dart';
<<<<<<< HEAD
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../widgets/manager_buildings_tab.dart';
import '../../../sites/presentation/widgets/manager_sites_tab.dart';

enum PropertiesSegment { sites, buildings }

class ManagerPropertiesTab extends ConsumerStatefulWidget {
  const ManagerPropertiesTab({super.key});
=======
import '../../../buildings/domain/entities/building_entity.dart';
import '../../../sites/data/sites_store.dart';
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

  @override
  ConsumerState<ManagerPropertiesTab> createState() =>
      _ManagerPropertiesTabState();
}

class _ManagerPropertiesTabState extends ConsumerState<ManagerPropertiesTab> {
<<<<<<< HEAD
  PropertiesSegment _segment = PropertiesSegment.sites;

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: AppSizes.screenBodyScrollPadding.copyWith(bottom: 0),
          child: SegmentedButton<PropertiesSegment>(
            segments: [
              ButtonSegment(
                value: PropertiesSegment.sites,
                label: Text(t.tabSites),
                icon: const Icon(Icons.domain_outlined),
              ),
              ButtonSegment(
                value: PropertiesSegment.buildings,
                label: Text(t.tabBuildings),
                icon: const Icon(Icons.apartment_outlined),
              ),
            ],
            selected: {_segment},
            onSelectionChanged: (value) {
              setState(() => _segment = value.first);
            },
            style: ButtonStyle(
              textStyle: WidgetStatePropertyAll(
                AppTypography.button.copyWith(fontWeight: FontWeight.w700),
              ),
              minimumSize: const WidgetStatePropertyAll(
                Size(0, AppSizes.minTouchTarget),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: _segment == PropertiesSegment.sites
                ? const ManagerSitesTab(key: ValueKey('sites_tab'))
                : const ManagerBuildingsTab(
                    key: ValueKey('buildings_tab'),
                  ),
          ),
=======
  PropertyType _selectedType = PropertyType.sites;

  @override
  Widget build(BuildContext context) {
    final sitesAsync = ref.watch(sitesStoreProvider);
    final sites = sitesAsync.value ?? [];
    final siteCount = sites.length;
    final buildingCount =
        widget.standaloneBuildingsAsync.value?.length ?? 0;

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
                  siteCount: siteCount,
                  buildingCount: buildingCount,
                ),
              ),
              const SizedBox(height: 4.0),
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        ),
      ],
    );
  }
}
