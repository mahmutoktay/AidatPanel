import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../domain/entities/due_entity.dart';
import '../utils/dues_ui_helpers.dart';
import 'dues_screen_style.dart';

class ResidentDueListCard extends StatelessWidget {
  final DueEntity due;

  const ResidentDueListCard({
    super.key,
    required this.due,
  });

  String _currencySymbol(String currency) =>
      currency == 'TRY' ? '₺' : currency;

  @override
  Widget build(BuildContext context) {
    final visual = duesStatusVisual(context, due.status);
    final periodLabel =
        '${monthName(context, due.month)} ${due.year}';
    final subtitle = residentDueCardSubtitle(context, due);
    final amountText = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: _currencySymbol(due.currency),
      decimalDigits: 2,
    ).format(due.amount);
    final isPaid = due.status == DueStatus.paid;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
      child: Container(
        decoration: DuesScreenStyle.whiteCard(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingM,
          vertical: AppSizes.spacingS,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: visual.bg,
                    borderRadius:
                        BorderRadius.circular(DuesScreenStyle.iconBoxRadius),
                  ),
                  alignment: Alignment.center,
                  child: Icon(visual.icon, color: visual.fg, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        periodLabel,
                        style: AppTypography.body1.copyWith(
                          color: AppColors.inkDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.mutedText,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: visual.bg,
                    borderRadius:
                        BorderRadius.circular(DuesScreenStyle.chipRadius),
                  ),
                  child: Text(
                    visual.label,
                    style: AppTypography.caption.copyWith(
                      color: visual.fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingS),
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.lineLight,
            ),
            const SizedBox(height: AppSizes.spacingS),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    amountText,
                    style: AppTypography.h2.copyWith(
                      color: AppColors.inkDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingS),
                if (isPaid)
                  _SecondaryActionButton(
                    label: context.t.common.dekontShort,
                    onTap: () => context.push('/resident-dashboard/dekonts'),
                  )
                else
                  _PrimaryActionButton(
                    label: context.t.common.payShort,
                    onTap: () => context.push(
                      '/resident-dashboard/payment?dueId=${due.id}',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        minimumSize: const Size(0, AppSizes.buttonHeightSmall),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DuesScreenStyle.chipRadius),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.button.copyWith(
          color: AppColors.surface,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryActionButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: AppColors.fill,
        foregroundColor: AppColors.textSecondary,
        minimumSize: const Size(0, AppSizes.buttonHeightSmall),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DuesScreenStyle.chipRadius),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.button.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }
}
