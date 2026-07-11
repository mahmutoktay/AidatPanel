import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_currency_format.dart';
import '../../../../l10n/strings.g.dart';
import '../../domain/entities/due_entity.dart';
import '../utils/dues_ui_helpers.dart';

/// Defter tarzı aidat dönem satırı — kart değil, ince ayraçlı liste satırı.
class ResidentDueLedgerRow extends StatelessWidget {
  const ResidentDueLedgerRow({
    super.key,
    required this.due,
    this.showDivider = true,
  });

  final DueEntity due;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final visual = residentDueLedgerStatusVisual(context, due.status);
    final periodLabel = '${monthName(context, due.month)} ${due.year}';
    final subtitle = residentDueLedgerSubtitle(context, due);
    final amountText = AppCurrencyFormat.format(
      due.hasRemainingBalance ? due.remainingAmount : due.amount,
    );
    final canPay =
        due.status == DueStatus.pending || due.status == DueStatus.overdue;
    final subtitleColor = due.status == DueStatus.overdue
        ? AppColors.statusRed
        : AppColors.mutedText;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      periodLabel,
                      style: AppTypography.body1.copyWith(
                        color: AppColors.inkDark,
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.body2.copyWith(
                        color: subtitleColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountText,
                    style: AppTypography.body1.copyWith(
                      color: AppColors.inkDark,
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: visual.bg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      visual.label,
                      style: AppTypography.caption.copyWith(
                        color: visual.fg,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (canPay) ...[
                    const SizedBox(height: 4),
                    _PayLink(
                      onTap: () => context.push(
                        '/resident-dashboard/payment?dueId=${due.id}',
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: AppColors.border.withValues(alpha: 0.55),
          ),
      ],
    );
  }
}

class _PayLink extends StatelessWidget {
  const _PayLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.actionButton,
          minimumSize: const Size(44, 44),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: Text(
          context.t.common.payShort,
          style: AppTypography.button.copyWith(
            color: AppColors.actionButton,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
