import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../domain/entities/expense_entity.dart';
import '../utils/expense_labels.dart';

class ExpenseListItemCard extends StatelessWidget {
  final ExpenseEntity expense;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ExpenseListItemCard({
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
    final categoryColor = AppColors.brand;
    final canSwipe = onEdit != null || onDelete != null;

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ??
            () => context.push('/expenses/${expense.id}', extra: expense),
        borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
        child: Ink(
          decoration: DashboardScreenStyle.whiteCard().copyWith(
            border: Border.all(
              color: categoryColor.withValues(alpha: 0.12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.cardPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _categoryIcon(expense.category),
                    color: categoryColor,
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
                        style: AppTypography.h4.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingXS),
                      Text(
                        '${expense.category.label(context)} · $date',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (expense.note != null && expense.note!.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.spacingS),
                        Text(
                          expense.note!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body2.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSizes.spacingS),
                      Text(
                        expense.amount != null
                            ? '${expense.amount!.toStringAsFixed(2)} ₺'
                            : context.t.features.expenses.amountPending,
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (expense.parsedAmount != null &&
                          expense.parsedAmount != expense.amount)
                        Text(
                          '(OCR: ${expense.parsedAmount!.toStringAsFixed(2)} ₺)',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.brand,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!canSwipe) return card;

    final t = context.t.features.expenses;
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
              label: t.editAction,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
          if (onDelete != null)
            SlidableAction(
              onPressed: (_) => onDelete!(),
              backgroundColor: AppColors.statusRed,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
              label: t.deleteAction,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
        ],
      ),
      child: card,
    );
  }
}
