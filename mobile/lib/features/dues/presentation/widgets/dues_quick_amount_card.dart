import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/show_due_day_picker.dart';

/// Aidat tutarı güncelleme alt sayfası.
class DuesAmountUpdateSheet extends StatefulWidget {
  final TextEditingController amountController;
  final int? selectedDueDay;
  final bool affectCurrent;
  final bool isLoading;
  final String? hintAmount;
  final ValueChanged<int?> onDueDayChanged;
  final ValueChanged<bool> onAffectCurrentChanged;
  final Future<void> Function() onSubmit;

  const DuesAmountUpdateSheet({
    super.key,
    required this.amountController,
    required this.selectedDueDay,
    required this.affectCurrent,
    required this.isLoading,
    required this.hintAmount,
    required this.onDueDayChanged,
    required this.onAffectCurrentChanged,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required TextEditingController amountController,
    required int? selectedDueDay,
    required bool affectCurrent,
    required bool isLoading,
    required String? hintAmount,
    required String currencySymbol,
    required ValueChanged<int?> onDueDayChanged,
    required ValueChanged<bool> onAffectCurrentChanged,
    required Future<void> Function() onSubmit,
  }) {
    return PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (_) => DuesAmountUpdateSheet(
        amountController: amountController,
        selectedDueDay: selectedDueDay,
        affectCurrent: affectCurrent,
        isLoading: isLoading,
        hintAmount: hintAmount,
        onDueDayChanged: onDueDayChanged,
        onAffectCurrentChanged: onAffectCurrentChanged,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<DuesAmountUpdateSheet> createState() => _DuesAmountUpdateSheetState();
}

class _DuesAmountUpdateSheetState extends State<DuesAmountUpdateSheet> {
  bool _pickingDueDay = false;
  bool _isSubmitting = false;
  late int? _selectedDueDay;
  late bool _affectCurrent;

  @override
  void initState() {
    super.initState();
    _selectedDueDay = widget.selectedDueDay;
    _affectCurrent = widget.affectCurrent;
  }

  Future<void> _pickDueDay(BuildContext context) async {
    if (_isSubmitting || _pickingDueDay) return;
    setState(() => _pickingDueDay = true);
    try {
      final picked = await showDueDayPicker(
        context,
        selectedDueDay: _selectedDueDay,
      );
      if (picked == null) return;
      final newValue =
          picked == kDueDayClearSentinel ? null : picked;
      setState(() => _selectedDueDay = newValue);
      widget.onDueDayChanged(newValue);
    } finally {
      if (mounted) setState(() => _pickingDueDay = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const currencySymbol = '₺';
    final t = context.t.common;

    return PremiumBottomSheetScaffold(
      title: t.updateDueAmount,
      scrollable: false,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MinimalTextField(
            controller: widget.amountController,
            label: t.amount,
            hint: widget.hintAmount,
            icon: Icons.payments_outlined,
            enabled: !_isSubmitting,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
            ],
            suffix: Text(
              currencySymbol,
              style: AppTypography.body1.copyWith(
                color: AppColors.mutedText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          MinimalPickerField(
            label: t.dueDay,
            value: _selectedDueDay?.toString(),
            hint: t.selectDueDay,
            icon: Icons.event_outlined,
            enabled: !_isSubmitting && !_pickingDueDay,
            onTap: () => _pickDueDay(context),
          ),
          const SizedBox(height: AppSizes.spacingM),
          MinimalToggleRow(
            title: t.affectCurrentDues,
            subtitle: t.affectCurrentDuesHint,
            value: _affectCurrent,
            enabled: !_isSubmitting,
            onChanged: _isSubmitting
                ? null
                : (value) {
                    setState(() => _affectCurrent = value);
                    widget.onAffectCurrentChanged(value);
                  },
          ),
        ],
      ),
      actions: PremiumSheetActions(
        primaryLabel: t.update,
        onPrimary: _isSubmitting ? null : _handleSubmit,
        primaryLoading: _isSubmitting,
      ),
    );
  }
}
