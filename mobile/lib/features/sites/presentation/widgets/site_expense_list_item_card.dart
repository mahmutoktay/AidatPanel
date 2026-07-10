import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_currency_format.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../expenses/presentation/utils/expense_labels.dart';
import '../../domain/entities/site_expense_entity.dart';

class SiteExpenseListItemCard extends StatelessWidget {
  final SiteExpenseEntity expense;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const SiteExpenseListItemCard({
    super.key,
    required this.expense,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  IconData _categoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.cleaning:
        return Icons.cleaning_services_outlined;
      case ExpenseCategory.elevator:
        return Icons.elevator_outlined;
      case ExpenseCategory.electricity:
        return Icons.bolt_outlined;
      case ExpenseCategory.water:
        return Icons.water_drop_outlined;
      case ExpenseCategory.insurance:
        return Icons.shield_outlined;
      case ExpenseCategory.repair:
        return Icons.build_outlined;
      case ExpenseCategory.garden:
        return Icons.yard_outlined;
      case ExpenseCategory.other:
        return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final date =
        '${expense.date.day}.${expense.date.month}.${expense.date.year}';
    final amount = expense.amount ?? 0;
    final perUnit = expense.perUnitAmount;
    final canSwipe = onEdit != null || onDelete != null;

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
        child: Ink(
          decoration: DashboardScreenStyle.whiteCard(),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.cardPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _categoryIcon(expense.category),
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${expense.category.label(context)} · $date',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                      if (perUnit != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          context.t.features.sites.perUnitShare.replaceAll(
                            '{amount}',
                            AppCurrencyFormat.format(perUnit),
                          ),
                          style: AppTypography.label.copyWith(
                            color: AppColors.statusBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  AppCurrencyFormat.format(amount),
                  style: AppTypography.h4.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!canSwipe) return card;

    return Slidable(
      key: ValueKey<String>(expense.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: onEdit != null && onDelete != null ? 0.5 : 0.34,
        children: [
          if (onEdit != null)
            SlidableAction(
              onPressed: (_) => onEdit!(),
              backgroundColor: AppColors.statusBlue,
              foregroundColor: Colors.white,
              icon: Icons.edit_outlined,
              label: context.t.common.edit,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
          if (onDelete != null)
            SlidableAction(
              onPressed: (_) => onDelete!(),
              backgroundColor: AppColors.statusRed,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
              label: context.t.common.delete,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
        ],
      ),
      child: card,
    );
  }
}
