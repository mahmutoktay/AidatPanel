import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/notifications/notification_toast.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/strings.g.dart';
import '../../../../dues/presentation/providers/dues_provider.dart';
import 'resident_home_actions_grid.dart';
import 'resident_home_colors.dart';
import 'resident_home_quick_icons.dart';

/// Sakin ana sayfa — mockup 5 birebir.
class ResidentHomeTab extends ConsumerWidget {
  const ResidentHomeTab({
    super.key,
    required this.onGoToDuesTab,
    required this.onGoToIssuesTab,
  });

  final VoidCallback onGoToDuesTab;
  final VoidCallback onGoToIssuesTab;

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      ref.read(duesNotifierProvider.notifier).loadMyDues(),
      pollAndShowNotificationToasts(ref),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
<<<<<<< HEAD
    final dues = ref.watch(duesNotifierProvider.select((state) => state.dues));
    final tickets = ref.watch(ticketsNotifierProvider).tickets;

    final pendingCount = dues
        .where((d) => d.status == DueStatus.pending)
        .length;
    final overdueCount = dues
        .where((d) => d.status == DueStatus.overdue)
        .length;
    final paidCount = dues.where((d) => d.status == DueStatus.paid).length;
    final openTicketCount = tickets
        .where(
          (t) =>
              t.status == TicketStatus.open ||
              t.status == TicketStatus.inProgress,
        )
        .length;

    final featuredDue = pickFeaturedDue(dues);
=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    final t = context.t.common;
    final dashT = context.t.features.dashboard;

    return ColoredBox(
      color: AppColors.surface,
      child: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        color: ResidentHomeColors.blue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSizes.screenBodyScrollPadding.copyWith(
            top: 0,
            bottom: AppSizes.spacingXL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResidentHomeTopShortcutCard(
                    label: t.debtAndPay,
                    icon: Icons.account_balance_wallet_rounded,
                    iconBackground: ResidentHomeColors.topOrange,
                    onTap: () => context.push('/resident-dashboard/payment'),
                  ),
                  const SizedBox(width: 10),
                  ResidentHomeTopShortcutCard(
                    label: t.duesStatus,
                    icon: Icons.warning_amber_rounded,
                    iconBackground: ResidentHomeColors.topRed,
                    onTap: onGoToDuesTab,
                  ),
                  const SizedBox(width: 10),
                  ResidentHomeTopShortcutCard(
                    label: t.myAnnouncements,
                    icon: Icons.check_rounded,
                    iconBackground: ResidentHomeColors.topGreen,
                    iconShape: BoxShape.circle,
                    onTap: () =>
                        context.push('/resident-dashboard/notifications'),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingL),
              Text(
                t.quickActions,
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                ),
              ),
              const SizedBox(height: AppSizes.spacingM),
              SizedBox(
                height: 228,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 11,
                      child: ResidentHomeFeaturedAction(
                        title: t.debtAndPay,
                        subtitle: dashT.residentDebtAndPaySubtitle,
                        onTap: () =>
                            context.push('/resident-dashboard/payment'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 12,
                      child: Column(
                        children: [
                          Expanded(
                            child: ResidentHomeSecondaryAction(
                              icon: Icons.description_outlined,
                              iconBackground:
                                  ResidentHomeColors.secondaryOrangeBg,
                              iconColor: ResidentHomeColors.topOrange,
                              label: t.accountSummary,
                              subtitle: t.accountSummarySubtitle,
                              onTap: onGoToDuesTab,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ResidentHomeSecondaryAction(
                              icon: Icons.receipt_long_outlined,
                              iconBackground: ResidentHomeColors.secondaryBlueBg,
                              iconColor: ResidentHomeColors.blue,
                              label: t.myReceipts,
                              subtitle: t.myReceiptsSubtitle,
                              onTap: () => context.push(
                                '/resident-dashboard/dekonts',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ResidentHomeSecondaryAction(
                              icon: Icons.request_page_outlined,
                              iconBackground: ResidentHomeColors.secondaryBlueBg,
                              iconColor: ResidentHomeColors.blue,
                              label: t.myPaymentRequest,
                              subtitle: t.myPaymentRequestSubtitle,
                              onTap: onGoToIssuesTab,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
