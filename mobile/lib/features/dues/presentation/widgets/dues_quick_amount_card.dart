import 'package:flutter/material.dart';

import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/app_select_field.dart';
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
class DuesAmountUpdateSheet extends StatelessWidget {
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
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.surface,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: DuesAmountUpdateSheet(
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol =
        LocaleSettings.currentLocale == AppLocale.tr ? '₺' : r'$';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.spacingM,
          AppSizes.spacingS,
          AppSizes.spacingM,
          AppSizes.spacingM,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lineLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              context.t.common.updateDueAmount,
              style: AppTypography.h3.copyWith(
                color: AppColors.inkDark,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: context.t.common.amount,
                prefixText: '$currencySymbol ',
                hintText: hintAmount,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingS),
            AppSelectField<int?>(
              label: context.t.common.dueDay,
              value: selectedDueDay,
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
              onChanged: isLoading ? null : onDueDayChanged,
            ),
            const SizedBox(height: AppSizes.spacingS),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: affectCurrent,
              onChanged: isLoading ? null : onAffectCurrentChanged,
              title: Text(
                context.t.common.affectCurrentDues,
                style: AppTypography.body1.copyWith(color: AppColors.inkDark),
              ),
              subtitle: Text(
                context.t.common.affectCurrentDuesHint,
                style: AppTypography.caption.copyWith(
                  color: AppColors.mutedText,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            SizedBox(
              height: AppSizes.buttonHeightSecondary,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                style: AppButtonStyles.elevatedPrimary(),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.t.common.update),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
