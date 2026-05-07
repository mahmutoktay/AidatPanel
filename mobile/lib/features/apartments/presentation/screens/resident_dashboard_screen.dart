import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/settings_tab.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      ref.read(residentTabIndexProvider.notifier).state = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.features.apartments.residentPanel),
        centerTitle: true,
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
    );
  }

  Widget _buildHomeTab() {
    final authState = ref.watch(authStateProvider);
    final userName = authState.user?.name ?? context.t.common.user;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${context.t.common.welcome}, $userName',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingL),
          _buildQuickActionsRow(),
          const SizedBox(height: AppSizes.spacingL),
          Text(
            context.t.common.recentTransactions,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          _buildTransactionHistory(),
        ],
      ),
    );
  }

  Widget _buildDuesTab() {
    return Center(
      child: Text(
        context.t.common.duesTab,
        style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildIssuesTab() {
    return Center(
      child: Text(
        context.t.common.issuesTab,
        style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return const SettingsTab();
  }

  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.payment_outlined,
            label: context.t.common.makePayment,
            onTap: () {},
          ),
        ),
        const SizedBox(width: AppSizes.spacingM),
        Expanded(
          child: _buildActionButton(
            icon: Icons.receipt_outlined,
            label: context.t.common.bills,
            onTap: () {},
          ),
        ),
        const SizedBox(width: AppSizes.spacingM),
        Expanded(
          child: _buildActionButton(
            icon: Icons.help_outline,
            label: context.t.common.support,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: AppSizes.spacingS),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    // TODO: Backend API'den işlem geçmişini çek
    // Şimdilik: Boş liste göster
    final transactions = <Map<String, String>>[];

    return Column(
      children: transactions
          .map(
            (tx) => Container(
              margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
              padding: const EdgeInsets.all(AppSizes.spacingM),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
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
