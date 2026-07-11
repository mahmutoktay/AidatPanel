import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/strings.g.dart';

/// Sakin ana sayfa — aidat, gider, ödeme, dekont ve talep hızlı işlemleri.
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
    final expensesT = context.t.features.expenses;
    final dekontT = context.t.features.dekont;
    final ticketsT = context.t.features.tickets;

    final actions = <_QuickActionSpec>[
      _QuickActionSpec(
        icon: Icons.account_balance_wallet_outlined,
        label: common.duesStatus,
        onTap: onGoToDuesTab,
      ),
      _QuickActionSpec(
        icon: Icons.receipt_long_outlined,
        label: expensesT.quickActionLabel,
        onTap: () => context.push('/resident-dashboard/expenses'),
      ),
      _QuickActionSpec(
        icon: Icons.payments_outlined,
        label: common.makePayment,
        onTap: () => context.push('/resident-dashboard/payment'),
      ),
      _QuickActionSpec(
        icon: Icons.fact_check_outlined,
        label: dekontT.myDekontsTitle,
        onTap: () => context.push('/resident-dashboard/dekonts'),
      ),
      _QuickActionSpec(
        icon: Icons.support_agent_outlined,
        label: ticketsT.myTickets,
        onTap: onGoToIssuesTab,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          for (var row = 0; row < actions.length; row += 2) ...[
            if (row > 0)
              Container(
                height: 1,
                color: AppColors.border.withValues(alpha: 0.45),
              ),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: _QuickActionTile(spec: actions[row])),
                  if (row + 1 < actions.length) ...[
                    Container(
                      width: 1,
                      color: AppColors.border.withValues(alpha: 0.45),
                    ),
                    Expanded(child: _QuickActionTile(spec: actions[row + 1])),
                  ] else
                    const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionSpec {
  const _QuickActionSpec({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.spec});

  final _QuickActionSpec spec;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: spec.onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingM,
            vertical: AppSizes.spacingXS,
          ),
          leading: Icon(spec.icon, color: AppColors.primary, size: 24),
          title: Text(
            spec.label,
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
