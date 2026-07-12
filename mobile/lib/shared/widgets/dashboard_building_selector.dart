import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/action_chevron.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/buildings/domain/entities/building_entity.dart';
import '../../features/dashboard/domain/entities/dashboard_filter_scope.dart';
import '../../features/sites/data/sites_store.dart';
import '../../features/sites/domain/entities/site_entity.dart';
import '../../l10n/strings.g.dart';
import '../../shared/theme/dashboard_screen_style.dart';
import 'building_picker_sheet.dart';

/// Bina/site seçici — dokunulunca aranabilir hiyerarşik liste açılır.
class DashboardBuildingSelector extends ConsumerWidget {
  final List<BuildingEntity> buildings;
  final DashboardFilterScope scope;
  final ValueChanged<DashboardFilterScope> onScopeChanged;
  final bool includeAllOption;

  const DashboardBuildingSelector({
    super.key,
    required this.buildings,
    required this.scope,
    required this.onScopeChanged,
    this.includeAllOption = false,
  });

  /// Geriye dönük uyumluluk — yalnızca bina ID'si ile çalışır.
  factory DashboardBuildingSelector.legacy({
    required List<BuildingEntity> buildings,
    required String? selectedBuildingId,
    required ValueChanged<String?> onSelected,
    bool includeAllOption = false,
  }) {
    return DashboardBuildingSelector(
      buildings: buildings,
      scope: selectedBuildingId == null
          ? const DashboardFilterScope.all()
          : DashboardFilterScope.building(selectedBuildingId),
      includeAllOption: includeAllOption,
      onScopeChanged: (next) {
        onSelected(next.buildingId);
      },
    );
  }

  BuildingEntity? _selectedBuilding() {
    final id = scope.buildingId;
    if (id == null) return null;
    for (final b in buildings) {
      if (b.id == id) return b;
    }
    return null;
  }

  SiteEntity? _selectedSite(List<SiteEntity> sites) {
    final id = scope.siteId;
    if (id == null) return null;
    for (final site in sites) {
      if (site.id == id) return site;
    }
    return null;
  }

  int _siteBuildingCount(String siteId) {
    return buildings.where((b) => b.siteId == siteId).length;
  }

  Future<void> _openPicker(BuildContext context, WidgetRef ref) async {
    final sites = ref.read(sitesStoreProvider).value ?? const <SiteEntity>[];
    final result = await BuildingPickerSheet.show(
      context,
      buildings: buildings,
      sites: sites,
      selectedBuildingId: scope.buildingId,
      selectedSiteId: scope.siteId,
      selectedIsAll: scope.isAll,
      includeAllOption: includeAllOption,
      enableSiteGrouping: sites.isNotEmpty,
    );
    if (result.cancelled) return;

    if (result.isAllBuildings) {
      if (!scope.isAll) onScopeChanged(const DashboardFilterScope.all());
      return;
    }
    if (result.isSiteScope && result.siteId != null) {
      if (scope.siteId != result.siteId || scope.buildingId != null) {
        onScopeChanged(DashboardFilterScope.site(result.siteId!));
      }
      return;
    }
    final buildingId = result.buildingId;
    if (buildingId != null &&
        (scope.buildingId != buildingId || scope.siteId != null)) {
      onScopeChanged(DashboardFilterScope.building(buildingId));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t.features.dashboard;
    final sites = ref.watch(sitesStoreProvider).value ?? const <SiteEntity>[];
    final selectedBuilding = _selectedBuilding();
    final selectedSite = _selectedSite(sites);

    late final String title;
    late final String subtitle;

    if (scope.isAll) {
      title = t.allBuildings;
      subtitle = t.allBuildingsSummary.replaceAll('{count}', '${buildings.length}');
    } else if (scope.isSite && selectedSite != null) {
      title = selectedSite.name;
      subtitle = t.siteScopeSummary.replaceAll(
        '{count}',
        '${_siteBuildingCount(selectedSite.id)}',
      );
    } else if (selectedBuilding != null) {
      title = selectedBuilding.name;
      subtitle = _buildingSubtitle(context, selectedBuilding);
    } else {
      title = t.selectBuilding;
      subtitle = t.buildingPickerTapHint;
    }

    return _DashboardBuildingSelectorTrigger(
      title: title,
      subtitle: subtitle,
      onTap: () => _openPicker(context, ref),
    );
  }

  String _buildingSubtitle(BuildContext context, BuildingEntity building) {
    final t = context.t.features.dashboard;
    final units = t.buildingUnitsSummary.replaceAll(
      '{apartments}',
      '${building.totalApartments}',
    );
    if (building.displayAddress.isEmpty) return units;
    return '${building.displayAddress} · $units';
  }
}

class _DashboardBuildingSelectorTrigger extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardBuildingSelectorTrigger({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
          child: Ink(
            decoration: DashboardScreenStyle.whiteCard(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacingM,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.dashboardBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.apartment_rounded,
                      color: AppColors.statusBlue,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.body1.copyWith(
                            color: AppColors.inkDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: AppTypography.body2.copyWith(
                            color: AppColors.mutedText,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const ActionChevron(
                    direction: ChevronDirection.down,
                    size: 26,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
