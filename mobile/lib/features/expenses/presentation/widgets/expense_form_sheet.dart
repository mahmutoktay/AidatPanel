import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/app_date_field.dart';
import '../../../../shared/widgets/app_select_field.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../domain/entities/expense_entity.dart';
import '../providers/expenses_provider.dart';
import '../utils/expense_labels.dart';
import 'expense_receipt_section.dart';

/// Gider ekleme / düzenleme formu (B4).
class ExpenseFormSheet extends ConsumerStatefulWidget {
  final String buildingId;
  final ExpenseEntity? expense;

  const ExpenseFormSheet({
    super.key,
    required this.buildingId,
    this.expense,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String buildingId,
    ExpenseEntity? expense,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExpenseFormSheet(
        buildingId: buildingId,
        expense: expense,
      ),
    );
  }

  @override
  ConsumerState<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late ExpenseCategory _category;
  late DateTime _date;
  bool _submitting = false;
  List<PlatformFile> _receiptFiles = [];

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _titleController = TextEditingController(text: e?.title ?? '');
    _noteController = TextEditingController(text: e?.note ?? '');
    _category = e?.category ?? ExpenseCategory.other;
    _date = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.expenses;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spacingM,
              AppSizes.spacingS,
              AppSizes.spacingM,
              AppSizes.spacingM,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
                      decoration: BoxDecoration(
                        color: AppColors.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    _isEdit ? t.editTitle : t.createTitle,
                    style: AppTypography.h4.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: t.fieldTitle),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? t.required : null,
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  AppSelectField<ExpenseCategory>(
                    label: t.fieldCategory,
                    value: _category,
                    displayText: (v) => v?.label(context) ?? '',
                    options: [
                      for (final c in ExpenseCategory.values)
                        AppSelectOption(value: c, label: c.label(context)),
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
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: InputDecoration(labelText: t.fieldNote),
                  ),
                  const SizedBox(height: AppSizes.spacingL),
                  ExpenseReceiptSection(
                    pickedFiles: _receiptFiles,
                    existingReceiptUrl: widget.expense?.receiptUrl,
                    enabled: !_submitting,
                    onChanged: (files) => setState(() => _receiptFiles = files),
                    onPickFailed: () {
                      ref.read(toastProvider.notifier).show(
                            t.receiptPickFailed,
                            type: ToastType.error,
                          );
                    },
                  ),
                  const SizedBox(height: AppSizes.spacingXL),
                  ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(t.submit),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final note = _noteController.text.trim();
    final notifier = ref.read(expensesNotifierProvider.notifier);
    final receiptPaths = _receiptFiles.map((f) => f.path).whereType<String>().toList();

    final result = _isEdit
        ? await notifier.update(
            expenseId: widget.expense!.id,
            title: _titleController.text.trim(),
            category: _category,
            date: _date,
            note: note.isEmpty ? '' : note,
            receiptFilePaths: receiptPaths,
          )
        : await notifier.create(
            buildingId: widget.buildingId,
            title: _titleController.text.trim(),
            category: _category,
            date: _date,
            note: note.isEmpty ? null : note,
            receiptFilePaths: receiptPaths,
          );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!result.success) return;

    final toast = ref.read(toastProvider.notifier);
    final expensesT = context.t.features.expenses;
    if (result.receiptUploadDeferred) {
      toast.show(expensesT.receiptPendingBackend, type: ToastType.warning);
    } else if (result.receiptWarning != null) {
      toast.show(result.receiptWarning!, type: ToastType.warning);
    }
    toast.show(
      _isEdit
          ? context.t.features.expenses.updateSuccess
          : context.t.features.expenses.createSuccess,
      type: ToastType.success,
    );
    Navigator.of(context).pop(true);
  }
}
