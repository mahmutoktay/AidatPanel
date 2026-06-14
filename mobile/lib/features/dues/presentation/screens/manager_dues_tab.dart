import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/widgets/app_select_field.dart';
import '../../../../shared/widgets/tint_dashboard_tile.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../domain/entities/due_entity.dart';
import '../providers/dues_provider.dart';
import '../widgets/due_status_sheet.dart';

class ManagerDuesTab extends ConsumerStatefulWidget {
  const ManagerDuesTab({super.key});

  @override
  ConsumerState<ManagerDuesTab> createState() => _ManagerDuesTabState();
}

class _ManagerDuesTabState extends ConsumerState<ManagerDuesTab> {
  final TextEditingController _amountController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _selectedBuildingId;
  int? _selectedDueDay;
  DueStatus? _statusFilter;
  int? _monthFilter = DateTime.now().month;
  int? _yearFilter = DateTime.now().year;
  bool _affectCurrent = false;
  bool _initialized = false;
  bool _showAmountCard = false;

  @override
  void initState() {
    super.initState();
    attachPaginationScroll(_scrollController, () {
      ref.read(duesNotifierProvider.notifier).loadMoreBuildingDues();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buildings = ref.watch(buildingsStoreProvider).value ?? [];
    final duesState = ref.watch(duesNotifierProvider);
    final highlightDueId = ref.watch(managerDueHighlightIdProvider);

    ref.listen<ManagerDueNavigationIntent?>(
      managerDueNavigationIntentProvider,
      (previous, next) {
        if (next == null) return;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          final buildingId = next.buildingId;
          if (buildingId != null &&
              buildingId.isNotEmpty &&
              buildings.any((b) => b.id == buildingId)) {
            setState(() => _selectedBuildingId = buildingId);
            await _reloadDues();
          }
          ref.read(managerDueNavigationIntentProvider.notifier).update(null);
        });
      },
    );

    _tryInitialize(buildings);

    final dues = duesState.dues;
    final isLoading = duesState.isLoading;
    final selectedBuilding = _selectedBuildingId != null
        ? _buildingFor(_selectedBuildingId!, buildings)
        : null;

    return RefreshIndicator(
      onRefresh: _reloadDues,
      color: AppColors.primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.dashboardScreenPaddingHorizontal,
              AppSizes.spacingM,
              AppSizes.dashboardScreenPaddingHorizontal,
              0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Seçili bina başlığı (tıklanabilir → bina değiştirme popup'ı)
                if (selectedBuilding != null) ...[
                  _buildSelectedBuildingHeader(
                    context,
                    selectedBuilding,
                    buildings,
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                ],

                // Hero özet kartı
                if (dues.isNotEmpty) ...[
                  _buildDueSummaryHero(dues),
                  const SizedBox(height: AppSizes.spacingM),
                ],

                // Filtreler — kompakt fill kutu (bina seçimi başlıkta)
                _buildCompactFilters(context, buildings, dues, isLoading),
                const SizedBox(height: AppSizes.spacingM),

                // Hızlı işlem: Aidat tutarını güncelle
                if (selectedBuilding != null)
                  _buildQuickAmountUpdate(context, selectedBuilding, isLoading),
                const SizedBox(height: AppSizes.spacingL),

                // Bina aidatları başlığı + sayı rozeti
                if (selectedBuilding != null) _buildDueListHeader(dues.length),
                const SizedBox(height: AppSizes.spacingM),

                if (isLoading && dues.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(minHeight: 3),
                    ),
                  ),
              ]),
            ),
          ),
          if (isLoading && dues.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (dues.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.dashboardScreenPaddingHorizontal,
                0,
                AppSizes.dashboardScreenPaddingHorizontal,
                AppSizes.spacingL,
              ),
              sliver: SliverToBoxAdapter(child: _buildEmptyState(context)),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.dashboardScreenPaddingHorizontal,
                0,
                AppSizes.dashboardScreenPaddingHorizontal,
                AppSizes.spacingL,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => KeyedSubtree(
                    key: ValueKey<String>(dues[index].id),
                    child: _buildDueCard(
                      context,
                      dues[index],
                      highlighted: highlightDueId == dues[index].id,
                    ),
                  ),
                  childCount: dues.length,
                ),
              ),
            ),
          if (duesState.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: AppSizes.spacingL),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Seçili bina başlığı — tıklanınca popup bina seçici açar
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildSelectedBuildingHeader(
    BuildContext context,
    BuildingEntity building,
    List<BuildingEntity> buildings,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showBuildingPicker(context, buildings),
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.border.withValues(alpha: 0.4),
        highlightColor: AppColors.border.withValues(alpha: 0.25),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.spacingM),
          decoration: BoxDecoration(
            color: AppColors.fill,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
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
                        const SizedBox(width: AppSizes.spacingXS),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 22,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 16,
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.85,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          building.dueAmount != null
                              ? '${_currencySymbol()}${building.dueAmount!.toStringAsFixed(0)} / ${context.t.common.monthlyDues}'
                              : context.t.common.noDuesYet,
                          style: AppTypography.body2.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBuildingPicker(
    BuildContext context,
    List<BuildingEntity> buildings,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: AppColors.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.spacingM,
                  AppSizes.spacingM,
                  AppSizes.spacingM,
                  AppSizes.spacingS,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.t.common.buildings,
                        style: AppTypography.h4.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: AppSizes.minTouchTargetComfort,
                      height: AppSizes.minTouchTargetComfort,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.close, size: 22),
                        onPressed: () => Navigator.of(sheetContext).pop(),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: buildings.length,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.spacingS,
                  ),
                  itemBuilder: (_, i) {
                    final b = buildings[i];
                    final isSelected = b.id == _selectedBuildingId;
                    return InkWell(
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        setState(() {
                          _selectedBuildingId = b.id;
                          _selectedDueDay = null;
                        });
                        _reloadDues();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.spacingM,
                          vertical: AppSizes.spacingS + 4,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.10)
                                    : AppColors.fill,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary.withValues(
                                          alpha: 0.25,
                                        )
                                      : AppColors.fill,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.apartment_rounded,
                                size: 24,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    b.name,
                                    style: AppTypography.body1.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    b.displayAddress,
                                    style: AppTypography.body2.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                size: 22,
                                color: AppColors.primary,
                              ),
                            if (!isSelected)
                              Icon(
                                Icons.chevron_right,
                                size: 22,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSizes.spacingS),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Hero özet kartı — DashboardMetricTile ile 3'lü metrik
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildDueSummaryHero(List<DueEntity> dues) {
    final paid = dues.where((d) => d.status == DueStatus.paid).length;
    final pending = dues.where((d) => d.status == DueStatus.pending).length;
    final overdue = dues.where((d) => d.status == DueStatus.overdue).length;

    return SizedBox(
      height: DashboardMetricTile.kTileHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DashboardMetricTile(
              icon: Icons.check_circle_outline,
              animatedValue: paid,
              label: context.t.common.paidStatus,
              valueColor: AppColors.success,
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: DashboardMetricTile(
              icon: Icons.schedule_outlined,
              animatedValue: pending,
              label: context.t.common.pendingStatus,
              valueColor: AppColors.warning,
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: DashboardMetricTile(
              icon: Icons.warning_amber_rounded,
              animatedValue: overdue,
              label: context.t.common.overdueStatus,
              valueColor: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Kompakt filtreler — bina seçimi başlıkta, sadece durum + ay/yıl
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildCompactFilters(
    BuildContext context,
    List<BuildingEntity> buildings,
    List<DueEntity> dues,
    bool isLoading,
  ) {
    final currentYear = DateTime.now().year;
    final yearSet = <int>{
      for (var i = 0; i < 5; i++) currentYear - i,
      ...dues.map((d) => d.year),
    };
    final years = yearSet.toList()..sort((a, b) => b.compareTo(a));

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Durum filtresi
          AppSelectField<DueStatus?>(
            key: ValueKey<String>(
              'dues_status_${_statusFilter?.name ?? 'all'}',
            ),
            label: context.t.common.status,
            value: _statusFilter,
            enabled: !isLoading,
            displayText: (v) => _statusLabel(context, v),
            options: [
              AppSelectOption(value: null, label: context.t.common.all),
              AppSelectOption(
                value: DueStatus.pending,
                label: context.t.common.pendingStatus,
              ),
              AppSelectOption(
                value: DueStatus.paid,
                label: context.t.common.paidStatus,
              ),
              AppSelectOption(
                value: DueStatus.overdue,
                label: context.t.common.overdueStatus,
              ),
              AppSelectOption(
                value: DueStatus.waived,
                label: context.t.common.waivedStatus,
              ),
            ],
            onChanged: isLoading
                ? null
                : (value) {
                    setState(() => _statusFilter = value);
                    _reloadDues();
                  },
          ),
          const SizedBox(height: AppSizes.spacingS),
          // Ay / Yıl
          Row(
            children: [
              Expanded(
                child: AppSelectField<int?>(
                  key: ValueKey<String>('dues_month_${_monthFilter ?? 'all'}'),
                  label: context.t.common.month,
                  value: _monthFilter,
                  enabled: !isLoading,
                  displayText: (v) => v == null
                      ? context.t.common.allMonths
                      : _monthName(context, v),
                  options: [
                    AppSelectOption(
                      value: null,
                      label: context.t.common.allMonths,
                    ),
                    for (var m = 1; m <= 12; m++)
                      AppSelectOption(value: m, label: _monthName(context, m)),
                  ],
                  onChanged: isLoading
                      ? null
                      : (value) {
                          setState(() => _monthFilter = value);
                          _reloadDues();
                        },
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: AppSelectField<int?>(
                  key: ValueKey<String>('dues_year_${_yearFilter ?? 'all'}'),
                  label: context.t.common.year,
                  value: _yearFilter,
                  enabled: !isLoading,
                  displayText: (v) =>
                      v == null ? context.t.common.allYears : '$v',
                  options: [
                    AppSelectOption(
                      value: null,
                      label: context.t.common.allYears,
                    ),
                    for (final y in years)
                      AppSelectOption(value: y, label: '$y'),
                  ],
                  onChanged: isLoading
                      ? null
                      : (value) {
                          setState(() => _yearFilter = value);
                          _reloadDues();
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Hızlı işlem: Aidat tutarı güncelleme (DashboardActionTile stili)
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildQuickAmountUpdate(
    BuildContext context,
    BuildingEntity building,
    bool isLoading,
  ) {
    if (!_showAmountCard) {
      return DashboardActionTile(
        icon: Icons.edit_calendar_outlined,
        label: context.t.common.updateDueAmount,
        value: building.dueAmount != null ? _currencySymbol() : '',
        onTap: () => setState(() => _showAmountCard = true),
      );
    }

    final currencySymbol = _currencySymbol();
    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.t.common.updateDueAmount,
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: AppSizes.minTouchTargetComfort,
                height: AppSizes.minTouchTargetComfort,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => setState(() => _showAmountCard = false),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingS),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: context.t.common.amount,
              prefixText: '$currencySymbol ',
              hintText: building.dueAmount?.toStringAsFixed(0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          AppSelectField<int?>(
            label: context.t.common.dueDay,
            value: _selectedDueDay,
            enabled: !isLoading,
            displayText: (v) =>
                v == null ? context.t.common.selectDueDay : '$v',
            options: [
              AppSelectOption(
                value: null,
                label: context.t.common.selectDueDay,
              ),
              for (var day = 1; day <= 28; day++)
                AppSelectOption(value: day, label: '$day'),
            ],
            onChanged: isLoading
                ? null
                : (value) => setState(() => _selectedDueDay = value),
          ),
          const SizedBox(height: AppSizes.spacingS),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _affectCurrent,
            onChanged: isLoading
                ? null
                : (value) => setState(() => _affectCurrent = value),
            title: Text(
              context.t.common.affectCurrentDues,
              style: AppTypography.body1.copyWith(color: AppColors.textPrimary),
            ),
            subtitle: Text(
              context.t.common.affectCurrentDuesHint,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: AppSizes.buttonHeightSecondary,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => _updateDueAmount([building]),
                    style: AppButtonStyles.elevatedPrimary(),
                    child: Text(context.t.common.update),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Bina aidatları başlık + sayı rozeti
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildDueListHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.t.common.buildingDues,
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingS,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: AppColors.cardBorder,
          ),
          child: Text(
            count.toString(),
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Due kartı — bina kartı stiline benzer (fill zemin + ikon + içerik)
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildDueCard(
    BuildContext context,
    DueEntity due, {
    bool highlighted = false,
  }) {
    final statusVisual = _statusVisual(context, due.status);
    const tileRadius = BorderRadius.all(Radius.circular(12));

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
      child: Container(
        decoration: BoxDecoration(
          color: highlighted ? AppColors.surface : AppColors.fill,
          borderRadius: tileRadius,
          border: highlighted
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Üst satır: daire no + ikon + durum rozeti + menü
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: statusVisual.fg.withValues(alpha: 0.18),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.door_front_door_outlined,
                      color: statusVisual.fg,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          due.apartmentNumber,
                          style: AppTypography.body1.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_monthName(context, due.month)} ${due.year}',
                          style: AppTypography.body2.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusVisual.bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusVisual.label,
                      style: AppTypography.caption.copyWith(
                        color: statusVisual.fg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _buildDueStatusMenu(context, due),
                ],
              ),
              const SizedBox(height: AppSizes.spacingS),
              // Alt satır: tutar + gecikme
              Container(
                padding: const EdgeInsets.all(AppSizes.spacingS),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 18,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.85,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacingS),
                          Text(
                            context.t.common.amount,
                            style: AppTypography.body2.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_currencySymbol()}${due.amount.toStringAsFixed(2)}',
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
              if (due.status == DueStatus.overdue && due.overdueDays > 0) ...[
                const SizedBox(height: AppSizes.spacingS),
                Row(
                  children: [
                    Icon(Icons.error_outline, size: 16, color: AppColors.error),
                    const SizedBox(width: AppSizes.spacingXS),
                    Text(
                      '${due.overdueDays} ${context.t.common.overdueDays}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Yardımcılar
  // ─────────────────────────────────────────────────────────────────────

  void _tryInitialize(List<BuildingEntity> buildings) {
    if (_initialized || buildings.isEmpty) return;
    _initialized = true;
    _selectedBuildingId = buildings.first.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectedBuildingId == null) return;
      _reloadDues();
    });
  }

  Future<void> _reloadDues() async {
    final buildingId = _selectedBuildingId;
    if (buildingId == null) return;
    await ref
        .read(duesNotifierProvider.notifier)
        .loadBuildingDues(
          buildingId,
          month: _monthFilter,
          year: _yearFilter,
          status: _statusFilter,
        );
  }

  void _invalidateDashboardDuesHero() {
    ref.invalidate(allBuildingsDuesProvider);
  }

  String _statusLabel(BuildContext context, DueStatus? status) {
    final t = context.t.common;
    if (status == null) return t.all;
    switch (status) {
      case DueStatus.pending:
        return t.pendingStatus;
      case DueStatus.paid:
        return t.paidStatus;
      case DueStatus.overdue:
        return t.overdueStatus;
      case DueStatus.waived:
        return t.waivedStatus;
    }
  }

  String _monthName(BuildContext context, int month) {
    final t = context.t.common;
    switch (month) {
      case 1:
        return t.monthJanuary;
      case 2:
        return t.monthFebruary;
      case 3:
        return t.monthMarch;
      case 4:
        return t.monthApril;
      case 5:
        return t.monthMay;
      case 6:
        return t.monthJune;
      case 7:
        return t.monthJuly;
      case 8:
        return t.monthAugust;
      case 9:
        return t.monthSeptember;
      case 10:
        return t.monthOctober;
      case 11:
        return t.monthNovember;
      case 12:
        return t.monthDecember;
      default:
        return '$month';
    }
  }

  Widget _buildDueStatusMenu(BuildContext context, DueEntity due) {
    return SizedBox(
      width: AppSizes.minTouchTargetComfort,
      height: AppSizes.minTouchTargetComfort,
      child: IconButton(
        tooltip: context.t.common.status,
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.more_vert,
          size: AppSizes.iconSize,
          color: AppColors.textSecondary,
        ),
        onPressed: () => _openDueStatusSheet(context, due),
      ),
    );
  }

  Future<void> _openDueStatusSheet(BuildContext context, DueEntity due) async {
    final monthLabel =
        '${_monthName(context, due.month)} ${due.year}';
    final status = await DueStatusSheet.show(
      context,
      due: due,
      monthLabel: monthLabel,
    );
    if (!mounted || status == null || status == due.status) return;
    await _updateStatus(due.id, status);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingL),
        child: Text(
          context.t.common.noDuesYet,
          style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Future<void> _updateDueAmount(List<BuildingEntity> buildings) async {
    final buildingId = _selectedBuildingId;
    if (buildingId == null) return;

    final toast = ref.read(toastProvider.notifier);
    void validationToast(String msg) {
      toast.show(msg, type: ToastType.info);
    }

    final amountText = _amountController.text
        .trim()
        .replaceAll(',', '.')
        .replaceAll(' ', '');
    final dueDay = _selectedDueDay;

    double? parsedAmount;
    if (amountText.isNotEmpty) {
      parsedAmount = double.tryParse(amountText);
      if (parsedAmount == null || parsedAmount <= 0) {
        validationToast(context.t.common.dueAmountInvalidPositive);
        return;
      }
    }

    final hasAmount = parsedAmount != null && parsedAmount > 0;
    final hasDueDay = dueDay != null;
    if (!hasAmount && !hasDueDay) {
      validationToast(context.t.common.dueUpdateNeedAmountOrDay);
      return;
    }

    final building = _buildingFor(buildingId, buildings);
    late final double resolvedAmount;
    if (hasAmount) {
      resolvedAmount = parsedAmount;
    } else {
      final stored = building?.dueAmount;
      if (stored == null || stored <= 0) {
        validationToast(context.t.common.dueUpdateNeedStoredAmount);
        return;
      }
      resolvedAmount = stored;
    }

    final ok = await ref
        .read(duesNotifierProvider.notifier)
        .updateBuildingDueAmount(
          buildingId: buildingId,
          dueAmount: resolvedAmount,
          dueDay: dueDay,
          currency: _currencyCode(),
          affectCurrent: _affectCurrent,
        );

    if (!mounted) return;
    toast.show(
      ok
          ? context.t.common.dueAmountUpdated
          : context.t.common.dueAmountUpdateFailed,
      type: ok ? ToastType.success : ToastType.error,
    );
    if (ok) {
      _amountController.clear();
      setState(() {
        _selectedDueDay = null;
        _affectCurrent = false;
        _showAmountCard = false;
      });
      await ref.read(buildingsStoreProvider.notifier).refreshBuildings();
      if (!mounted) return;
      _invalidateDashboardDuesHero();
    }
  }

  BuildingEntity? _buildingFor(String buildingId, List<BuildingEntity> list) {
    for (final b in list) {
      if (b.id == buildingId) return b;
    }
    return null;
  }

  Future<void> _updateStatus(String dueId, DueStatus status) async {
    final buildingId = _selectedBuildingId;
    if (buildingId == null) return;
    await ref
        .read(duesNotifierProvider.notifier)
        .updateStatus(buildingId: buildingId, dueId: dueId, status: status);
    if (!mounted) return;
    _invalidateDashboardDuesHero();
    ref
        .read(toastProvider.notifier)
        .show(context.t.common.duesUpdated, type: ToastType.success);
  }

  String _currencyCode() {
    return LocaleSettings.currentLocale == AppLocale.tr ? 'TRY' : 'USD';
  }

  String _currencySymbol() {
    return LocaleSettings.currentLocale == AppLocale.tr ? '₺' : r'$';
  }
}

// ─────────────────────────────────────────────────────────────────────
// Durum görsel sınıfı
// ─────────────────────────────────────────────────────────────────────
class _StatusVisual {
  final String label;
  final Color fg;
  final Color bg;

  const _StatusVisual({
    required this.label,
    required this.fg,
    required this.bg,
  });
}

_StatusVisual _statusVisual(BuildContext context, DueStatus status) {
  switch (status) {
    case DueStatus.paid:
      return _StatusVisual(
        label: context.t.common.paidStatus,
        fg: AppColors.success,
        bg: AppColors.successBg,
      );
    case DueStatus.overdue:
      return _StatusVisual(
        label: context.t.common.overdueStatus,
        fg: AppColors.error,
        bg: AppColors.errorBg,
      );
    case DueStatus.waived:
      return _StatusVisual(
        label: context.t.common.waivedStatus,
        fg: AppColors.textSecondary,
        bg: AppColors.fill,
      );
    case DueStatus.pending:
      return _StatusVisual(
        label: context.t.common.pendingStatus,
        fg: AppColors.warning,
        bg: AppColors.warningBg,
      );
  }
}
