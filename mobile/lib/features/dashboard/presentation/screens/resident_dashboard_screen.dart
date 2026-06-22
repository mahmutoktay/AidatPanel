import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/app_back_navigation.dart';
import '../../../../core/navigation/dashboard_back_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/widgets/dashboard/dashboard_bottom_nav_bar.dart';
import '../../../../shared/widgets/dashboard/dashboard_app_bar.dart';
import '../../../../shared/widgets/dashboard/profile_drawer.dart';
import '../../../../shared/widgets/menu_tab.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../../shared/widgets/notification_icon_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../../../dues/presentation/screens/resident_dues_tab.dart';
import '../../../tickets/presentation/providers/tickets_provider.dart';
import '../../../tickets/presentation/screens/resident_tickets_tab.dart';
import '../widgets/resident_home/resident_home_tab.dart';

class ResidentDashboardScreen extends ConsumerStatefulWidget {
  const ResidentDashboardScreen({super.key});

  @override
  ConsumerState<ResidentDashboardScreen> createState() =>
      _ResidentDashboardScreenState();
}

class _ResidentDashboardScreenState extends ConsumerState<ResidentDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
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
      onExitHint: (message) => ref.read(toastProvider.notifier).show(
            message,
            type: ToastType.info,
            duration: AppBackNavigation.exitGracePeriod,
          ),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const ProfileDrawer(role: UserRole.resident),
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
                  roleTitle: t.resident,
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
                  ResidentHomeTab(
                    onGoToDuesTab: _goToDuesTab,
                    onGoToIssuesTab: _goToIssuesTab,
                  ),
                  const ResidentDuesTab(),
                  const ResidentTicketsTab(),
                  const MenuTab(role: UserRole.resident),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: DashboardBottomNavBar(
          selectedIndex: selectedTab,
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
              icon: Icons.receipt_outlined,
              selectedIcon: Icons.receipt,
              label: t.dues,
            ),
            DashboardNavDestination(
              icon: Icons.warning_amber_outlined,
              selectedIcon: Icons.warning_amber_rounded,
              label: t.issues,
            ),
            DashboardNavDestination(
              icon: Icons.apps_outlined,
              selectedIcon: Icons.apps_rounded,
              label: t.menu,
            ),
          ],
        ),
      ),
    );
  }
}
