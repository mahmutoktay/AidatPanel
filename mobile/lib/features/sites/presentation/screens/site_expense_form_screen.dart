import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/list_cache_refresh.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/month_labels.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/app_date_field.dart';
import '../../../../shared/widgets/app_select_field.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/form_step_actions.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../expenses/presentation/utils/expense_labels.dart';
import '../../../profile/presentation/theme/profile_settings_ui.dart';
import '../../domain/entities/site_expense_entity.dart';
import '../providers/site_expenses_provider.dart';

class SiteExpenseFormScreen extends ConsumerStatefulWidget {
  final String siteId;
  final SiteExpenseEntity? expense;

  const SiteExpenseFormScreen({
    super.key,
    required this.siteId,
    this.expense,
  });

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
      text: e?.amount != null ? e!.amount!.toStringAsFixed(0) : '',
    );
    _noteController = TextEditingController(text: e?.note ?? '');
    _category = e?.category ?? ExpenseCategory.other;
    _date = e?.date ?? now;
    _targetMonth = e?.targetMonth ?? now.month;
    _targetYear = e?.targetYear ?? now.year;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<int> get _targetYearOptions {
    final now = DateTime.now().year;
    return [for (var y = now - 2; y <= now + 2; y++) y];
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;
    final expensesT = context.t.features.expenses;

    return DashboardSecondaryScaffold(
      title: _isEdit ? t.editExpenseTitle : t.addExpenseTitle,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSizes.screenBodyScrollPadding,
          children: [
            MinimalTextField(
              controller: _titleController,
              label: expensesT.fieldTitle,
              icon: Icons.title_outlined,
              required: true,
              enabled: !_submitting,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? context.t.common.fieldRequired
                  : null,
            ),
            const SizedBox(height: AppSizes.spacingM),
            MinimalTextField(
              controller: _amountController,
              label: expensesT.fieldAmount,
              icon: Icons.payments_outlined,
              required: true,
              enabled: !_submitting,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              suffix: Text(
                '₺',
                style: ProfileSettingsUi.fieldValue.copyWith(
                  color: ProfileSettingsUi.muted,
                ),
              ),
              validator: (v) {
                final n = double.tryParse(v?.trim() ?? '');
                if (n == null || n <= 0) {
                  return context.t.common.fieldRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacingM),
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
            const SizedBox(height: AppSizes.spacingM),
            AppDateField(
              label: expensesT.fieldDate,
              value: _date,
              onChanged: (d) => setState(() => _date = d),
            ),
            if (!_isEdit) ...[
              const SizedBox(height: AppSizes.spacingM),
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
              const SizedBox(height: AppSizes.spacingM),
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
            const SizedBox(height: AppSizes.spacingM),
            MinimalTextField(
              controller: _noteController,
              label: expensesT.fieldNote,
              icon: Icons.notes_outlined,
              maxLines: 3,
              enabled: !_submitting,
            ),
            FormStepActions(
              primaryLabel: _isEdit ? context.t.common.save : t.addExpense,
              onPrimary: _submitting ? null : _onSubmit,
              isLoading: _submitting,
            ),
          ],
        ),
      ),
    );
  }

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
          await _finishSuccess();
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
            await _finishSuccess();
          }
        }
        return;
      }

      if (result.success) {
        ref.read(toastProvider.notifier).show(
              siteT.expenseCreated,
              type: ToastType.success,
            );
        await _finishSuccess();
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _finishSuccess() async {
    await invalidateSiteExpensesRelatedCaches(ref, siteId: widget.siteId);
    if (!mounted) return;
    context.pop(true);
  }
}
