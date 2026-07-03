import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/month_labels.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/app_date_field.dart';
import '../../../../shared/widgets/app_select_field.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
<<<<<<< HEAD
import '../../../../shared/widgets/sliding_segmented_control.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../expenses/data/datasources/expense_remote_datasource.dart';
import '../../../expenses/domain/entities/expense_create_outcome.dart';
=======
import '../../../../shared/widgets/toast_overlay.dart';
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../expenses/presentation/utils/expense_labels.dart';
import '../../../profile/presentation/theme/profile_settings_ui.dart';
import '../../domain/entities/site_expense_entity.dart';
import '../providers/site_expenses_provider.dart';

<<<<<<< HEAD
enum _TargetMonthMode { thisMonth, nextMonth, specific }

class SiteExpenseFormScreen extends ConsumerStatefulWidget {
=======
class SiteExpenseFormScreen extends ConsumerStatefulWidget {
  final String siteId;
  final SiteExpenseEntity? expense;

>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  const SiteExpenseFormScreen({
    super.key,
    required this.siteId,
    this.expense,
  });

<<<<<<< HEAD
  final String siteId;
  final SiteExpenseEntity? expense;

=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  @override
  ConsumerState<SiteExpenseFormScreen> createState() =>
      _SiteExpenseFormScreenState();
}

class _SiteExpenseFormScreenState extends ConsumerState<SiteExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late ExpenseCategory _category;
  late DateTime _date;
<<<<<<< HEAD
  late _TargetMonthMode _targetMode;
=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  late int _targetMonth;
  late int _targetYear;
  bool _submitting = false;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    final now = DateTime.now();
    _titleController = TextEditingController(text: e?.title ?? '');
    _amountController = TextEditingController(
<<<<<<< HEAD
      text: e?.amount?.toStringAsFixed(2) ?? '',
=======
      text: e?.amount != null ? e!.amount!.toStringAsFixed(0) : '',
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    );
    _noteController = TextEditingController(text: e?.note ?? '');
    _category = e?.category ?? ExpenseCategory.other;
    _date = e?.date ?? now;
    _targetMonth = e?.targetMonth ?? now.month;
    _targetYear = e?.targetYear ?? now.year;
<<<<<<< HEAD
    _targetMode = _TargetMonthMode.thisMonth;
=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
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

  InputDecoration _fieldDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: ProfileSettingsUi.fieldLabel,
        filled: true,
        fillColor: AppColors.fill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ProfileSettingsUi.radiusMd),
          borderSide: BorderSide.none,
        ),
      );

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
            onPressed: () => Navigator.of(ctx).pop(
              ExpenseCarryForwardPolicy.carryToNextMonth,
            ),
            child: Text(t.carryForwardAuto),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;

    final amount = double.tryParse(
      _amountController.text.trim().replaceAll(',', '.'),
    );
    if (amount == null || amount <= 0) return;

    setState(() => _submitting = true);
    final notifier = ref.read(siteExpensesNotifierProvider.notifier);
    final note = _noteController.text.trim();
    final target = _resolvedTargetPeriod;

    if (_isEdit) {
      final ok = await notifier.update(
        expense: widget.expense!,
        title: _titleController.text.trim(),
        amount: amount,
        category: _category,
        date: _date,
        targetMonth: target.month,
        targetYear: target.year,
        note: note.isEmpty ? null : note,
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      if (!ok) return;
      ref.read(toastProvider.notifier).show(
            context.t.features.expenses.updateSuccess,
            type: ToastType.success,
          );
      context.pop(true);
      return;
    }

    var policy = ExpenseCarryForwardPolicyApi.warnOnly;
    var confirmPaidImpact = false;

    for (var attempt = 0; attempt < 2; attempt++) {
      final result = await notifier.create(
        siteId: widget.siteId,
        title: _titleController.text.trim(),
        amount: amount,
        category: _category,
        date: _date,
        targetMonth: target.month,
        targetYear: target.year,
        note: note.isEmpty ? null : note,
        carryForwardPolicy: policy,
        confirmPaidImpact: confirmPaidImpact,
      );

      if (!mounted) return;

      if (result.preview != null) {
        final chosen = await _showCarryForwardDialog(result.preview!);
        if (!mounted) return;
        if (chosen == null) {
          setState(() => _submitting = false);
          return;
        }
        policy = chosen == ExpenseCarryForwardPolicy.carryToNextMonth
            ? ExpenseCarryForwardPolicyApi.carryToNextMonth
            : ExpenseCarryForwardPolicyApi.warnOnly;
        confirmPaidImpact = true;
        continue;
      }

      setState(() => _submitting = false);
      if (!result.success) return;
      ref.read(toastProvider.notifier).show(
            context.t.features.expenses.createSuccess,
            type: ToastType.success,
          );
      context.pop(true);
      return;
    }

    if (mounted) setState(() => _submitting = false);
=======
  List<int> get _targetYearOptions {
    final now = DateTime.now().year;
    return [for (var y = now - 2; y <= now + 2; y++) y];
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final t = context.t.features.expenses;
    final siteT = context.t.features.sites;

    return PopScope(
      canPop: !_submitting,
      child: DashboardSecondaryScaffold(
        title: _isEdit ? t.editTitle : siteT.addSiteExpense,
        body: Form(
          key: _formKey,
          child: ListView(
            padding: AppSizes.screenBodyScrollPadding,
            children: [
              DashboardSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      enabled: !_submitting,
                      decoration: _fieldDecoration(t.fieldTitle),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? t.required : null,
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    TextFormField(
                      controller: _amountController,
                      enabled: !_submitting,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.,]'),
                        ),
                      ],
                      decoration: _fieldDecoration(t.fieldAmount),
                      validator: (v) {
                        final raw = v?.trim().replaceAll(',', '.') ?? '';
                        final n = double.tryParse(raw);
                        if (n == null || n <= 0) return t.amountInvalid;
                        return null;
                      },
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
                  ],
                ),
              ),
              if (!_isEdit) ...[
                const SizedBox(height: AppSizes.spacingM),
                DashboardSurfaceCard(
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
                                  for (final y in [
                                    DateTime.now().year,
                                    DateTime.now().year - 1,
                                    DateTime.now().year - 2,
                                  ])
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
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSizes.spacingM),
              DashboardSurfaceCard(
                child: TextFormField(
                  controller: _noteController,
                  enabled: !_submitting,
                  maxLines: 3,
                  decoration: _fieldDecoration(t.fieldNote),
                ),
              ),
              const SizedBox(height: AppSizes.spacingL),
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
            ],
          ),
=======
    final t = context.t.features.sites;
    final expensesT = context.t.features.expenses;

    return DashboardSecondaryScaffold(
      title: _isEdit ? t.editExpenseTitle : t.addExpenseTitle,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSizes.screenBodyScrollPadding,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: expensesT.fieldTitle,
                filled: true,
                fillColor: AppColors.fill,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(ProfileSettingsUi.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? context.t.common.fieldRequired
                  : null,
            ),
            const SizedBox(height: AppSizes.spacingFieldSpacing),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: expensesT.fieldAmount,
                suffixText: '₺',
                filled: true,
                fillColor: AppColors.fill,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(ProfileSettingsUi.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                final n = double.tryParse(v?.trim() ?? '');
                if (n == null || n <= 0) {
                  return context.t.common.fieldRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacingFieldSpacing),
            AppSelectField<ExpenseCategory>(
              label: expensesT.fieldCategory,
              value: _category,
              options: ExpenseCategory.values
                  .map(
                    (c) => AppSelectOption(
                      value: c,
                      label: c.label(context),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: AppSizes.spacingFieldSpacing),
            AppDateField(
              label: expensesT.fieldDate,
              value: _date,
              onChanged: (d) => setState(() => _date = d),
            ),
            if (!_isEdit) ...[
              const SizedBox(height: AppSizes.spacingFieldSpacing),
              AppSelectField<int>(
                label: expensesT.targetMonthLabel,
                value: _targetMonth,
                options: List.generate(
                  12,
                  (i) => AppSelectOption(
                    value: i + 1,
                    label: localizedMonthName(context, i + 1),
                  ),
                ),
                onChanged: (v) {
                  if (v != null) setState(() => _targetMonth = v);
                },
              ),
              const SizedBox(height: AppSizes.spacingFieldSpacing),
              AppSelectField<int>(
                label: expensesT.fieldYear,
                value: _targetYear,
                options: _targetYearOptions
                    .map((y) => AppSelectOption(value: y, label: '$y'))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _targetYear = v);
                },
              ),
            ],
            const SizedBox(height: AppSizes.spacingFieldSpacing),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: expensesT.fieldNote,
                filled: true,
                fillColor: AppColors.fill,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(ProfileSettingsUi.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSizes.spacingXL),
            SizedBox(
              height: AppSizes.buttonHeightPrimary,
              child: FilledButton(
                onPressed: _submitting ? null : _onSubmit,
                child: _submitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text(_isEdit ? context.t.common.save : t.addExpense),
              ),
            ),
          ],
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        ),
      ),
    );
  }
<<<<<<< HEAD
=======

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    final siteT = context.t.features.sites;

    try {
      final amount = double.parse(_amountController.text.trim());
      if (_isEdit) {
        final ok = await ref
            .read(siteExpensesNotifierProvider.notifier)
            .update(
              siteId: widget.siteId,
              expenseId: widget.expense!.id,
              title: _titleController.text.trim(),
              amount: amount,
              category: _category,
              date: _date,
              note: _noteController.text.trim(),
            );
        if (!mounted) return;
        if (ok) {
          ref.read(toastProvider.notifier).show(
                siteT.expenseUpdated,
                type: ToastType.success,
              );
          context.pop(true);
        }
        return;
      }

      final result = await ref
          .read(siteExpensesNotifierProvider.notifier)
          .create(
            siteId: widget.siteId,
            title: _titleController.text.trim(),
            amount: amount,
            category: _category,
            date: _date,
            targetMonth: _targetMonth,
            targetYear: _targetYear,
            note: _noteController.text.trim(),
          );

      if (!mounted) return;
      if (result.preview != null) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(siteT.confirmExpenseTitle),
            content: Text(result.preview!.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(context.t.common.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(context.t.common.confirm),
              ),
            ],
          ),
        );
        if (confirm == true && mounted) {
          final retry = await ref
              .read(siteExpensesNotifierProvider.notifier)
              .create(
                siteId: widget.siteId,
                title: _titleController.text.trim(),
                amount: amount,
                category: _category,
                date: _date,
                targetMonth: _targetMonth,
                targetYear: _targetYear,
                note: _noteController.text.trim(),
                confirmPaidImpact: true,
              );
          if (!mounted) return;
          if (retry.success) {
            ref.read(toastProvider.notifier).show(
                  siteT.expenseCreated,
                  type: ToastType.success,
                );
            context.pop(true);
          }
        }
        return;
      }

      if (result.success) {
        ref.read(toastProvider.notifier).show(
              siteT.expenseCreated,
              type: ToastType.success,
            );
        context.pop(true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
}
