import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/buildings/domain/entities/building_entity.dart';
import '../../l10n/strings.g.dart';
import 'minimal_form_widgets.dart';
import 'premium_bottom_sheet.dart';

/// Bina seçim alt sayfası sonucu. [cancelled] true ise kullanıcı vazgeçti.
class BuildingPickerResult {
  final bool cancelled;
  final bool isAllBuildings;
  final String? buildingId;

  const BuildingPickerResult._({
    required this.cancelled,
    this.isAllBuildings = false,
    this.buildingId,
  });

  const BuildingPickerResult.cancelled() : this._(cancelled: true);

  const BuildingPickerResult.allBuildings()
      : this._(cancelled: false, isAllBuildings: true);

  const BuildingPickerResult.building(String id)
      : this._(cancelled: false, buildingId: id);
}

/// Aranabilir bina seçim alt sayfası — çok sayıda bina için ölçeklenebilir.
class BuildingPickerSheet extends StatefulWidget {
  final List<BuildingEntity> buildings;
  final String? selectedBuildingId;
  final bool includeAllOption;

  const BuildingPickerSheet({
    super.key,
    required this.buildings,
    required this.selectedBuildingId,
    this.includeAllOption = false,
  });

  static Future<BuildingPickerResult> show(
    BuildContext context, {
    required List<BuildingEntity> buildings,
    required String? selectedBuildingId,
    bool includeAllOption = false,
  }) async {
    final result = await PremiumBottomSheetScaffold.show<BuildingPickerResult>(
      context: context,
      builder: (_) => BuildingPickerSheet(
        buildings: buildings,
        selectedBuildingId: selectedBuildingId,
        includeAllOption: includeAllOption,
      ),
    );
    return result ?? const BuildingPickerResult.cancelled();
  }

  @override
  State<BuildingPickerSheet> createState() => _BuildingPickerSheetState();
}

class _BuildingPickerSheetState extends State<BuildingPickerSheet> {
  String _query = '';

  List<BuildingEntity> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.buildings;
    return widget.buildings.where((b) {
      final name = b.name.toLowerCase();
      final address = b.displayAddress.toLowerCase();
      final city = b.city.toLowerCase();
      return name.contains(q) || address.contains(q) || city.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;
    final filtered = _filtered;
    final showAllOption =
        widget.includeAllOption && _query.trim().isEmpty;
    final listCount = filtered.length + (showAllOption ? 1 : 0);

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
          if (listCount == 0)
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
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: AppSizes.spacingL),
              itemCount: listCount,
              itemBuilder: (_, index) {
                if (showAllOption && index == 0) {
                  return _BuildingPickerTile(
                    title: t.allBuildings,
                    subtitle: t.allBuildingsSummary.replaceAll(
                      '{count}',
                      '${widget.buildings.length}',
                    ),
                    selected: widget.selectedBuildingId == null,
                    leadingIcon: Icons.grid_view_rounded,
                    onTap: () => Navigator.of(context).pop(
                      const BuildingPickerResult.allBuildings(),
                    ),
                  );
                }

                final buildingIndex =
                    showAllOption ? index - 1 : index;
                final building = filtered[buildingIndex];
                final apartmentLabel = t.buildingUnitsSummary
                    .replaceAll(
                      '{apartments}',
                      '${building.totalApartments}',
                    );

                return _BuildingPickerTile(
                  title: building.name,
                  subtitle: building.displayAddress.isNotEmpty
                      ? '${building.displayAddress} · $apartmentLabel'
                      : apartmentLabel,
                  selected: widget.selectedBuildingId == building.id,
                  leadingIcon: Icons.apartment_rounded,
                  onTap: () => Navigator.of(context).pop(
                    BuildingPickerResult.building(building.id),
                  ),
                );
              },
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
