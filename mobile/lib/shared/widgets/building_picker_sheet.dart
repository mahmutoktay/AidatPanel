import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/buildings/domain/entities/building_entity.dart';
import '../../features/sites/domain/entities/site_entity.dart';
import '../../l10n/strings.g.dart';
import 'minimal_form_widgets.dart';
import 'premium_bottom_sheet.dart';

/// Bina/site seçim alt sayfası sonucu. [cancelled] true ise kullanıcı vazgeçti.
class BuildingPickerResult {
  final bool cancelled;
  final bool isAllBuildings;
  final String? siteId;
  final String? buildingId;

  const BuildingPickerResult._({
    required this.cancelled,
    this.isAllBuildings = false,
    this.siteId,
    this.buildingId,
  });

  const BuildingPickerResult.cancelled() : this._(cancelled: true);

  const BuildingPickerResult.allBuildings()
      : this._(cancelled: false, isAllBuildings: true);

  const BuildingPickerResult.site(String id)
      : this._(cancelled: false, siteId: id);

  const BuildingPickerResult.building(String id)
      : this._(cancelled: false, buildingId: id);

  bool get isSiteScope => siteId != null && buildingId == null;
}

class _SiteGroup {
  final SiteEntity site;
  final List<BuildingEntity> buildings;

  const _SiteGroup({required this.site, required this.buildings});
}

String _buildingPickerSubtitle(
  BuildingEntity building,
  SiteEntity? site,
  String apartmentLabel,
) {
  var address = building.displayAddress.trim();
  if (address.isEmpty && site != null) {
    final parts = <String>[
      if (site.address.trim().isNotEmpty) site.address.trim(),
      if (building.addressExtra?.trim().isNotEmpty == true)
        building.addressExtra!.trim(),
    ];
    final city = (building.effectiveCity ?? site.city).trim();
    address = parts.join(' — ');
    if (city.isNotEmpty) {
      address = address.isEmpty ? city : '$address, $city';
    }
  }
  if (address.isEmpty) return apartmentLabel;
  return '$address · $apartmentLabel';
}

/// Aranabilir bina/site seçim alt sayfası — site hiyerarşisi destekli.
class BuildingPickerSheet extends StatefulWidget {
  final List<BuildingEntity> buildings;
  final List<SiteEntity> sites;
  final String? selectedBuildingId;
  final String? selectedSiteId;
  final bool selectedIsAll;
  final bool includeAllOption;
  final bool enableSiteGrouping;

  const BuildingPickerSheet({
    super.key,
    required this.buildings,
    this.sites = const [],
    required this.selectedBuildingId,
    this.selectedSiteId,
    this.selectedIsAll = false,
    this.includeAllOption = false,
    this.enableSiteGrouping = true,
  });

  static Future<BuildingPickerResult> show(
    BuildContext context, {
    required List<BuildingEntity> buildings,
    List<SiteEntity> sites = const [],
    required String? selectedBuildingId,
    String? selectedSiteId,
    bool selectedIsAll = false,
    bool includeAllOption = false,
    bool enableSiteGrouping = true,
  }) async {
    final result = await PremiumBottomSheetScaffold.show<BuildingPickerResult>(
      context: context,
      builder: (_) => BuildingPickerSheet(
        buildings: buildings,
        sites: sites,
        selectedBuildingId: selectedBuildingId,
        selectedSiteId: selectedSiteId,
        selectedIsAll: selectedIsAll,
        includeAllOption: includeAllOption,
        enableSiteGrouping: enableSiteGrouping,
      ),
    );
    return result ?? const BuildingPickerResult.cancelled();
  }

  @override
  State<BuildingPickerSheet> createState() => _BuildingPickerSheetState();
}

class _BuildingPickerSheetState extends State<BuildingPickerSheet> {
  String _query = '';
  final Set<String> _expandedSiteIds = {};

  bool get _useHierarchy =>
      widget.enableSiteGrouping && widget.sites.isNotEmpty;

  Map<String, List<BuildingEntity>> get _buildingsBySiteId {
    final map = <String, List<BuildingEntity>>{};
    for (final building in widget.buildings) {
      final siteId = building.siteId;
      if (siteId == null) continue;
      map.putIfAbsent(siteId, () => []).add(building);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.name.compareTo(b.name));
    }
    return map;
  }

  List<BuildingEntity> get _standaloneBuildings {
    return widget.buildings
        .where((b) => b.siteId == null)
        .toList(growable: false)
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<_SiteGroup> get _siteGroups {
    final bySite = _buildingsBySiteId;
    final groups = <_SiteGroup>[];
    for (final site in widget.sites) {
      final buildings = bySite[site.id] ?? const <BuildingEntity>[];
      groups.add(_SiteGroup(site: site, buildings: buildings));
    }
    groups.sort((a, b) => a.site.name.compareTo(b.site.name));
    return groups;
  }

  bool _matchesQuery(String value) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return value.toLowerCase().contains(q);
  }

  bool _buildingMatches(BuildingEntity building) {
    if (_query.trim().isEmpty) return true;
    return _matchesQuery(building.name) ||
        _matchesQuery(building.displayAddress) ||
        _matchesQuery(building.city) ||
        (building.siteName != null && _matchesQuery(building.siteName!));
  }

  bool _siteMatches(SiteEntity site) {
    if (_query.trim().isEmpty) return true;
    return _matchesQuery(site.name) ||
        _matchesQuery(site.displayAddress) ||
        _matchesQuery(site.city);
  }

  List<_SiteGroup> get _visibleSiteGroups {
    if (!_useHierarchy) return const [];

    final q = _query.trim();
    if (q.isEmpty) return _siteGroups;

    final visible = <_SiteGroup>[];
    for (final group in _siteGroups) {
      final siteHit = _siteMatches(group.site);
      if (group.buildings.isEmpty) {
        if (siteHit) {
          visible.add(_SiteGroup(site: group.site, buildings: const []));
        }
        continue;
      }
      final matchedBuildings = group.buildings
          .where((b) => siteHit || _buildingMatches(b))
          .toList(growable: false);
      if (matchedBuildings.isEmpty) continue;
      visible.add(_SiteGroup(site: group.site, buildings: matchedBuildings));
    }
    return visible;
  }

  List<BuildingEntity> get _visibleStandaloneBuildings {
    final standalone = _standaloneBuildings;
    if (!_useHierarchy) {
      return standalone.where(_buildingMatches).toList(growable: false);
    }
    return standalone.where(_buildingMatches).toList(growable: false);
  }

  List<BuildingEntity> get _flatFilteredBuildings {
    return widget.buildings.where(_buildingMatches).toList(growable: false)
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  bool _isSiteExpanded(String siteId) {
    if (_query.trim().isNotEmpty) return true;
    return _expandedSiteIds.contains(siteId);
  }

  void _toggleSiteExpanded(String siteId) {
    setState(() {
      if (_expandedSiteIds.contains(siteId)) {
        _expandedSiteIds.remove(siteId);
      } else {
        _expandedSiteIds.add(siteId);
      }
    });
  }

  bool _isSiteSelected(String siteId) {
    return !widget.selectedIsAll &&
        widget.selectedSiteId == siteId &&
        widget.selectedBuildingId == null;
  }

  bool _isBuildingSelected(String buildingId) {
    return !widget.selectedIsAll &&
        widget.selectedBuildingId == buildingId;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;
    final showAllOption =
        widget.includeAllOption && _query.trim().isEmpty;

    final hasHierarchyContent = _useHierarchy &&
        (_visibleSiteGroups.isNotEmpty ||
            _visibleStandaloneBuildings.isNotEmpty);
    final hasFlatContent = !_useHierarchy && _flatFilteredBuildings.isNotEmpty;
    final isEmpty = !showAllOption && !hasHierarchyContent && !hasFlatContent;

    return PremiumBottomSheetScaffold(
      title: t.selectBuilding,
      showCloseButton: true,
      onClose: () => Navigator.of(context).pop(
        const BuildingPickerResult.cancelled(),
      ),
      scrollable: true,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingL),
            child: MinimalSearchField(
              hint: t.searchBuildings,
              autofocus: widget.buildings.length > 8,
              whiteBackground: true,
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          if (isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacingL),
              child: Text(
                context.t.common.noResults,
                style: AppTypography.body1.copyWith(
                  color: AppColors.mutedText,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else ...[
            if (showAllOption)
              _BuildingPickerTile(
                title: t.allBuildings,
                subtitle: t.allBuildingsSummary.replaceAll(
                  '{count}',
                  '${widget.buildings.length}',
                ),
                selected: widget.selectedIsAll,
                leadingIcon: Icons.grid_view_rounded,
                onTap: () => Navigator.of(context).pop(
                  const BuildingPickerResult.allBuildings(),
                ),
              ),
            if (_useHierarchy) ...[
              if (_visibleSiteGroups.isNotEmpty) ...[
                _SectionHeader(label: t.sitesSection),
                ..._visibleSiteGroups.map(_buildSiteGroup),
              ],
              if (_visibleStandaloneBuildings.isNotEmpty) ...[
                _SectionHeader(label: t.independentBuildingsSection),
                ..._visibleStandaloneBuildings.map(_buildStandaloneBuilding),
              ],
            ] else
              ..._flatFilteredBuildings.map(_buildStandaloneBuilding),
          ],
          const SizedBox(height: AppSizes.spacingL),
        ],
      ),
    );
  }

  Widget _buildSiteGroup(_SiteGroup group) {
    final hasBuildings = group.buildings.isNotEmpty;
    final expanded = hasBuildings && _isSiteExpanded(group.site.id);
    final siteSelected = _isSiteSelected(group.site.id);
    final buildingCountLabel = context.t.features.sites.buildingCount
        .replaceAll('{count}', '${group.buildings.length}');
    final selectLabel = context.t.common.select;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingS),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.spacingS),
        decoration: BoxDecoration(
          color: AppColors.dashboardBackground,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(color: AppColors.lineLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSizes.cardRadius),
                bottom: expanded
                    ? Radius.zero
                    : Radius.circular(AppSizes.cardRadius),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: hasBuildings
                          ? () => _toggleSiteExpanded(group.site.id)
                          : () => Navigator.of(context).pop(
                                BuildingPickerResult.site(group.site.id),
                              ),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(AppSizes.cardRadius),
                      ),
                      child: _PickerRowContent(
                        icon: Icons.domain_rounded,
                        title: group.site.name,
                        subtitle: buildingCountLabel,
                        selected: siteSelected,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(
                      BuildingPickerResult.site(group.site.id),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.statusBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: const Size(48, 48),
                    ),
                    child: Text(
                      selectLabel,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (hasBuildings)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.mutedText,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 8),
                ],
              ),
            ),
            if (hasBuildings)
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: expanded
                    ? Column(
                        children: [
                          Divider(height: 1, color: AppColors.lineLight),
                          ...group.buildings.map(
                            (building) => _IndentedBuildingTile(
                              building: building,
                              site: group.site,
                              selected: _isBuildingSelected(building.id),
                              onTap: () => Navigator.of(context).pop(
                                BuildingPickerResult.building(building.id),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandaloneBuilding(BuildingEntity building) {
    final t = context.t.features.dashboard;
    final apartmentLabel = t.buildingUnitsSummary.replaceAll(
      '{apartments}',
      '${building.totalApartments}',
    );

    return _BuildingPickerTile(
      title: building.displayName,
      subtitle: _buildingPickerSubtitle(building, null, apartmentLabel),
      selected: _isBuildingSelected(building.id),
      leadingIcon: Icons.apartment_rounded,
      onTap: () => Navigator.of(context).pop(
        BuildingPickerResult.building(building.id),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacingL,
        AppSizes.spacingS,
        AppSizes.spacingL,
        AppSizes.spacingXS,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.mutedText,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _IndentedBuildingTile extends StatelessWidget {
  final BuildingEntity building;
  final SiteEntity? site;
  final bool selected;
  final VoidCallback onTap;

  const _IndentedBuildingTile({
    required this.building,
    this.site,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;
    final apartmentLabel = t.buildingUnitsSummary.replaceAll(
      '{apartments}',
      '${building.totalApartments}',
    );
    final subtitle = _buildingPickerSubtitle(building, site, apartmentLabel);

    return Padding(
      padding: const EdgeInsets.only(left: AppSizes.spacingM),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          child: _PickerRowContent(
            icon: Icons.apartment_rounded,
            title: building.displayName,
            subtitle: subtitle,
            selected: selected,
          ),
        ),
      ),
    );
  }
}

class _PickerRowContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;

  const _PickerRowContent({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.statusBlue.withValues(alpha: 0.15)
                  : AppColors.statusBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.statusBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.inkDark,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (selected)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.statusGreen,
                size: 22,
              ),
            ),
        ],
      ),
    );
  }
}

class _BuildingPickerTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final IconData leadingIcon;
  final VoidCallback onTap;

  const _BuildingPickerTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.leadingIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumActionSheetTile(
      icon: leadingIcon,
      label: title,
      subtitle: subtitle,
      iconColor: AppColors.statusBlue,
      iconBackground: selected
          ? AppColors.statusBlue.withValues(alpha: 0.15)
          : null,
      trailing: selected
          ? const Icon(
              Icons.check_circle_rounded,
              color: AppColors.statusGreen,
              size: 22,
            )
          : null,
      onTap: onTap,
    );
  }
}
