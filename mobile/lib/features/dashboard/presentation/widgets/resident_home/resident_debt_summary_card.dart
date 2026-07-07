import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/utils/app_currency_format.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/strings.g.dart';
import '../../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../dues/domain/entities/due_entity.dart';
import '../../../../dues/domain/resident_debt_summary.dart';
import '../../../../dues/presentation/utils/dues_ui_helpers.dart';

/// Sakin ana sayfa borç özeti — tek kart, tekrarsız ödeme girişi.
class ResidentDebtSummaryCard extends StatelessWidget {
  const ResidentDebtSummaryCard({
    super.key,
    required this.dues,
    required this.isLoading,
  });

  final List<DueEntity> dues;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading && dues.isEmpty) {
      return const _CardShell(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.spacingXL),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (!hasOutstandingDebt(dues)) {
      return _CardShell(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingM,
            vertical: AppSizes.spacingL,
          ),
          child: Text(
            context.t.common.noCurrentDebt,
            textAlign: TextAlign.center,
            style: AppTypography.body1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final featuredDue = pickFeaturedDue(dues);
    final total = totalOutstandingAmount(dues);
    final overdueCount = overdueDueCount(dues);
    final t = context.t;
    final dashT = t.features.dashboard;
    final amountText = AppCurrencyFormat.format(total);

    String? periodLabel;
    if (featuredDue != null) {
      periodLabel = dashT.residentFeaturedDuePeriod
          .replaceAll('{month}', monthName(context, featuredDue.month))
          .replaceAll('{year}', '${featuredDue.year}');
      if (overdueCount > 1) {
        periodLabel =
            '$periodLabel · ${dashT.residentOverduePaymentsBadge.replaceAll('{count}', '$overdueCount')}';
      }
    }

    return _CardShell(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (overdueCount > 0 && featuredDue != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.statusRed,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dashT.residentOverduePaymentsBadge.replaceAll(
                          '{count}',
                          '$overdueCount',
                        ),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.statusRed,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacingM),
            ],
            Text(
              amountText,
              style: AppTypography.h1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 34,
                height: 1.1,
              ),
            ),
            if (periodLabel != null) ...[
              const SizedBox(height: AppSizes.spacingXS),
              Text(
                periodLabel,
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: AppSizes.spacingM),
            SizedBox(
              height: AppSizes.buttonHeightPrimary,
              child: FilledButton(
                onPressed: featuredDue == null
                    ? null
                    : () => context.push(
                          '/resident-dashboard/payment?dueId=${featuredDue.id}',
                        ),
                child: Text(context.t.common.payDue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
        boxShadow: DashboardScreenStyle.cardShadow,
      ),
      child: child,
    );
  }
}
