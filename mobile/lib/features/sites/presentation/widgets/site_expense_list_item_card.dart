import 'package:flutter/material.dart';

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

  const SiteExpenseListItemCard({
    super.key,
    required this.expense,
    this.onEdit,
    this.onDelete,
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
          ),
        ),
      ),
    );
  }
}
