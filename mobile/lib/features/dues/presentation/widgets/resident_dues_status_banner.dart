import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_currency_format.dart';
import '../../../../l10n/strings.g.dart';
import '../../domain/entities/due_entity.dart';
import '../../domain/resident_debt_summary.dart';

/// İnce durum satırı — Ana Sayfa hero kartının kopyası değil.
class ResidentDuesStatusBanner extends StatelessWidget {
  const ResidentDuesStatusBanner({
    super.key,
    required this.dues,
  });

  final List<DueEntity> dues;

  @override
  Widget build(BuildContext context) {
    final r = context.t.features.dues.resident;
    final hasDebt = hasOutstandingDebt(dues);

    if (!hasDebt) {
      return _BannerShell(
        background: AppColors.statusGreenBg,
        foreground: AppColors.statusGreen,
        icon: Icons.check_circle_outline_rounded,
        message: r.duesUpToDate,
      );
    }

    final overdueCount = overdueDueCount(dues);
    final pendingCount = pendingDueCount(dues);
    final amount = AppCurrencyFormat.format(totalOutstandingAmount(dues));

    final String message;
    if (overdueCount > 0) {
      message = r.debtBannerOverdue
          .replaceAll('{count}', '$overdueCount')
          .replaceAll('{amount}', amount);
    } else {
      message = r.debtBannerPending
          .replaceAll('{count}', '$pendingCount')
          .replaceAll('{amount}', amount);
    }

    return _BannerShell(
      background: AppColors.statusRedBg,
      foreground: AppColors.statusRed,
      icon: Icons.warning_amber_rounded,
      message: message,
    );
  }
}

class _BannerShell extends StatelessWidget {
  const _BannerShell({
    required this.background,
    required this.foreground,
    required this.icon,
    required this.message,
  });

  final Color background;
  final Color foreground;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingS,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body2.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
