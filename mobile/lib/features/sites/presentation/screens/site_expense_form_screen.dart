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
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: SizedBox(
          height: AppSizes.buttonHeightPrimary,
          width: double.infinity,
          child: FilledButton(
            onPressed: _submitting ? null : _onSubmit,
            child: _submitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(_isEdit ? context.t.common.save : t.addExpense),
          ),
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
}
