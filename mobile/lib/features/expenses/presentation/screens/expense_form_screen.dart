import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/month_labels.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/app_date_field.dart';
import '../../../../shared/widgets/app_select_field.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/sliding_segmented_control.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../profile/presentation/theme/profile_settings_ui.dart';
import '../../domain/entities/expense_create_outcome.dart';
import '../../domain/entities/expense_entity.dart';
import '../providers/expenses_provider.dart';
import '../utils/expense_labels.dart';
import '../widgets/expense_receipt_section.dart';

enum _TargetMonthMode { thisMonth, nextMonth, specific }

/// Gider ekleme / düzenleme — tam ekran form.
class ExpenseFormScreen extends ConsumerStatefulWidget {
  final String buildingId;
  final ExpenseEntity? expense;

  const ExpenseFormScreen({
    super.key,
    required this.buildingId,
    this.expense,
  });

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late ExpenseCategory _category;
  late DateTime _date;
  late _TargetMonthMode _targetMode;
  late int _targetMonth;
  late int _targetYear;
  bool _submitting = false;
  List<PlatformFile> _receiptFiles = [];

  bool get _isEdit => widget.expense != null;

  int get _sectionCount {
    var count = 3; // basic info, note, receipt
    if (!_isEdit) count += 1; // target month
    count += 1; // submit button
    return count;
  }

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    final now = DateTime.now();
    _titleController = TextEditingController(text: e?.title ?? '');
    _noteController = TextEditingController(text: e?.note ?? '');
    _category = e?.category ?? ExpenseCategory.other;
    _date = e?.date ?? now;
    _targetMonth = e?.targetMonth ?? now.month;
    _targetYear = e?.targetYear ?? now.year;
    _targetMode = _TargetMonthMode.thisMonth;
  }

  List<int> get _targetYearOptions {
    final now = DateTime.now().year;
    return [for (var y = now - 2; y <= now + 2; y++) y];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  DateTime get _resolvedTargetPeriod {
    final now = DateTime.now();
    switch (_targetMode) {
      case _TargetMonthMode.thisMonth:
        return DateTime(now.year, now.month);
      case _TargetMonthMode.nextMonth:
        return DateTime(now.year, now.month + 1);
      case _TargetMonthMode.specific:
        return DateTime(_targetYear, _targetMonth);
    }
  }

  bool get _isPastTarget {
    final now = DateTime.now();
    final target = _resolvedTargetPeriod;
    if (target.year < now.year) return true;
    if (target.year == now.year && target.month < now.month) return true;
    return false;
  }

  InputDecoration _fieldDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: ProfileSettingsUi.fieldLabel,
        floatingLabelStyle: ProfileSettingsUi.fieldLabel.copyWith(
          color: ProfileSettingsUi.ink,
        ),
        filled: true,
        fillColor: AppColors.fill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ProfileSettingsUi.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ProfileSettingsUi.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ProfileSettingsUi.radiusMd),
          borderSide: BorderSide(color: ProfileSettingsUi.ink, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ProfileSettingsUi.radiusMd),
          borderSide: const BorderSide(color: ProfileSettingsUi.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingM,
          vertical: AppSizes.spacingM,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.expenses;
    final expense = widget.expense;

    return DashboardSecondaryScaffold(
      title: _isEdit ? t.editTitle : t.createTitle,
      canPop: !_submitting,
      body: Form(
        key: _formKey,
        child: ListView.builder(
          padding: AppSizes.screenBodyScrollPadding,
          itemCount: _sectionCount,
          itemBuilder: (context, index) {
            var sectionIndex = index;
            if (sectionIndex == 0) {
              return Padding(
                padding: DashboardScreenStyle.listItemPadding,
                child: DashboardSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          enabled: !_submitting,
                          style: ProfileSettingsUi.fieldValue,
                          cursorColor: ProfileSettingsUi.ink,
                          decoration: _fieldDecoration(t.fieldTitle),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? t.required : null,
                        ),
                        const SizedBox(height: AppSizes.spacingM),
                        AppSelectField<ExpenseCategory>(
                          label: t.fieldCategory,
                          value: _category,
                          enabled: !_submitting,
                          displayText: (v) => v?.label(context) ?? '',
                          options: [
                            for (final c in ExpenseCategory.values)
                              AppSelectOption(
                                value: c,
                                label: c.label(context),
                              ),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _category = v);
                          },
                        ),
                        const SizedBox(height: AppSizes.spacingM),
                        AppDateField(
                          label: t.fieldDate,
                          value: _date,
                          enabled: !_submitting,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          onChanged: (picked) => setState(() => _date = picked),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppSizes.spacingXS,
                            left: AppSizes.spacingXS,
                          ),
                          child: Text(
                            t.fieldDateHint,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              sectionIndex -= 1;

              if (!_isEdit) {
                if (sectionIndex == 0) {
                  return Padding(
                    padding: DashboardScreenStyle.listItemPadding,
                    child: DashboardSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            t.targetMonthLabel,
                            style: ProfileSettingsUi.sectionLabel,
                          ),
                          const SizedBox(height: AppSizes.spacingS),
                          SlidingSegmentedControl(
                            segments: [
                              t.targetThisMonth,
                              t.targetNextMonth,
                              t.targetSpecificMonth,
                            ],
                            selectedIndex: _targetMode.index,
                            onChanged: (index) {
                              setState(() {
                                _targetMode = _TargetMonthMode.values[index];
                              });
                            },
                          ),
                          if (_targetMode == _TargetMonthMode.specific) ...[
                            const SizedBox(height: AppSizes.spacingM),
                            Row(
                              children: [
                                Expanded(
                                  child: AppSelectField<int>(
                                    label: t.fieldMonth,
                                    value: _targetMonth,
                                    enabled: !_submitting,
                                    displayText: (v) => v == null
                                        ? ''
                                        : localizedMonthName(context, v),
                                    options: [
                                      for (var m = 1; m <= 12; m++)
                                        AppSelectOption(
                                          value: m,
                                          label: localizedMonthName(context, m),
                                        ),
                                    ],
                                    onChanged: !_submitting
                                        ? (v) {
                                            if (v != null) {
                                              setState(() => _targetMonth = v);
                                            }
                                          }
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: AppSizes.spacingS),
                                Expanded(
                                  child: AppSelectField<int>(
                                    label: t.fieldYear,
                                    value: _targetYear,
                                    enabled: !_submitting,
                                    displayText: (v) => v == null ? '' : '$v',
                                    options: [
                                      for (final y in _targetYearOptions)
                                        AppSelectOption(value: y, label: '$y'),
                                    ],
                                    onChanged: !_submitting
                                        ? (v) {
                                            if (v != null) {
                                              setState(() => _targetYear = v);
                                            }
                                          }
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox(height: AppSizes.spacingS),
                            Text(
                              t.targetPeriodSummary
                                  .replaceAll(
                                    '{month}',
                                    localizedMonthName(
                                      context,
                                      _resolvedTargetPeriod.month,
                                    ),
                                  )
                                  .replaceAll(
                                    '{year}',
                                    '${_resolvedTargetPeriod.year}',
                                  ),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          if (_isPastTarget) ...[
                            const SizedBox(height: AppSizes.spacingM),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.spacingM,
                                vertical: AppSizes.spacingS,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.warning),
                              ),
                              child: Text(
                                t.pastMonthWarning,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }
                sectionIndex -= 1;
              }

              if (sectionIndex == 0) {
                return Padding(
                  padding: DashboardScreenStyle.listItemPadding,
                  child: DashboardSurfaceCard(
                    child: TextFormField(
                      controller: _noteController,
                      enabled: !_submitting,
                      maxLines: 3,
                      style: ProfileSettingsUi.fieldValue,
                      cursorColor: ProfileSettingsUi.ink,
                      decoration: _fieldDecoration(t.fieldNote),
                    ),
                  ),
                );
              }
              sectionIndex -= 1;

              if (sectionIndex == 0) {
                return Padding(
                  padding: DashboardScreenStyle.listItemPadding,
                  child: DashboardSurfaceCard(
                    child: ExpenseReceiptSection(
                      pickedFiles: _receiptFiles,
                      existingReceiptUrl: widget.expense?.receiptUrl,
                      enabled: !_submitting,
                      caption: t.amountFromReceiptsHint,
                      amountLabel: _isEdit && expense?.amount != null
                          ? '${expense!.amount!.toStringAsFixed(2)} ₺'
                          : null,
                      onChanged: (files) =>
                          setState(() => _receiptFiles = files),
                      onPickFailed: () {
                        ref.read(toastProvider.notifier).show(
                              t.receiptPickFailed,
                              type: ToastType.error,
                            );
                      },
                    ),
                  ),
                );
              }
              sectionIndex -= 1;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_isEdit && _receiptFiles.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
                      child: Text(
                        t.receiptRequired,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  SizedBox(
                    height: ProfileSettingsUi.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ProfileSettingsUi.primaryButton,
                      child: _submitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(t.submit),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                ],
              );
            },
          ),
        ),
    );
  }

  Future<ExpenseCarryForwardPolicy?> _showCarryForwardDialog(
    ExpensePaidImpactPreview preview,
  ) async {
    final t = context.t.features.expenses;
    return showDialog<ExpenseCarryForwardPolicy>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.carryForwardDialogTitle),
        content: Text(preview.message),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop(ExpenseCarryForwardPolicy.warnOnly),
            child: Text(t.carryForwardManual),
          ),
          FilledButton(
            onPressed: () => Navigator.of(
              ctx,
            ).pop(ExpenseCarryForwardPolicy.carryToNextMonth),
            child: Text(t.carryForwardAuto),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final receiptPaths =
        _receiptFiles.map((f) => f.path).whereType<String>().toList();

    if (!_isEdit && receiptPaths.isEmpty) {
      setState(() {});
      return;
    }

    setState(() => _submitting = true);

    final note = _noteController.text.trim();
    final notifier = ref.read(expensesNotifierProvider.notifier);
    final target = _resolvedTargetPeriod;

    if (_isEdit) {
      final result = await notifier.update(
        expenseId: widget.expense!.id,
        title: _titleController.text.trim(),
        category: _category,
        date: _date,
        note: note.isEmpty ? '' : note,
        receiptFilePaths: receiptPaths.isEmpty ? null : receiptPaths,
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      if (!result.success) return;
      _finishSuccess(result.receiptWarning, result.receiptUploadDeferred);
      return;
    }

    var policy = ExpenseCarryForwardPolicy.warnOnly;
    var confirmPaidImpact = false;

    for (var attempt = 0; attempt < 2; attempt++) {
      final result = await notifier.create(
        buildingId: widget.buildingId,
        title: _titleController.text.trim(),
        category: _category,
        date: _date,
        targetMonth: target.month,
        targetYear: target.year,
        note: note.isEmpty ? null : note,
        carryForwardPolicy: policy,
        confirmPaidImpact: confirmPaidImpact,
        receiptFilePaths: receiptPaths,
      );

      if (!mounted) return;

      if (result.preview != null) {
        final chosen = await _showCarryForwardDialog(result.preview!);
        if (!mounted) return;
        if (chosen == null) {
          setState(() => _submitting = false);
          return;
        }
        policy = chosen;
        confirmPaidImpact = true;
        continue;
      }

      setState(() => _submitting = false);
      if (!result.success) return;
      _finishSuccess(result.receiptWarning, result.receiptUploadDeferred);
      return;
    }

    if (mounted) setState(() => _submitting = false);
  }

  void _finishSuccess(String? receiptWarning, bool receiptUploadDeferred) {
    final toast = ref.read(toastProvider.notifier);
    final expensesT = context.t.features.expenses;
    if (receiptUploadDeferred) {
      toast.show(expensesT.receiptPendingBackend, type: ToastType.warning);
    } else if (receiptWarning != null) {
      toast.show(receiptWarning, type: ToastType.warning);
    }
    toast.show(
      _isEdit ? expensesT.updateSuccess : expensesT.createSuccess,
      type: ToastType.success,
    );
    if (!_isEdit) {
      toast.show(expensesT.amountOcrPending, type: ToastType.info);
    }
    context.pop(true);
  }
}
