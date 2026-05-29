import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/platform/system_navigator_bridge.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/notification_icon_button.dart';
import '../../../../shared/widgets/settings_tab.dart';
import '../../../../shared/widgets/tint_dashboard_tile.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../../../dues/presentation/screens/resident_dues_tab.dart';
import '../../../tickets/domain/entities/ticket_entity.dart';
import '../../../tickets/presentation/providers/tickets_provider.dart';
import '../../../tickets/presentation/screens/resident_tickets_tab.dart';

class ResidentDashboardScreen extends ConsumerStatefulWidget {
  const ResidentDashboardScreen({super.key});

  @override
  ConsumerState<ResidentDashboardScreen> createState() =>
      _ResidentDashboardScreenState();
}

class _ResidentDashboardScreenState
    extends ConsumerState<ResidentDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _requestedInitialDues = false;
  bool _requestedInitialTickets = false;

  @override
  void initState() {
    super.initState();
    final initialIndex = ref.read(residentTabIndexProvider);
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(() {
      ref.read(residentTabIndexProvider.notifier).state = _tabController.index;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      prefetchNotifications(ref);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_requestedInitialDues) {
      _requestedInitialDues = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(duesNotifierProvider.notifier).loadMyDues();
      });
    }
    if (!_requestedInitialTickets) {
      _requestedInitialTickets = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(ticketsNotifierProvider.notifier).loadMyTickets();
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await SystemNavigatorBridge.moveAppToBackground();
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: Text(context.t.features.apartments.residentPanel),
          centerTitle: true,
          actions: const [NotificationIconButton()],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildHomeTab(),
            _buildDuesTab(),
            _buildIssuesTab(),
            _buildSettingsTab(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: context.t.common.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_outlined),
              selectedIcon: const Icon(Icons.receipt),
              label: context.t.common.dues,
            ),
            NavigationDestination(
              icon: const Icon(Icons.warning_amber_outlined),
              selectedIcon: const Icon(Icons.warning_amber_rounded),
              label: context.t.common.issues,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: context.t.common.settings,
            ),
          ],
          selectedIndex: ref.watch(residentTabIndexProvider),
          onDestinationSelected: (index) {
            ref.read(residentTabIndexProvider.notifier).state = index;
            _tabController.animateTo(index);
          },
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    final authState = ref.watch(authStateProvider);
    final dues = ref.watch(duesNotifierProvider).dues;
    final tickets = ref.watch(ticketsNotifierProvider).tickets;
    final userName = authState.user?.name ?? context.t.common.user;
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

    return RefreshIndicator(
      onRefresh: _refreshHomeTab,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSizes.screenBodyScrollPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ResidentHeroSummaryCard(
              userName: userName,
              pendingCount: pendingCount,
              overdueCount: overdueCount,
              paidCount: paidCount,
            ),
            const SizedBox(height: AppSizes.spacingM),
            _ResidentQuickActionsRow(
              pendingCount: pendingCount,
              billsCount: dues.length,
              openTicketCount: openTicketCount,
              onDues: _goToDuesTab,
              onBills: _goToDuesTab,
              onSupport: _goToIssuesTab,
            ),
            const SizedBox(height: AppSizes.spacingL),
            Text(
              context.t.common.recentTransactions,
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            _buildTransactionHistory(),
          ],
        ),
      ),
    );
  }

  void _goToDuesTab() {
    ref.read(residentTabIndexProvider.notifier).state = 1;
    _tabController.animateTo(1);
  }

  void _goToIssuesTab() {
    ref.read(residentTabIndexProvider.notifier).state = 2;
    _tabController.animateTo(2);
  }

  Future<void> _refreshHomeTab() async {
    await Future.wait([
      ref.read(duesNotifierProvider.notifier).loadMyDues(),
      ref.read(ticketsNotifierProvider.notifier).loadMyTickets(),
    ]);
  }

  Widget _buildDuesTab() {
    return const ResidentDuesTab();
  }

  Widget _buildIssuesTab() {
    return const ResidentTicketsTab();
  }

  Widget _buildSettingsTab() {
    return const SettingsTab();
  }

  Widget _buildTransactionHistory() {
    final transactions = <Map<String, String>>[];

    if (transactions.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        title: context.t.common.recentTransactions,
        subtitle: context.t.common.comingSoon,
      );
    }

    return Column(
      children: transactions
          .map(
            (tx) => Container(
              margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
              padding: const EdgeInsets.all(AppSizes.spacingM),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx['type']!,
                        style: AppTypography.h4.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingXS),
                      Text(
                        tx['date']!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        tx['amount']!,
                        style: AppTypography.h4.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingXS),
                      Text(
                        tx['status']!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

/// Yönetici ana sayfadaki `_HeroSummaryCard` ile aynı düzen.
class _ResidentHeroSummaryCard extends StatelessWidget {
  final String userName;
  final int pendingCount;
  final int overdueCount;
  final int paidCount;

  const _ResidentHeroSummaryCard({
    required this.userName,
    required this.pendingCount,
    required this.overdueCount,
    required this.paidCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${context.t.common.welcome}, ',
                style: AppTypography.body1.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: userName,
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSizes.spacingM),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TintDashboardTile(
                  icon: Icons.pending_outlined,
                  value: pendingCount.toString(),
                  label: context.t.common.pendingStatus,
                  tint: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: TintDashboardTile(
                  icon: Icons.warning_amber_rounded,
                  value: overdueCount.toString(),
                  label: context.t.common.overdueStatus,
                  tint: AppColors.error,
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: TintDashboardTile(
                  icon: Icons.check_circle_outline,
                  value: paidCount.toString(),
                  label: context.t.common.paidStatus,
                  tint: AppColors.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Yönetici `_ManagerQuickActionsRow` ile aynı kutu stili ve düzen.
class _ResidentQuickActionsRow extends StatelessWidget {
  final int pendingCount;
  final int billsCount;
  final int openTicketCount;
  final VoidCallback onDues;
  final VoidCallback onBills;
  final VoidCallback onSupport;

  const _ResidentQuickActionsRow({
    required this.pendingCount,
    required this.billsCount,
    required this.openTicketCount,
    required this.onDues,
    required this.onBills,
    required this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.common;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TintDashboardTile(
              icon: Icons.payment_outlined,
              value: pendingCount.toString(),
              label: t.makePayment,
              tint: AppColors.primary,
              onTap: onDues,
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: TintDashboardTile(
              icon: Icons.receipt_outlined,
              value: billsCount.toString(),
              label: t.bills,
              tint: AppColors.accent,
              onTap: onBills,
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: TintDashboardTile(
              icon: Icons.support_agent_outlined,
              value: openTicketCount.toString(),
              label: t.support,
              tint: AppColors.primaryLight,
              onTap: onSupport,
            ),
          ),
        ],
      ),
    );
  }
}
