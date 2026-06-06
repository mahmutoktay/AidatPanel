import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/dashboard_back_handler.dart';
import '../../../../core/navigation/app_back_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../../shared/widgets/notification_icon_button.dart';
import '../providers/manager_home_counts_provider.dart';
import '../../../tickets/presentation/providers/manager_open_tickets_count_provider.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../../dues/presentation/screens/manager_dues_tab.dart';
import '../../../../shared/widgets/settings_tab.dart';

import '../widgets/manager_home_tab.dart';
import '../widgets/manager_buildings_tab.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../../../core/theme/app_sizes.dart';
import 'package:go_router/go_router.dart';

class ManagerDashboardScreen extends ConsumerStatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  ConsumerState<ManagerDashboardScreen> createState() =>
      _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends ConsumerState<ManagerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
      ref.read(managerTabIndexProvider.notifier).state = _tabController.index;
      prefetchNotifications(ref);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      prefetchNotifications(ref);
      ref.invalidate(managerOpenTicketsCountProvider);
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
        _tabController.animateTo(next);
      }
    });

    final buildingsAsync = ref.watch(buildingsStoreProvider);

    return DashboardBackHandler(
      dashboardRootPath: '/manager-dashboard',
      currentTabIndex: _tabController.index,
      exitHintMessage: context.t.common.pressBackAgainToExit,
      goToHomeTab: () {
        ref.read(managerTabIndexProvider.notifier).state = 0;
        _tabController.animateTo(0);
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
            DashboardRoleBar(title: context.t.common.manager),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ManagerHomeTab(
                    buildingsAsync: buildingsAsync,
                    onRetryBuildings: () => ref.read(buildingsStoreProvider.notifier).loadBuildings(),
                    buildBuildingCards: _buildBuildingCards,
                  ),
                  ManagerBuildingsTab(buildingsAsync: buildingsAsync),
                  const ManagerDuesTab(),
                  const SettingsTab(),
                ],
              ),
            ),
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
              icon: const Icon(Icons.apartment_outlined),
              selectedIcon: const Icon(Icons.apartment),
              label: context.t.common.buildings,
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_outlined),
              selectedIcon: const Icon(Icons.receipt),
              label: context.t.common.dues,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: context.t.common.settings,
            ),
          ],
          selectedIndex: ref.watch(managerTabIndexProvider),
          onDestinationSelected: (index) {
            ref.read(managerTabIndexProvider.notifier).state = index;
            _tabController.animateTo(index);
          },
        ),
      ),
    );
  }
  
  List<Widget> _buildBuildingCards(List<BuildingEntity> buildings) {
    const tileRadius = BorderRadius.all(Radius.circular(12));

    return buildings
        .map(
          (building) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.fill,
                borderRadius: tileRadius,
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: tileRadius,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  borderRadius: tileRadius,
                  onTap: () => context.push('/manager-dashboard/buildings/${building.id}'),
                  splashColor: AppColors.border.withValues(alpha: 0.4),
                  highlightColor: AppColors.border.withValues(alpha: 0.25),
                  child: Padding(
                     padding: const EdgeInsets.all(AppSizes.spacingM),
                     child: Row(
                        children: [
                           const Icon(Icons.apartment, color: AppColors.primary),
                           const SizedBox(width: AppSizes.spacingM),
                           Expanded(child: Text(building.name)),
                           const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        ]
                     )
                  )
                ),
              ),
            ),
          ),
        )
        .toList();
  }
}
