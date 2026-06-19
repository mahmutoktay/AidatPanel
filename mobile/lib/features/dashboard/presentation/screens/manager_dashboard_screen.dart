import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/dashboard_back_handler.dart';
import '../../../../core/navigation/app_back_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../../shared/widgets/dashboard/dashboard_bottom_nav_bar.dart';
import '../../../../shared/widgets/dashboard/dashboard_app_bar.dart';
import '../../../../shared/widgets/dashboard/profile_drawer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../shared/widgets/notification_icon_button.dart';
import '../providers/manager_home_counts_provider.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../../dues/presentation/screens/manager_dues_tab.dart';
import '../../../../shared/widgets/menu_tab.dart';

import '../widgets/manager_home_tab.dart';
import '../widgets/manager_buildings_tab.dart';

class ManagerDashboardScreen extends ConsumerStatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  ConsumerState<ManagerDashboardScreen> createState() =>
      _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends ConsumerState<ManagerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final initialIndex = ref.read(managerTabIndexProvider);
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      ref.read(managerTabIndexProvider.notifier).update(_tabController.index);
      prefetchNotifications(ref);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      prefetchNotifications(ref);
      ref.invalidate(managerMonthExpensesCountProvider);
      ref.invalidate(managerMonthAnnouncementsCountProvider);
      ref.invalidate(managerPendingDekontsCountProvider);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(managerTabIndexProvider, (previous, next) {
      if (_tabController.index != next) {
        _tabController.animateTo(
          next,
          duration: DashboardNavAnimation.duration,
          curve: DashboardNavAnimation.curve,
        );
      }
    });

    final buildingsAsync = ref.watch(buildingsStoreProvider);
    final userName =
        ref.watch(authStateProvider).user?.name ?? context.t.common.user;
    final selectedTab = ref.watch(managerTabIndexProvider);

    return DashboardBackHandler(
      dashboardRootPath: '/manager-dashboard',
      currentTabIndex: _tabController.index,
      exitHintMessage: context.t.common.pressBackAgainToExit,
      goToHomeTab: () {
        ref.read(managerTabIndexProvider.notifier).reset();
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
        key: _scaffoldKey,
        drawer: const ProfileDrawer(role: UserRole.manager),
        drawerEnableOpenDragGesture: false,
        backgroundColor: AppColors.dashboardBackground,
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
                child: DashboardAppBar(
                  roleTitle: context.t.common.manager,
                  userName: userName,
                  showWelcome: selectedTab == 0,
                  onProfileTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ManagerHomeTab(
                    buildingsAsync: buildingsAsync,
                    onRetryBuildings: () =>
                        ref.read(buildingsStoreProvider.notifier).loadBuildings(),
                  ),
                  ManagerBuildingsTab(buildingsAsync: buildingsAsync),
                  const ManagerDuesTab(),
                  const MenuTab(role: UserRole.manager),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: DashboardBottomNavBar(
          selectedIndex: ref.watch(managerTabIndexProvider),
          onDestinationSelected: (index) {
            ref.read(managerTabIndexProvider.notifier).update(index);
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
              label: context.t.common.home,
            ),
            DashboardNavDestination(
              icon: Icons.apartment_outlined,
              selectedIcon: Icons.apartment,
              label: context.t.common.buildings,
            ),
            DashboardNavDestination(
              icon: Icons.receipt_outlined,
              selectedIcon: Icons.receipt,
              label: context.t.common.dues,
            ),
            DashboardNavDestination(
              icon: Icons.apps_outlined,
              selectedIcon: Icons.apps_rounded,
              label: context.t.common.menu,
            ),
          ],
        ),
      ),
    );
  }
}
