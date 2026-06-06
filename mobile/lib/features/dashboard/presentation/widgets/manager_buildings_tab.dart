import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/tint_dashboard_tile.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../../buildings/presentation/widgets/building_actions_sheet.dart';
import '../../../buildings/presentation/widgets/delete_building_dialog.dart';
import '../../../buildings/presentation/widgets/edit_building_bottom_sheet.dart';
import '../../../buildings/presentation/widgets/edit_building_collection_bottom_sheet.dart';
import '../../../dues/presentation/providers/dues_provider.dart';

// manager_dashboard_screen.dart içinden gelen _BuildingsAsyncSection'ı burada kullanamayız
// import etmemiz veya buraya taşımamız gerek. Şimdilik geçici _BuildingsAsyncSection tanımı ekliyorum
// Veya _BuildingsAsyncSection'ı yeni bir dosyaya almalıyız.
import 'buildings_async_section.dart';

class ManagerBuildingsTab extends ConsumerStatefulWidget {
  final AsyncValue<List<BuildingEntity>> buildingsAsync;

  const ManagerBuildingsTab({
    super.key,
    required this.buildingsAsync,
  });

  @override
  ConsumerState<ManagerBuildingsTab> createState() => _ManagerBuildingsTabState();
}

class _ManagerBuildingsTabState extends ConsumerState<ManagerBuildingsTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.screenBodyScrollPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: AppSizes.buttonHeightPrimary,
                  child: ElevatedButton.icon(
                    onPressed: _onAddBuildingPressed,
                    style: AppButtonStyles.elevatedPrimary(),
                    icon: const Icon(Icons.add_business),
                    label: Text(context.t.common.addBuilding),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: SizedBox(
                  height: AppSizes.buttonHeightPrimary,
                  child: ElevatedButton.icon(
                    onPressed: _onCreateInviteCodePressed,
                    style: AppButtonStyles.elevatedAccent(),
                    icon: const Icon(Icons.qr_code_2),
                    label: Text(context.t.common.inviteCode),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingL),
          Text(
            context.t.common.myBuildings,
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          BuildingsAsyncSection(
            buildingsAsync: widget.buildingsAsync,
            onRetry: _onRetryBuildings,
            buildList: (list) => list
                .map((b) => _buildDetailedBuildingCard(b))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  void _onRetryBuildings() {
    ref.read(buildingsStoreProvider.notifier).loadBuildings();
  }

  Widget _buildDetailedBuildingCard(BuildingEntity building) {
    const tileRadius = BorderRadius.all(Radius.circular(12));

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.fill,
          borderRadius: tileRadius,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: tileRadius,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              InkWell(
                borderRadius: tileRadius,
                splashColor: AppColors.border.withValues(alpha: 0.4),
                highlightColor: AppColors.border.withValues(alpha: 0.25),
                onTap: () => _onBuildingTapped(building),
                child: _buildBuildingCardContent(
                  building,
                  reserveMenuSlot: true,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: _buildBuildingActionsMenu(building),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagedBuildingHeader(
    BuildingEntity building, {
    bool reserveMenuSlot = false,
    bool showChevron = false,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: AppSizes.minTouchTargetComfort,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingM,
          vertical: 14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.18),
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.apartment_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          building.name,
                          style: AppTypography.body1.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!building.isCollectionConfigured) ...[
                        const SizedBox(width: AppSizes.spacingXS),
                        Tooltip(
                          message: context
                              .t
                              .features
                              .buildings
                              .collection
                              .ibanNotConfigured,
                          child: Icon(
                            Icons.warning_amber_rounded,
                            size: 20,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.85),
                          ),
                        ),
                        const WidgetSpan(child: SizedBox(width: 4)),
                        TextSpan(text: building.displayAddress),
                      ],
                    ),
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    maxLines: reserveMenuSlot ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (reserveMenuSlot)
              const SizedBox(width: AppSizes.minTouchTargetComfort)
            else if (showChevron) ...[
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right,
                size: 24,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ] else
              _buildBuildingActionsMenu(building),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingCardContent(
    BuildingEntity building, {
    bool reserveMenuSlot = false,
  }) {
    final allDues =
        ref.watch(allBuildingsDuesProvider).value ?? const {};
    final collectionRate = buildingCollectionRate(allDues, building.id);
    final showPerApartmentDues =
        building.dueAmount != null && building.dueAmount! > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildManagedBuildingHeader(
          building,
          reserveMenuSlot: reserveMenuSlot,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.spacingM,
            0,
            AppSizes.spacingM,
            AppSizes.spacingM,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.spacingS),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: DashboardMetricTile.kTileHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: DashboardMetricTile(
                          icon: Icons.door_front_door_outlined,
                          label: context.t.common.apartment,
                          value:
                              '${building.occupiedApartments}/${building.totalApartments}',
                          animateValue: false,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingS),
                      Expanded(
                        child: DashboardMetricTile(
                          icon: Icons.trending_up,
                          label: context.t.common.collection,
                          animatedValue: collectionRate.round(),
                          valuePrefix: '%',
                          valueColor: AppColors.success,
                          animateValue: false,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingS),
                      Expanded(
                        child: DashboardMetricTile(
                          icon: Icons.payments_outlined,
                          label: context.t.common.monthlyDues,
                          value:
                              '₺${building.totalMonthlyDues.toStringAsFixed(0)}',
                          animateValue: false,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showPerApartmentDues) ...[
                  const SizedBox(height: AppSizes.spacingS),
                  Container(
                    height: AppSizes.minTouchTargetComfort,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacingM,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.fill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 18,
                          color: AppColors.textSecondary.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: AppSizes.spacingS),
                        Expanded(
                          child: Text(
                            context.t.common.monthlyDuesPerApartment,
                            style: AppTypography.body2.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSizes.spacingS),
                        Text(
                          '₺${building.dueAmount!.toStringAsFixed(0)}',
                          style: AppTypography.body1.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBuildingActionsMenu(BuildingEntity building) {
    return SizedBox(
      width: AppSizes.minTouchTargetComfort,
      height: AppSizes.minTouchTargetComfort,
      child: IconButton(
        tooltip: MaterialLocalizations.of(context).showMenuTooltip,
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.more_vert,
          color: AppColors.textSecondary,
          size: AppSizes.iconSize,
        ),
        onPressed: () => _openBuildingActionsSheet(building),
      ),
    );
  }

  Future<void> _openBuildingActionsSheet(BuildingEntity building) async {
    final action = await BuildingActionsSheet.show(
      context,
      building: building,
    );
    if (!mounted || action == null) return;
    _onBuildingMenuAction(building, action);
  }

  void _onBuildingMenuAction(BuildingEntity building, BuildingMenuAction action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (action) {
        case BuildingMenuAction.edit:
          EditBuildingBottomSheet.show(context, building: building);
          break;
        case BuildingMenuAction.collection:
          EditBuildingCollectionBottomSheet.show(context, building: building);
          break;
        case BuildingMenuAction.delete:
          unawaited(DeleteBuildingDialog.show(context, building: building));
          break;
      }
    });
  }

  void _onAddBuildingPressed() {
    context.push('/manager-dashboard/add-building');
  }

  void _onCreateInviteCodePressed() {
    context.push('/manager-dashboard/invite-code');
  }

  void _onBuildingTapped(BuildingEntity building) {
    context.push('/manager-dashboard/buildings/${building.id}');
  }
}
