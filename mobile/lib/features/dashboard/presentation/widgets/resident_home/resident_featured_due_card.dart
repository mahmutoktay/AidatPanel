import 'package:flutter/material.dart';
import '../../../../../core/utils/app_currency_format.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/strings.g.dart';
import '../../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../dues/domain/entities/due_entity.dart';
import '../../../../dues/presentation/utils/dues_ui_helpers.dart';

/// Öne çıkan aidat kartı — koyu zemin, tutar, CTA (mockup stili).
class ResidentFeaturedDueCard extends StatelessWidget {
  final DueEntity due;
  final int overdueCount;
  final VoidCallback onPay;

  const ResidentFeaturedDueCard({
    super.key,
    required this.due,
    required this.overdueCount,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final dashT = t.features.dashboard;
    final amountText = AppCurrencyFormat.format(due.amount);

    final periodLabel = dashT.featuredDuePeriod
        .replaceAll('{month}', monthName(context, due.month))
        .replaceAll('{year}', '${due.year}');

    String? dueDateSuffix;
    if (due.dueDate != null) {
      dueDateSuffix = t.common.dueMetaPendingDueDate
          .replaceAll('{day}', '${due.dueDate!.day}')
          .replaceAll('{month}', monthName(context, due.dueDate!.month));
    }

    final subtitle = dueDateSuffix != null
        ? '$periodLabel · $dueDateSuffix'
        : periodLabel;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
<<<<<<< HEAD
        color: AppColors.heroCardBackground,
=======
        color: AppColors.darkCard,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
        boxShadow: DashboardScreenStyle.cardShadow,
      ),
      padding: const EdgeInsets.all(AppSizes.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (overdueCount > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
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
                      dashT.overduePaymentsBadge.replaceAll(
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
          if (overdueCount > 0) const SizedBox(height: AppSizes.spacingM),
          Text(
            amountText,
            style: AppTypography.h1.copyWith(
<<<<<<< HEAD
              color: AppColors.heroCardTitle,
=======
              color: Colors.white,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
              fontWeight: FontWeight.w800,
              fontSize: 36,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppSizes.spacingXS),
          Text(
            subtitle,
            style: AppTypography.body2.copyWith(
<<<<<<< HEAD
              color: AppColors.heroCardSubtitle,
=======
              color: Colors.white.withValues(alpha: 0.72),
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          SizedBox(
            height: AppSizes.buttonHeightSmall,
            child: FilledButton(
              onPressed: onPay,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.darkCard,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    DashboardScreenStyle.pillRadius,
                  ),
                ),
              ),
              child: Text(
                dashT.payNow,
                style: AppTypography.button.copyWith(
                  color: AppColors.darkCard,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

DueEntity? pickFeaturedDue(List<DueEntity> dues) {
  final overdue = dues.where((d) => d.status == DueStatus.overdue).toList();
  if (overdue.isNotEmpty) {
    overdue.sort((a, b) => b.overdueDays.compareTo(a.overdueDays));
    return overdue.first;
  }

  final pending = dues.where((d) => d.status == DueStatus.pending).toList();
  if (pending.isNotEmpty) {
    pending.sort((a, b) {
      final aDate = a.dueDate;
      final bDate = b.dueDate;
      if (aDate != null && bDate != null) {
        return aDate.compareTo(bDate);
      }
      if (a.year != b.year) return a.year.compareTo(b.year);
      return a.month.compareTo(b.month);
    });
    return pending.first;
  }

  return null;
}
