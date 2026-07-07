import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/strings.g.dart';

/// Sakin ana sayfa — Aidat Durumu ve Taleplerim hızlı işlemleri.
class ResidentHomeQuickActionsRow extends StatelessWidget {
  const ResidentHomeQuickActionsRow({
    super.key,
    required this.onGoToDuesTab,
    required this.onGoToIssuesTab,
  });

  final VoidCallback onGoToDuesTab;
  final VoidCallback onGoToIssuesTab;

  @override
  Widget build(BuildContext context) {
    final common = context.t.common;
    final ticketsT = context.t.features.tickets;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _QuickActionTile(
                icon: Icons.account_balance_wallet_outlined,
                label: common.duesStatus,
                onTap: onGoToDuesTab,
              ),
            ),
            Container(
              width: 1,
              color: AppColors.border.withValues(alpha: 0.45),
            ),
            Expanded(
              child: _QuickActionTile(
                icon: Icons.support_agent_outlined,
                label: ticketsT.myTickets,
                onTap: onGoToIssuesTab,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingM,
            vertical: AppSizes.spacingXS,
          ),
          leading: Icon(icon, color: AppColors.primary, size: 24),
          title: Text(
            label,
            style: AppTypography.body2.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          minVerticalPadding: 0,
          minLeadingWidth: 28,
        ),
      ),
    );
  }
}
