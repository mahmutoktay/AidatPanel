import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/strings.g.dart';

/// Sakin ana sayfa — aidat, talep, gider ve duyuru hızlı işlemleri (2×2 ayrık kartlar).
class ResidentHomeQuickActionsRow extends StatelessWidget {
  const ResidentHomeQuickActionsRow({
    super.key,
    required this.hasApartment,
    required this.onJoinBuilding,
    required this.onGoToDuesTab,
    required this.onGoToIssuesTab,
  });

  final bool hasApartment;
  final VoidCallback onJoinBuilding;
  final VoidCallback onGoToDuesTab;
  final VoidCallback onGoToIssuesTab;

  void _guardApartment(VoidCallback action) {
    if (hasApartment) {
      action();
      return;
    }
    onJoinBuilding();
  }

  @override
  Widget build(BuildContext context) {
    final common = context.t.common;
    final expensesT = context.t.features.expenses;
    final ticketsT = context.t.features.tickets;

    final actions = <_QuickActionSpec>[
      _QuickActionSpec(
        icon: Icons.account_balance_wallet_outlined,
        label: common.duesStatus,
        iconBg: AppColors.infoBg,
        iconColor: AppColors.chartBlue,
        onTap: () => _guardApartment(onGoToDuesTab),
      ),
      _QuickActionSpec(
        icon: Icons.support_agent_outlined,
        label: ticketsT.myTickets,
        iconBg: AppColors.expenseAccentBg,
        iconColor: AppColors.expenseAccent,
        onTap: () => _guardApartment(onGoToIssuesTab),
      ),
      _QuickActionSpec(
        icon: Icons.receipt_long_outlined,
        label: expensesT.quickActionLabel,
        iconBg: AppColors.warningBg,
        iconColor: AppColors.chartYellow,
        onTap: () => _guardApartment(
          () => context.push('/resident-dashboard/expenses'),
        ),
      ),
      _QuickActionSpec(
        icon: Icons.campaign_outlined,
        label: common.announcements,
        iconBg: AppColors.successBg,
        iconColor: AppColors.chartGreen,
        onTap: () => _guardApartment(
          () => context.push('/resident-dashboard/announcements'),
        ),
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _QuickActionTile(spec: actions[0])),
            const SizedBox(width: AppSizes.spacingS),
            Expanded(child: _QuickActionTile(spec: actions[1])),
          ],
        ),
        const SizedBox(height: AppSizes.spacingS),
        Row(
          children: [
            Expanded(child: _QuickActionTile(spec: actions[2])),
            const SizedBox(width: AppSizes.spacingS),
            Expanded(child: _QuickActionTile(spec: actions[3])),
          ],
        ),
      ],
    );
  }
}

class _QuickActionSpec {
  const _QuickActionSpec({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.spec});

  final _QuickActionSpec spec;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: spec.onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.45),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingM,
              vertical: AppSizes.spacingXS,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: spec.iconBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(spec.icon, color: spec.iconColor, size: 22),
            ),
            title: Text(
              spec.label,
              style: AppTypography.body2.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            minVerticalPadding: 0,
            minLeadingWidth: 40,
          ),
        ),
      ),
    );
  }
}
