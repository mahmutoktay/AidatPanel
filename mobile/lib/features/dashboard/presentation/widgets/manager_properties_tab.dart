import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_sizes.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../widgets/manager_buildings_tab.dart';
import '../../../sites/presentation/widgets/buildings_expandable_fab.dart';
import '../../../sites/presentation/widgets/manager_sites_tab.dart';
import 'property_type_segmented_tab.dart';

/// Siteler | Binalar geçişi için premium seçici.
class ManagerPropertiesTab extends ConsumerStatefulWidget {
  /// Tüm binalar; Binalar sekmesi `siteId == null` ile tekil olanları süzülür.
  /// `buildingsStoreProvider` ile aynı kaynak — mutasyon sonrası otomatik güncellenir.
  final AsyncValue<List<BuildingEntity>> buildingsAsync;

  const ManagerPropertiesTab({
    super.key,
    required this.buildingsAsync,
  });

  @override
  ConsumerState<ManagerPropertiesTab> createState() =>
      _ManagerPropertiesTabState();
}

class _ManagerPropertiesTabState extends ConsumerState<ManagerPropertiesTab> {
  final GlobalKey<BuildingsExpandableFabState> _fabKey =
      GlobalKey<BuildingsExpandableFabState>();
  bool _fabOpen = false;

  void _closeFab() {
    _fabKey.currentState?.close();
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(propertyTypeProvider);

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.dashboardScreenPaddingHorizontal,
                AppSizes.spacingS,
                AppSizes.dashboardScreenPaddingHorizontal,
                AppSizes.spacingS,
              ),
              child: PropertyTypeSegmentedTab(
                onChanged: (_) => _closeFab(),
              ),
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (_fabOpen &&
                      (notification is ScrollStartNotification ||
                          notification is ScrollUpdateNotification)) {
                    _closeFab();
                  }
                  return false;
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  child: selectedType == PropertyType.sites
                      ? const ManagerSitesTab(
                          key: ValueKey(PropertyType.sites),
                        )
                      : ManagerBuildingsTab(
                          key: const ValueKey(PropertyType.buildings),
                          buildingsAsync: widget.buildingsAsync,
                        ),
                ),
              ),
            ),
          ],
        ),
        if (_fabOpen)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeFab,
              onVerticalDragStart: (_) => _closeFab(),
              onHorizontalDragStart: (_) => _closeFab(),
            ),
          ),
        Positioned(
          right: AppSizes.spacingL,
          bottom: AppSizes.spacingL,
          child: BuildingsExpandableFab(
            key: _fabKey,
            onOpenChanged: (open) {
              if (_fabOpen != open) {
                setState(() => _fabOpen = open);
              }
            },
          ),
        ),
      ],
    );
  }
}
