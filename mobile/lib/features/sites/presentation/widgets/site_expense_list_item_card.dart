import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
<<<<<<< HEAD
=======
import '../../../../core/utils/app_currency_format.dart';
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../expenses/presentation/utils/expense_labels.dart';
import '../../domain/entities/site_expense_entity.dart';

class SiteExpenseListItemCard extends StatelessWidget {
<<<<<<< HEAD
=======
  final SiteExpenseEntity expense;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  const SiteExpenseListItemCard({
    super.key,
    required this.expense,
    this.onEdit,
    this.onDelete,
  });

<<<<<<< HEAD
  final SiteExpenseEntity expense;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
<<<<<<< HEAD
    final categoryColor = AppColors.primary;
    final showMenu = onEdit != null || onDelete != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEdit,
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
                      if (expense.perUnitAmount != null) ...[
                        const SizedBox(height: AppSizes.spacingXS),
                        Text(
                          context.t.features.sites.perUnitShare.replaceAll(
                            '{amount}',
                            expense.perUnitAmount!.toStringAsFixed(2),
                          ),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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
                        '${expense.amount?.toStringAsFixed(2) ?? '0.00'} ₺',
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showMenu)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: AppColors.textDisabled,
                    ),
                    onSelected: (v) {
                      if (v == 'edit') onEdit?.call();
                      if (v == 'delete') onDelete?.call();
                    },
                    itemBuilder: (ctx) => [
                      if (onEdit != null)
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(context.t.features.expenses.editAction),
                        ),
                      if (onDelete != null)
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(context.t.features.expenses.deleteAction),
                        ),
                    ],
                  ),
              ],
            ),
=======
    final amount = expense.amount ?? 0;
    final perUnit = expense.perUnitAmount;

    return Material(
      color: Colors.transparent,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppCurrencyFormat.format(amount),
                    style: AppTypography.h4.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                          case 'delete':
                            onDelete?.call();
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(context.t.common.edit),
                          ),
                        if (onDelete != null)
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(context.t.common.delete),
                          ),
                      ],
                    ),
                ],
              ),
            ],
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
          ),
        ),
      ),
    );
  }
}
