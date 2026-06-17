import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import 'dues_screen_style.dart';

class DuesQuickAmountCard extends StatelessWidget {
  final String amountText;
  final String currencySymbol;
  final VoidCallback onTap;

  const DuesQuickAmountCard({
    super.key,
    required this.amountText,
    required this.currencySymbol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DuesScreenStyle.cardRadius),
        child: Ink(
          decoration: DuesScreenStyle.whiteCard(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingM,
              vertical: 14,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.dashboardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.inkDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.t.common.updateDueAmount,
                    style: AppTypography.body1.copyWith(
                      color: AppColors.inkDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  amountText,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColors.mutedText.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Aidat tutarı güncelleme alt sayfası.
class DuesAmountUpdateSheet extends StatefulWidget {
  final TextEditingController amountController;
  final int? selectedDueDay;
  final bool affectCurrent;
  final bool isLoading;
  final String? hintAmount;
  final ValueChanged<int?> onDueDayChanged;
  final ValueChanged<bool> onAffectCurrentChanged;
  final VoidCallback onSubmit;

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
    required VoidCallback onSubmit,
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

  Future<void> _pickDueDay(BuildContext context) async {
    if (widget.isLoading || _pickingDueDay) return;
    setState(() => _pickingDueDay = true);
    final t = context.t.common;
    const clearSentinel = -1;
    try {
      final picked = await PremiumBottomSheetScaffold.show<int>(
        context: context,
        builder: (ctx) => PremiumBottomSheetScaffold(
          title: t.dueDay,
          scrollable: true,
          body: PremiumActionSheetList(
            children: [
              PremiumActionSheetTile(
                icon: Icons.event_busy_outlined,
                label: t.selectDueDay,
                trailing: widget.selectedDueDay == null
                    ? const Icon(Icons.check_rounded, color: AppColors.inkDark)
                    : null,
                onTap: () => Navigator.pop(ctx, clearSentinel),
              ),
              for (var day = 1; day <= 28; day++)
                PremiumActionSheetTile(
                  icon: Icons.calendar_today_outlined,
                  label: '$day',
                  trailing: widget.selectedDueDay == day
                      ? const Icon(Icons.check_rounded, color: AppColors.inkDark)
                      : null,
                  onTap: () => Navigator.pop(ctx, day),
                ),
            ],
          ),
        ),
      );
      if (picked == null) return;
      widget.onDueDayChanged(picked == clearSentinel ? null : picked);
    } finally {
      if (mounted) setState(() => _pickingDueDay = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol =
        LocaleSettings.currentLocale == AppLocale.tr ? '₺' : r'$';
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
            enabled: !widget.isLoading,
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
            value: widget.selectedDueDay?.toString(),
            hint: t.selectDueDay,
            icon: Icons.event_outlined,
            enabled: !widget.isLoading && !_pickingDueDay,
            onTap: () => _pickDueDay(context),
          ),
          const SizedBox(height: AppSizes.spacingM),
          MinimalToggleRow(
            title: t.affectCurrentDues,
            subtitle: t.affectCurrentDuesHint,
            value: widget.affectCurrent,
            enabled: !widget.isLoading,
            onChanged: widget.isLoading ? null : widget.onAffectCurrentChanged,
          ),
        ],
      ),
      actions: PremiumSheetActions(
        primaryLabel: t.update,
        onPrimary: widget.isLoading ? null : widget.onSubmit,
        primaryLoading: widget.isLoading,
      ),
    );
  }
}
