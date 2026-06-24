import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../expenses/presentation/utils/expense_labels.dart';
import '../../domain/entities/site_expense_entity.dart';

class SiteExpenseListItemCard extends StatelessWidget {
  const SiteExpenseListItemCard({
    super.key,
    required this.expense,
    this.onEdit,
    this.onDelete,
  });

  final SiteExpenseEntity expense;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

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
          ),
        ),
      ),
    );
  }
}
