import 'dart:math' show max, min;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/selection_mode_widgets.dart';
import '../../../../shared/widgets/async_error_widget.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../apartments/data/apartments_store.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';
import '../../../apartments/presentation/widgets/add_apartment_bottom_sheet.dart';
import '../../domain/entities/building_entity.dart';

import '../../../dues/presentation/providers/dues_provider.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../../../reports/presentation/widgets/report_download_sheet.dart';
import '../../../dashboard/presentation/utils/manager_dashboard_mapper.dart';
import '../models/building_list_item_model.dart';
import '../utils/apartment_ui_utils.dart';
import '../widgets/apartment_details_sheet.dart';
import '../widgets/building_detail_bottom_toolbar.dart';
import '../widgets/building_detail_overview.dart';
import '../../../dashboard/presentation/utils/manager_overdue_remind_helper.dart';
import '../widgets/building_resident_card.dart';
import '../widgets/building_summary_card.dart';
import '../widgets/delete_building_dialog.dart';
import '../widgets/edit_building_bottom_sheet.dart';
import '../../../dues/presentation/utils/dues_amount_update_flow.dart';

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
                          color: AppColors.brand,
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
                                Divider(
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
                side: BorderSide(color: AppColors.borderColor, width: 1.5),
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
    final asyncAllDues = ref.watch(allBuildingsDuesProvider);
    final selectedCount = _selectedApartmentIds.length;
    final hasOccupied =
        asyncApartments.value?.any((a) => a.isOccupied) ?? false;

    return DashboardSecondaryScaffold(
      title: _selectionMode
          ? '$selectedCount ${context.t.common.selectedCountLabel}'
          : context.t.common.buildingDetail,
      canPop: !_selectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _exitSelectionMode();
      },
      leading: _selectionMode
          ? IconButton(
              tooltip: context.t.common.cancelBtn,
              icon: const Icon(Icons.close_rounded),
              onPressed: _exitSelectionMode,
            )
          : const Center(child: AppBackButton()),
      floatingActionButtonLocation: selectionActionFabLocation,
      floatingActionButton: _selectionMode && selectedCount > 0
          ? SelectionActionFab(
              onPressed: _confirmAndRemoveSelected,
              backgroundColor: AppColors.warning,
              icon: Icons.person_remove_outlined,
              label: '${context.t.common.remove} ($selectedCount)',
            )
          : null,
      bottomNavigationBar: _selectionMode
          ? null
          : BuildingDetailBottomToolbar(
              onEdit: () => EditBuildingBottomSheet.show(
                context,
                building: widget.building,
              ),
              onDelete: () =>
                  DeleteBuildingDialog.show(context, building: widget.building),
              onReport: () => ReportDownloadSheet.show(
                context,
                building: widget.building,
              ),
              onDueSettings: () => showBuildingDueAmountUpdateSheet(
                context,
                ref,
                widget.building,
              ),
              onMultiSelect: () {
                if (!hasOccupied) {
                  ref.read(toastProvider.notifier).show(
                        context.t.common.noResidentsToRemoveInBuilding,
                        type: ToastType.info,
                      );
                  return;
                }
                setState(() {
                  _selectionMode = true;
                  _selectedApartmentIds.clear();
                });
              },
            ),
      body: asyncApartments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AsyncErrorWidget(
          message: userFacingError(e),
          onRetry: () => ref
              .read(apartmentsStoreProvider(widget.building.id).notifier)
              .loadApartments(),
        ),
        data: (residents) {
          final allDues = asyncAllDues.value ?? const {};
          final dues = allDues[widget.building.id] ?? const <DueEntity>[];

          // Determine the target month and year (matching BuildingListItemModel logic)
          final now = DateTime.now();
          List<DueEntity> targetDues = dues
              .where((d) => d.month == now.month && d.year == now.year)
              .toList();
          if (targetDues.isEmpty && dues.isNotEmpty) {
            final maxYear = dues
                .map((d) => d.year)
                .reduce((a, b) => a > b ? a : b);
            final maxMonth = dues
                .where((d) => d.year == maxYear)
                .map((d) => d.month)
                .reduce((a, b) => a > b ? a : b);
            targetDues = dues
                .where((d) => d.year == maxYear && d.month == maxMonth)
                .toList();
          }

          final Map<String, DueEntity> duesByApartment = {
            for (final d in targetDues) d.apartmentId: d,
          };

          final enrichedResidents = residents.map((apt) {
            final due = duesByApartment[apt.id];
            if (due != null) {
              PaymentStatus status;
              switch (due.status) {
                case DueStatus.paid:
                  status = PaymentStatus.paid;
                  break;
                case DueStatus.overdue:
                  status = PaymentStatus.overdue;
                  break;
                case DueStatus.waived:
                  status = PaymentStatus.paid;
                  break;
                case DueStatus.pending:
                  status = PaymentStatus.pending;
                  break;
              }
              return apt.copyWith(
                monthlyDues: due.amount,
                paymentStatus: status,
                lastPaymentDate: due.paidAt,
              );
            } else {
              return apt.copyWith(
                monthlyDues: widget.building.dueAmount ?? 0.0,
                paymentStatus: PaymentStatus.pending,
              );
            }
          }).toList();

          return Column(
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
                      : AppSizes.screenBodyScrollPadding.copyWith(
                          bottom: AppSizes.spacingXL,
                        ),
                  itemCount: enrichedResidents.isEmpty
                      ? 3
                      : 3 + enrichedResidents.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildHeader(widget.building);
                    }
                    if (index == 1) {
                      return const SizedBox(height: AppSizes.spacingL);
                    }
                    if (index == 2) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildResidentsSectionHeader(
                            context,
                            residentsCount: enrichedResidents.length,
                          ),
                          const SizedBox(height: AppSizes.spacingM),
                          if (enrichedResidents.isEmpty)
                            _buildEmptyState(context),
                        ],
                      );
                    }

                    final residentIndex = index - 3;
                    final apt = enrichedResidents[residentIndex];
                    return BuildingResidentCard(
                      apt: apt,
                      selectionMode: _selectionMode,
                      selected: _selectedApartmentIds.contains(apt.id),
                      onToggleSelection: _toggleApartmentSelection,
                      onShowDetails: () =>
                          ApartmentDetailsSheet.show(context, apt: apt),
                      onInvite: apt.isOccupied
                          ? null
                          : () => context.push(
                                '/manager-dashboard/invite-code'
                                '?buildingId=${apt.buildingId}'
                                '&apartmentId=${apt.id}',
                              ),
                    );
                  },
                ),
              ),
            ],
          );
        },
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
          style: AppTypography.sectionTitle.copyWith(
            color: AppColors.inkDark,
          ),
        ),
        const SizedBox(width: AppSizes.spacingS),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: BuildingSummaryCard.cardShadow,
          ),
          child: Text(
            '$residentsCount ${context.t.common.apartmentsBadge}',
            style: AppTypography.caption.copyWith(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: context.t.common.addApartment,
          onPressed: () => AddApartmentBottomSheet.show(
            context,
            buildingId: widget.building.id,
          ),
          icon: const Icon(Icons.add_rounded),
          color: AppColors.brand,
          style: IconButton.styleFrom(
            minimumSize: const Size(40, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildingEntity building) {
    final allDues = ref.watch(allBuildingsDuesProvider).value ?? const {};
    final item = BuildingListItemModel.fromEntity(
      building: building,
      allDues: allDues,
    );
    final buildingDues = allDues[building.id] ?? const <DueEntity>[];
    final now = DateTime.now();
    final currentMonthDues = ManagerDashboardMapper.filterDuesForMonth(
      buildingDues,
      month: now.month,
      year: now.year,
    );
    final summary = ManagerDashboardMapper.duesAmountSummary(currentMonthDues);
    final overdueDueIdsByBuilding = groupOverdueDueIdsByBuilding(
      allDues,
      buildingIds: {building.id},
    );

    return BuildingDetailOverview(
      item: item,
      summary: summary,
      currency: building.currency,
      remindDueIdsByBuilding: overdueDueIdsByBuilding,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingXL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(BuildingSummaryCard.cardRadius),
        boxShadow: BuildingSummaryCard.cardShadow,
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 56, color: AppColors.mutedText),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            context.t.common.noApartmentsYet,
            style: AppTypography.body1.copyWith(color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
