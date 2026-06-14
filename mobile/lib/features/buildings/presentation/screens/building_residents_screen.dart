import 'dart:math' show max, min;

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/selection_mode_widgets.dart';
import '../../../../shared/widgets/async_error_widget.dart';
import '../../../../shared/widgets/tint_dashboard_tile.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../apartments/data/apartments_store.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';
import '../../domain/entities/building_entity.dart';

import '../../../dues/presentation/providers/dues_provider.dart';
import '../../../reports/presentation/widgets/report_download_sheet.dart';
import '../widgets/building_resident_card.dart';
import '../widgets/apartment_details_sheet.dart';
import '../utils/apartment_ui_utils.dart';

class BuildingResidentsScreen extends ConsumerStatefulWidget {
  final BuildingEntity building;

  const BuildingResidentsScreen({super.key, required this.building});

  @override
  ConsumerState<BuildingResidentsScreen> createState() =>
      _BuildingResidentsScreenState();
}

class _BuildingResidentsScreenState
    extends ConsumerState<BuildingResidentsScreen> {
  bool _selectionMode = false;
  final Set<String> _selectedApartmentIds = <String>{};

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedApartmentIds.clear();
    });
  }

  void _toggleApartmentSelection(ApartmentEntity apt) {
    if (!apt.isOccupied) return;
    setState(() {
      if (_selectedApartmentIds.contains(apt.id)) {
        _selectedApartmentIds.remove(apt.id);
      } else {
        _selectedApartmentIds.add(apt.id);
      }
    });
  }

  List<ApartmentEntity> _selectedApartmentsOrdered(List<String> ids) {
    final all = ref.read(apartmentsStoreProvider(widget.building.id)).value;
    if (all == null) return const [];
    final byId = {for (final a in all) a.id: a};
    return [
      for (final id in ids)
        if (byId[id] != null) byId[id]!,
    ];
  }

  Future<void> _confirmAndRemoveSelected() async {
    final ids = List<String>.from(_selectedApartmentIds);
    if (ids.isEmpty) {
      ref
          .read(toastProvider.notifier)
          .show(context.t.common.pickResidentsFirst, type: ToastType.info);
      return;
    }
    final apartmentsForDialog = _selectedApartmentsOrdered(ids);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final screenH = MediaQuery.sizeOf(dialogContext).height;
        final listMaxHeight = (screenH * 0.38).clamp(140.0, 320.0);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          title: Text(
            dialogContext.t.common.removeSelectedResidentsTitle,
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dialogContext.t.common.removeSelectedResidentsMessage,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingM),
                Text(
                  dialogContext
                      .t
                      .common
                      .removeSelectedResidentsAffectedListTitle,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingS),
                if (apartmentsForDialog.isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dialogContext
                            .t
                            .common
                            .removeSelectedResidentsListUnavailable,
                        style: AppTypography.body1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingS),
                      Text(
                        '${ids.length}',
                        style: AppTypography.h3.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    height: min(
                      listMaxHeight,
                      max(100.0, 64.0 * apartmentsForDialog.length + 32),
                    ),
                    child: ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      itemCount: apartmentsForDialog.length,
                      itemBuilder: (ctx, i) {
                        final apt = apartmentsForDialog[i];
                        final label = ApartmentUiUtils.formatApartmentLabel(
                          dialogContext,
                          apt.apartmentNumber,
                        );
                        final name = apt.resident?.name ?? apt.residentName;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: i < apartmentsForDialog.length - 1
                                ? AppSizes.spacingM
                                : 0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (i > 0) ...[
                                const Divider(
                                  height: 1,
                                  color: AppColors.borderColor,
                                ),
                                const SizedBox(height: AppSizes.spacingM),
                              ],
                              Text(
                                label,
                                style: AppTypography.body1.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                name,
                                style: AppTypography.body1.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(
                  color: AppColors.borderColor,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(48, 48),
              ),
              child: Text(
                dialogContext.t.common.cancelBtn,
                style: AppTypography.button.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(48, 48),
              ),
              child: Text(dialogContext.t.common.removeSelectedResidents),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (progressContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: AppSizes.spacingM),
                Expanded(
                  child: Text(
                    progressContext.t.common.removeSelectedProgress,
                    style: AppTypography.body1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      final notifier = ref.read(
        apartmentsStoreProvider(widget.building.id).notifier,
      );
      for (final id in ids) {
        await notifier.removeResidentFromApartment(id);
      }
      if (mounted) {
        Navigator.of(context).pop();
        _exitSelectionMode();
        ref
            .read(toastProvider.notifier)
            .show(
              context.t.common.removeSelectedSuccess,
              type: ToastType.success,
            );
      }
    } on ApiException catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ref
            .read(toastProvider.notifier)
            .show(
              userFacingError(e),
              type: ToastType.error,
              duration: const Duration(seconds: 6),
            );
      }
    } catch (_) {
      if (mounted) {
        Navigator.of(context).pop();
        ref
            .read(toastProvider.notifier)
            .show(context.t.common.removeSelectedFailed, type: ToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncApartments = ref.watch(
      apartmentsStoreProvider(widget.building.id),
    );
    final selectedCount = _selectedApartmentIds.length;
    final hasOccupied =
        asyncApartments.value?.any((a) => a.isOccupied) ?? false;

    return PopScope(
      canPop: !_selectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _exitSelectionMode();
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          centerTitle: true,
          leading: _selectionMode
              ? IconButton(
                  tooltip: context.t.common.cancelBtn,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: _exitSelectionMode,
                )
              : null,
          title: Text(
            _selectionMode
                ? '$selectedCount ${context.t.common.selectedCountLabel}'
                : context.t.common.buildingDetail,
          ),
        ),
        floatingActionButtonLocation: selectionActionFabLocation,
        floatingActionButton: _selectionMode && selectedCount > 0
            ? SelectionActionFab(
                onPressed: _confirmAndRemoveSelected,
                backgroundColor: AppColors.warning,
                icon: Icons.person_remove_outlined,
                label: '${context.t.common.remove} ($selectedCount)',
              )
            : null,
        body: asyncApartments.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AsyncErrorWidget(
            message: userFacingError(e),
            onRetry: () => ref
                .read(
                  apartmentsStoreProvider(widget.building.id).notifier,
                )
                .loadApartments(),
          ),
          data: (residents) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_selectionMode)
                SelectionHintBanner(
                  message: context.t.common.selectionRemoveHint,
                ),
              Expanded(
                child: ListView.builder(
                  padding: _selectionMode
                      ? const EdgeInsets.fromLTRB(
                          AppSizes.dashboardScreenPaddingHorizontal,
                          AppSizes.spacingL,
                          AppSizes.dashboardScreenPaddingHorizontal,
                          96,
                        )
                      : AppSizes.screenBodyScrollPadding,
                  itemCount: residents.isEmpty ? 4 : 4 + residents.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildHeader(widget.building);
                    }
                    if (index == 1) {
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSizes.spacingM),
                        child: _BuildingToolbarRow(
                          reportLabel: context.t.features.reports.menuDownload,
                          onReportTap: () => ReportDownloadSheet.show(
                            context,
                            building: widget.building,
                          ),
                          showSelectTrigger: !_selectionMode && hasOccupied,
                          onSelectTap: () => setState(() {
                            _selectionMode = true;
                            _selectedApartmentIds.clear();
                          }),
                          selectLabel: context.t.common.selectTriggerShort,
                        ),
                      );
                    }
                    if (index == 2) {
                      return const SizedBox(height: AppSizes.spacingL);
                    }
                    if (index == 3) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildResidentsSectionHeader(
                            context,
                            residentsCount: residents.length,
                          ),
                          const SizedBox(height: AppSizes.spacingM),
                          if (residents.isEmpty)
                            _buildEmptyState(context),
                        ],
                      );
                    }

                    final residentIndex = index - 4;
                    final apt = residents[residentIndex];
                    return BuildingResidentCard(
                      apt: apt,
                      selectionMode: _selectionMode,
                      selected: _selectedApartmentIds.contains(apt.id),
                      onToggleSelection: _toggleApartmentSelection,
                      onShowDetails: () => ApartmentDetailsSheet.show(context, apt: apt),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResidentsSectionHeader(
    BuildContext context, {
    required int residentsCount,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          context.t.common.residents,
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: AppSizes.spacingS),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.fill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            '$residentsCount ${context.t.common.apartmentsBadge}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildingEntity building) {
    final allDues = ref.watch(allBuildingsDuesProvider).value ?? const {};
    final collectionRate = buildingCollectionRate(allDues, building.id);
    final duesFormatted = NumberFormat('#,##0', 'tr_TR')
        .format(building.totalMonthlyDues.round());

    return Container(
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.apartment_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        building.name,
                        style: AppTypography.h3.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              building.displayAddress,
                              style: AppTypography.body2.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                height: 1.35,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingM),
            SizedBox(
              height: DashboardMetricTile.kTileHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: DashboardMetricTile(
                      icon: Icons.door_front_door_outlined,
                      label: context.t.common.apartmentsBadge,
                      value: '${building.totalApartments}',
                      backgroundColor: AppColors.surface,
                      animateValue: false,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingS),
                  Expanded(
                    child: DashboardMetricTile(
                      icon: Icons.payments_outlined,
                      label: context.t.common.monthlyDues,
                      value: '₺$duesFormatted',
                      backgroundColor: AppColors.surface,
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
                      backgroundColor: AppColors.surface,
                      animateValue: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingXL),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.people_outline, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            context.t.common.noApartmentsYet,
            style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _BuildingToolbarRow extends StatelessWidget {
  const _BuildingToolbarRow({
    required this.reportLabel,
    required this.onReportTap,
    required this.showSelectTrigger,
    required this.onSelectTap,
    required this.selectLabel,
  });

  final String reportLabel;
  final VoidCallback onReportTap;
  final bool showSelectTrigger;
  final VoidCallback onSelectTap;
  final String selectLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.minTouchTargetComfort,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: onReportTap,
            icon: const Icon(Icons.download_rounded, size: 22),
            label: Text(reportLabel),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: const Size(0, AppSizes.minTouchTargetComfort),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: AppTypography.button.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const Spacer(),
          if (showSelectTrigger)
            SelectionTriggerButton(
              label: selectLabel,
              onTap: onSelectTap,
            ),
        ],
      ),
    );
  }
}
