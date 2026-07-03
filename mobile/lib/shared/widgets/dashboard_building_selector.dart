import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/action_chevron.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/buildings/domain/entities/building_entity.dart';
import '../../l10n/strings.g.dart';
import '../../shared/theme/dashboard_screen_style.dart';
import 'building_picker_sheet.dart';

/// Bina seçici — dokunulunca aranabilir liste açılır (çok bina için ölçeklenebilir).
/// [includeAllOption] true ise "Tüm Binalar" seçeneği sunulur.
class DashboardBuildingSelector extends StatelessWidget {
  final List<BuildingEntity> buildings;
  final String? selectedBuildingId;
  final ValueChanged<String?> onSelected;
  final bool includeAllOption;

  const DashboardBuildingSelector({
    super.key,
    required this.buildings,
    required this.selectedBuildingId,
    required this.onSelected,
    this.includeAllOption = false,
  });

  BuildingEntity? get _selectedBuilding {
    if (selectedBuildingId == null) return null;
    for (final b in buildings) {
      if (b.id == selectedBuildingId) return b;
    }
    return null;
  }

  Future<void> _openPicker(BuildContext context) async {
    final result = await BuildingPickerSheet.show(
      context,
      buildings: buildings,
      selectedBuildingId: selectedBuildingId,
      includeAllOption: includeAllOption,
    );
    if (result.cancelled) return;
    if (result.isAllBuildings) {
      if (selectedBuildingId != null) onSelected(null);
      return;
    }
    final id = result.buildingId;
    if (id != null && id != selectedBuildingId) onSelected(id);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;
    final selected = _selectedBuilding;
    final isAll = includeAllOption && selectedBuildingId == null;

    final title = isAll ? t.allBuildings : (selected?.name ?? t.selectBuilding);
    final subtitle = isAll
        ? t.allBuildingsSummary.replaceAll('{count}', '${buildings.length}')
        : selected != null
            ? _buildingSubtitle(context, selected)
            : t.buildingPickerTapHint;

    return _DashboardBuildingSelectorTrigger(
      title: title,
      subtitle: subtitle,
      onTap: () => _openPicker(context),
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

/// Tek bina seçimi — aynı aranabilir liste (tüm binalar seçeneği yok).
class DashboardSingleBuildingSelector extends StatelessWidget {
  final List<BuildingEntity> buildings;
  final String? selectedBuildingId;
  final ValueChanged<String> onSelected;

  const DashboardSingleBuildingSelector({
    super.key,
    required this.buildings,
    required this.selectedBuildingId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardBuildingSelector(
      buildings: buildings,
      selectedBuildingId: selectedBuildingId,
      includeAllOption: false,
      onSelected: (id) {
        if (id != null) onSelected(id);
      },
    );
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
