import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/app_back_navigation.dart';
import '../../../../core/navigation/dashboard_back_handler.dart';
import '../../../../core/providers/theme_mode_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/widgets/dashboard/dashboard_bottom_nav_bar.dart';
import '../../../../shared/widgets/dashboard/dashboard_welcome_header.dart';
import '../../../../shared/widgets/notification_icon_button.dart';
import '../../../../shared/widgets/settings_tab.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../../../dues/presentation/screens/resident_dues_tab.dart';
import '../../../tickets/presentation/providers/tickets_provider.dart';
import '../../../tickets/presentation/screens/resident_tickets_tab.dart';
import '../widgets/resident_home/resident_home_colors.dart';
import '../widgets/resident_home/resident_home_tab.dart';

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
      if (_tabController.indexIsChanging) return;
      ref.read(residentTabIndexProvider.notifier).update(_tabController.index);
      prefetchNotifications(ref);
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

  void _goToDuesTab() {
    ref.read(residentTabIndexProvider.notifier).update(1);
    _tabController.animateTo(
      1,
      duration: DashboardNavAnimation.duration,
      curve: DashboardNavAnimation.curve,
    );
  }

  void _goToIssuesTab() {
    ref.read(residentTabIndexProvider.notifier).update(2);
    _tabController.animateTo(
      2,
      duration: DashboardNavAnimation.duration,
      curve: DashboardNavAnimation.curve,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tema değişiminde tüm dashboard iskeletinin rebuild olması için watch
    ref.watch(themeModeProvider);

    ref.listen<int>(residentTabIndexProvider, (previous, next) {
      if (_tabController.index != next) {
        _tabController.animateTo(
          next,
          duration: DashboardNavAnimation.duration,
          curve: DashboardNavAnimation.curve,
        );
      }
    });

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

    final selectedTab = ref.watch(residentTabIndexProvider);
    final t = context.t.common;
    final userName =
        ref.watch(authStateProvider.select((state) => state.user?.name)) ??
        context.t.common.user;
    final isSettings = selectedTab == 3;
    final title = switch (selectedTab) {
      3 => t.mySettings,
      2 => t.issues,
      1 => t.dues,
      _ => t.resident,
    };

    return DashboardBackHandler(
      dashboardRootPath: '/resident-dashboard',
      currentTabIndex: _tabController.index,
      exitHintMessage: t.pressBackAgainToExit,
      goToHomeTab: () {
        ref.read(residentTabIndexProvider.notifier).reset();
        _tabController.animateTo(
          0,
          duration: DashboardNavAnimation.duration,
          curve: DashboardNavAnimation.curve,
        );
      },
      onExitHint: (message) => ref
          .read(toastProvider.notifier)
          .show(
            message,
            type: ToastType.info,
            duration: AppBackNavigation.exitGracePeriod,
          ),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: AppSizes.screenBodyScrollPadding.copyWith(
                  top: AppSizes.spacingS,
                  bottom: AppSizes.spacingM,
                ),
                child: DashboardPageHeader(
                  title: title,
                  userName: userName,
                  showWelcome: !isSettings,
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ResidentHomeTab(
                    onGoToDuesTab: _goToDuesTab,
                    onGoToIssuesTab: _goToIssuesTab,
                  ),
                  const ResidentDuesTab(),
                  const ResidentTicketsTab(),
                  const SettingsTab(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: DashboardBottomNavBar(
          selectedIndex: selectedTab,
          selectedAccentColor: ResidentHomeColors.blue,
          showSelectionPill: false,
          onDestinationSelected: (index) {
            ref.read(residentTabIndexProvider.notifier).update(index);
            _tabController.animateTo(
              index,
              duration: DashboardNavAnimation.duration,
              curve: DashboardNavAnimation.curve,
            );
          },
          destinations: [
            DashboardNavDestination(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: t.home,
            ),
            DashboardNavDestination(
              icon: Icons.account_balance_wallet_outlined,
              selectedIcon: Icons.account_balance_wallet,
              label: t.dues,
            ),
            DashboardNavDestination(
              icon: Icons.warning_amber_outlined,
              selectedIcon: Icons.warning_amber_rounded,
              label: t.issues,
            ),
            DashboardNavDestination(
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings,
              label: t.mySettings,
            ),
          ],
        ),
      ),
    );
  }
}
