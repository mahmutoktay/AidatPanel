import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../domain/entities/due_entity.dart';
import '../providers/dues_provider.dart';

class ManagerDuesTab extends ConsumerStatefulWidget {
  const ManagerDuesTab({super.key});

  @override
  ConsumerState<ManagerDuesTab> createState() => _ManagerDuesTabState();
}

class _ManagerDuesTabState extends ConsumerState<ManagerDuesTab> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _selectedBuildingId;
  DueStatus? _statusFilter;
  int? _selectedMonth;
  int? _selectedYear;
  bool _initialized = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buildings = ref.watch(buildingsStoreProvider).value ?? [];
    final duesState = ref.watch(duesNotifierProvider);

    _tryInitialize(buildings);

    final filtered = _statusFilter == null
        ? duesState.dues
        : duesState.dues.where((due) => due.status == _statusFilter).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFilters(context, buildings, duesState.isLoading),
          const SizedBox(height: AppSizes.spacingM),
          _buildBulkCard(context, duesState.isLoading),
          const SizedBox(height: AppSizes.spacingL),
          Text(
            context.t.common.buildingDues,
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.spacingM),
          if (duesState.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (filtered.isEmpty)
            _buildEmptyState(context)
          else
            ...filtered.map((due) => _buildDueCard(context, due)),
        ],
      ),
    );
  }

  void _tryInitialize(List<BuildingEntity> buildings) {
    if (_initialized || buildings.isEmpty) return;
    _initialized = true;
    _selectedBuildingId = buildings.first.id;
    _selectedMonth = DateTime.now().month;
    _selectedYear = DateTime.now().year;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectedBuildingId == null) return;
      ref.read(duesNotifierProvider.notifier).loadBuildingDues(_selectedBuildingId!);
    });
  }

  Widget _buildFilters(
    BuildContext context,
    List<BuildingEntity> buildings,
    bool isLoading,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.t.common.buildingDues,
            style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.spacingM),
          DropdownButtonFormField<String>(
            key: ValueKey<String?>('dues_building_${_selectedBuildingId ?? 'none'}'),
            initialValue: _selectedBuildingId,
            isExpanded: true,
            menuMaxHeight: 240,
            items: buildings
                .map(
                  (building) => DropdownMenuItem<String>(
                    value: building.id,
                    child: Text(
                      building.name,
                      style: AppTypography.body1.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                )
                .toList(),
            onChanged: isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _selectedBuildingId = value);
                    ref.read(duesNotifierProvider.notifier).loadBuildingDues(value);
                  },
            decoration: InputDecoration(
              labelText: context.t.common.buildings,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          DropdownButtonFormField<DueStatus?>(
            key: ValueKey<String>('dues_status_${_statusFilter?.name ?? 'all'}'),
            initialValue: _statusFilter,
            isExpanded: true,
            menuMaxHeight: 240,
            items: [
              DropdownMenuItem<DueStatus?>(
                value: null,
                child: Text(context.t.common.all),
              ),
              DropdownMenuItem<DueStatus?>(
                value: DueStatus.pending,
                child: Text(context.t.common.pendingStatus),
              ),
              DropdownMenuItem<DueStatus?>(
                value: DueStatus.paid,
                child: Text(context.t.common.paidStatus),
              ),
              DropdownMenuItem<DueStatus?>(
                value: DueStatus.overdue,
                child: Text(context.t.common.overdueStatus),
              ),
              DropdownMenuItem<DueStatus?>(
                value: DueStatus.waived,
                child: Text(context.t.common.waivedStatus),
              ),
            ],
            onChanged: isLoading ? null : (value) => setState(() => _statusFilter = value),
            decoration: InputDecoration(
              labelText: context.t.common.status,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkCard(BuildContext context, bool isLoading) {
    final currencySymbol = _currencySymbol();
    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.t.common.bulkCreate,
            style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.spacingM),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: context.t.common.amount,
              prefixText: '$currencySymbol ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  key: ValueKey<String>('dues_month_${_selectedMonth ?? 0}'),
                  initialValue: _selectedMonth,
                  isExpanded: true,
                  menuMaxHeight: 240,
                  items: List.generate(
                    12,
                    (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text(_monthLabel(context, index + 1)),
                    ),
                  ),
                  onChanged: isLoading
                      ? null
                      : (value) => setState(() => _selectedMonth = value),
                  decoration: InputDecoration(
                    labelText: context.t.common.month,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: DropdownButtonFormField<int>(
                  key: ValueKey<String>('dues_year_${_selectedYear ?? 0}'),
                  initialValue: _selectedYear,
                  isExpanded: true,
                  menuMaxHeight: 240,
                  items: _yearOptions()
                      .map(
                        (year) => DropdownMenuItem<int>(
                          value: year,
                          child: Text('$year'),
                        ),
                      )
                      .toList(),
                  onChanged:
                      isLoading ? null : (value) => setState(() => _selectedYear = value),
                  decoration: InputDecoration(
                    labelText: context.t.common.year,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingS),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: context.t.common.note,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          SizedBox(
            height: AppSizes.buttonHeightSecondary,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => _createBulk(),
              child: Text(context.t.common.createDues),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueCard(BuildContext context, DueEntity due) {
    final statusVisual = _statusVisual(context, due.status);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  due.apartmentNumber,
                  style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              PopupMenuButton<DueStatus>(
                icon: const Icon(Icons.more_vert),
                onSelected: (status) => _updateStatus(due.id, status),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: DueStatus.paid,
                    child: Text(context.t.common.paidStatus),
                  ),
                  PopupMenuItem(
                    value: DueStatus.pending,
                    child: Text(context.t.common.pendingStatus),
                  ),
                  PopupMenuItem(
                    value: DueStatus.overdue,
                    child: Text(context.t.common.overdueStatus),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            '${_currencySymbol()}${due.amount.toStringAsFixed(2)}',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.spacingXS),
          Text(
            '${context.t.common.month}: ${due.month} • ${context.t.common.year}: ${due.year}',
            style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
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

  Future<void> _createBulk() async {
    if (_selectedBuildingId == null) return;
    final amount = double.tryParse(_amountController.text.trim());
    final month = _selectedMonth;
    final year = _selectedYear;
    if (amount == null || month == null || year == null) return;

    await ref.read(duesNotifierProvider.notifier).createBulk(
          buildingId: _selectedBuildingId!,
          amount: amount,
          month: month,
          year: year,
          currency: _currencyCode(),
          note: _noteController.text.trim(),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.t.common.duesCreated)),
    );
    _amountController.clear();
    _noteController.clear();
  }

  Future<void> _updateStatus(String dueId, DueStatus status) async {
    await ref.read(duesNotifierProvider.notifier).updateStatus(
          dueId: dueId,
          status: status,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.t.common.duesUpdated)),
    );
  }

  List<int> _yearOptions() {
    final nowYear = DateTime.now().year;
    return List<int>.generate(14, (index) => nowYear - 3 + index);
  }

  String _monthLabel(BuildContext context, int month) {
    switch (month) {
      case 1:
        return context.t.common.monthJanuary;
      case 2:
        return context.t.common.monthFebruary;
      case 3:
        return context.t.common.monthMarch;
      case 4:
        return context.t.common.monthApril;
      case 5:
        return context.t.common.monthMay;
      case 6:
        return context.t.common.monthJune;
      case 7:
        return context.t.common.monthJuly;
      case 8:
        return context.t.common.monthAugust;
      case 9:
        return context.t.common.monthSeptember;
      case 10:
        return context.t.common.monthOctober;
      case 11:
        return context.t.common.monthNovember;
      case 12:
      default:
        return context.t.common.monthDecember;
    }
  }

  String _currencyCode() {
    return LocaleSettings.currentLocale == AppLocale.tr ? 'TRY' : 'USD';
  }

  String _currencySymbol() {
    return LocaleSettings.currentLocale == AppLocale.tr ? '₺' : r'$';
  }
}

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
        bg: AppColors.borderColor,
      );
    case DueStatus.pending:
      return _StatusVisual(
        label: context.t.common.pendingStatus,
        fg: AppColors.warning,
        bg: AppColors.warningBg,
      );
  }
}
