import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_back_navigation.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/navigation/dashboard_back_handler.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/widgets/notification_icon_button.dart';
import '../../../../shared/widgets/settings_tab.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../../shared/widgets/tint_dashboard_tile.dart';
import '../../../../core/notifications/notification_toast.dart';
import '../../../notifications/presentation/widgets/announcement_form_sheet.dart';
import '../providers/manager_home_counts_provider.dart';
import '../../../tickets/presentation/providers/manager_open_tickets_count_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../../buildings/presentation/widgets/building_actions_sheet.dart';
import '../../../buildings/presentation/widgets/delete_building_dialog.dart';
import '../../../buildings/presentation/widgets/edit_building_bottom_sheet.dart';
import '../../../buildings/presentation/widgets/edit_building_collection_bottom_sheet.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../../../dues/presentation/screens/manager_dues_tab.dart';

class ManagerDashboardScreen extends ConsumerStatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  ConsumerState<ManagerDashboardScreen> createState() =>
      _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends ConsumerState<ManagerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _lastTransientErrorHintAt;
  String? _lastTransientErrorMessage;

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
                  _buildHomeTab(buildingsAsync),
                  _buildBuildingsTab(buildingsAsync),
                  _buildDuesTab(),
                  _buildSettingsTab(),
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

  Widget _buildHomeTab(AsyncValue<List<BuildingEntity>> buildingsAsync) {
    final openTicketsAsync = ref.watch(managerOpenTicketsCountProvider);
    final monthExpensesAsync = ref.watch(managerMonthExpensesCountProvider);
    final monthAnnouncementsAsync = ref.watch(
      managerMonthAnnouncementsCountProvider,
    );
    final pendingDekontsAsync = ref.watch(managerPendingDekontsCountProvider);
    _maybeShowTransientErrorHint([
      buildingsAsync,
      openTicketsAsync,
      monthExpensesAsync,
      monthAnnouncementsAsync,
      pendingDekontsAsync,
    ]);
    final openTicketCount = openTicketsAsync.valueOrNull ?? 0;
    final monthExpenseCount = monthExpensesAsync.valueOrNull ?? 0;
    final monthAnnouncementCount = monthAnnouncementsAsync.valueOrNull ?? 0;
    final pendingDekontCount = pendingDekontsAsync.valueOrNull ?? 0;
    final authState = ref.watch(authStateProvider);
    final userName = authState.user?.name ?? context.t.common.user;
    final buildings = buildingsAsync.valueOrNull ?? const <BuildingEntity>[];
    // Tüm binaların dues'unu paralel çeken provider — collectionRate ve
    // overdueCount'u backend `collectedDues` döndürmediği için buradan
    // hesaplıyoruz (DuesNotifier sadece tek seçili binayı tutuyor).
    final allDuesAsync = ref.watch(allBuildingsDuesProvider);
    final allDues =
        allDuesAsync.valueOrNull ?? const <String, List<DueEntity>>{};

    int totalApartments = 0;
    for (final b in buildings) {
      totalApartments += b.totalApartments;
    }
    final collectionRate = globalCollectionRate(allDues);
    final overdueCount = globalOverdueCount(allDues);

    return RefreshIndicator(
      onRefresh: _refreshHomeTab,
      color: AppColors.primary,
      // Boş bina listesinde de pull-to-refresh çalışsın diye
      // physics: AlwaysScrollableScrollPhysics
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSizes.screenBodyScrollPadding.copyWith(
          top: AppSizes.spacingS,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DashboardWelcomeLine(userName: userName),
            const SizedBox(height: AppSizes.spacingM),
            _HeroSummaryCard(
              totalApartments: totalApartments,
              collectionRate: collectionRate,
              overdueCount: overdueCount,
            ),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              context.t.common.quickActions,
              style: AppTypography.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSizes.spacingS),
            _ManagerQuickActionsRow(
              openTicketCount: openTicketCount,
              monthExpenseCount: monthExpenseCount,
              monthAnnouncementCount: monthAnnouncementCount,
              pendingDekontCount: pendingDekontCount,
              onTickets: () async {
                await context.push('/manager-dashboard/tickets');
                if (!mounted) return;
                ref.invalidate(managerOpenTicketsCountProvider);
              },
              onExpenses: () async {
                await context.push('/manager-dashboard/expenses');
                if (!mounted) return;
                ref.invalidate(managerMonthExpensesCountProvider);
              },
              onAnnouncement: () async {
                final sent = await AnnouncementFormSheet.show(context);
                if (!mounted) return;
                if (sent == true) {
                  ref.invalidate(managerMonthAnnouncementsCountProvider);
                }
              },
              onDekonts: () async {
                await context.push('/manager-dashboard/dekonts');
                if (!mounted) return;
                ref.invalidate(managerPendingDekontsCountProvider);
              },
            ),
            const SizedBox(height: AppSizes.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.t.common.managedBuildings,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingS,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: AppColors.cardBorder,
                  ),
                  child: Text(
                    buildings.length.toString(),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingM),
            _BuildingsAsyncSection(
              buildingsAsync: buildingsAsync,
              onRetry: _onRetryBuildings,
              buildList: _buildBuildingCards,
            ),
          ],
        ),
      ),
    );
  }

  void _maybeShowTransientErrorHint(List<AsyncValue<dynamic>> values) {
    Object? firstError;
    for (final value in values) {
      if (value.hasError) {
        firstError = value.error;
        break;
      }
    }
    if (firstError == null || !mounted) return;

    var isRateLimited = false;
    if (firstError is ApiException && firstError.statusCode == 429) {
      isRateLimited = true;
    } else {
      final fallback = userFacingError(firstError).toLowerCase();
      isRateLimited =
          fallback.contains('çok fazla istek') ||
          fallback.contains('too many requests') ||
          fallback.contains('429');
    }
    if (!isRateLimited) return;
    final message = context.t.common.rateLimitHint;

    final now = DateTime.now();
    final shouldDebounce =
        _lastTransientErrorMessage == message &&
        _lastTransientErrorHintAt != null &&
        now.difference(_lastTransientErrorHintAt!) <
            const Duration(seconds: 20);
    if (shouldDebounce) return;

    _lastTransientErrorMessage = message;
    _lastTransientErrorHintAt = now;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(toastProvider.notifier)
          .show(
            message,
            type: ToastType.info,
            duration: const Duration(seconds: 5),
          );
    });
  }

  /// Pull-to-refresh: bina listesi + tüm binaların dues'u birlikte yenilenir.
  /// Hero card collectionRate / overdueCount allBuildingsDuesProvider'ı
  /// dinlediği için invalidate sonrası otomatik güncellenir.
  Future<void> _refreshHomeTab() async {
    ref.invalidate(allBuildingsDuesProvider);
    ref.invalidate(managerOpenTicketsCountProvider);
    ref.invalidate(managerMonthExpensesCountProvider);
    ref.invalidate(managerMonthAnnouncementsCountProvider);
    ref.invalidate(managerPendingDekontsCountProvider);
    await Future.wait([
      ref.read(buildingsStoreProvider.notifier).loadBuildings(),
      pollAndShowNotificationToasts(ref),
    ]);
  }

  Widget _buildBuildingsTab(AsyncValue<List<BuildingEntity>> buildingsAsync) {
    return SingleChildScrollView(
      padding: AppSizes.screenBodyScrollPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: AppSizes.buttonHeightPrimary,
                  child: ElevatedButton.icon(
                    onPressed: _onAddBuildingPressed,
                    style: AppButtonStyles.elevatedPrimary(),
                    icon: const Icon(Icons.add_business),
                    label: Text(context.t.common.addBuilding),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: SizedBox(
                  height: AppSizes.buttonHeightPrimary,
                  child: ElevatedButton.icon(
                    onPressed: _onCreateInviteCodePressed,
                    style: AppButtonStyles.elevatedAccent(),
                    icon: const Icon(Icons.qr_code_2),
                    label: Text(context.t.common.inviteCode),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingL),
          Text(
            context.t.common.myBuildings,
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          _BuildingsAsyncSection(
            buildingsAsync: buildingsAsync,
            onRetry: _onRetryBuildings,
            buildList: (list) => list
                .map((b) => _buildDetailedBuildingCard(b))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  void _onRetryBuildings() {
    ref.read(buildingsStoreProvider.notifier).loadBuildings();
  }

  Widget _buildDetailedBuildingCard(BuildingEntity building) {
    const tileRadius = BorderRadius.all(Radius.circular(12));

    return Padding(
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
          child: Stack(
            children: [
              InkWell(
                borderRadius: tileRadius,
                splashColor: AppColors.border.withValues(alpha: 0.4),
                highlightColor: AppColors.border.withValues(alpha: 0.25),
                onTap: () => _onBuildingTapped(building),
                child: _buildBuildingCardContent(
                  building,
                  reserveMenuSlot: true,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: _buildBuildingActionsMenu(building),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ana menü “Yönetilen Binalar” ve Binalarım kartı üst satırı — ortak stil.
  Widget _buildManagedBuildingHeader(
    BuildingEntity building, {
    bool reserveMenuSlot = false,
    bool showChevron = false,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: AppSizes.minTouchTargetComfort,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingM,
          vertical: 14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.18),
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.apartment_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          building.name,
                          style: AppTypography.body1.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!building.isCollectionConfigured) ...[
                        const SizedBox(width: AppSizes.spacingXS),
                        Tooltip(
                          message: context
                              .t
                              .features
                              .buildings
                              .collection
                              .ibanNotConfigured,
                          child: Icon(
                            Icons.warning_amber_rounded,
                            size: 20,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.85),
                          ),
                        ),
                        const WidgetSpan(child: SizedBox(width: 4)),
                        TextSpan(text: building.displayAddress),
                      ],
                    ),
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    maxLines: reserveMenuSlot ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (reserveMenuSlot)
              const SizedBox(width: AppSizes.minTouchTargetComfort)
            else if (showChevron) ...[
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right,
                size: 24,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ] else
              _buildBuildingActionsMenu(building),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingCardContent(
    BuildingEntity building, {
    bool reserveMenuSlot = false,
  }) {
    final allDues =
        ref.watch(allBuildingsDuesProvider).valueOrNull ?? const {};
    final collectionRate = buildingCollectionRate(allDues, building.id);
    final showPerApartmentDues =
        building.dueAmount != null && building.dueAmount! > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildManagedBuildingHeader(
          building,
          reserveMenuSlot: reserveMenuSlot,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.spacingM,
            0,
            AppSizes.spacingM,
            AppSizes.spacingM,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.spacingS),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: DashboardMetricTile.kTileHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: DashboardMetricTile(
                          icon: Icons.door_front_door_outlined,
                          label: context.t.common.apartment,
                          value:
                              '${building.occupiedApartments}/${building.totalApartments}',
                          animateValue: false,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingS),
                      Expanded(
                        child: DashboardMetricTile(
                          icon: Icons.trending_up,
                          label: context.t.common.collection,
                          animatedValue: collectionRate.round(),
                          valuePrefix: '%',
                          valueColor: AppColors.success,
                          animateValue: false,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingS),
                      Expanded(
                        child: DashboardMetricTile(
                          icon: Icons.payments_outlined,
                          label: context.t.common.monthlyDues,
                          value:
                              '₺${building.totalMonthlyDues.toStringAsFixed(0)}',
                          animateValue: false,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showPerApartmentDues) ...[
                  const SizedBox(height: AppSizes.spacingS),
                  Container(
                    height: AppSizes.minTouchTargetComfort,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacingM,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.fill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 18,
                          color: AppColors.textSecondary.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: AppSizes.spacingS),
                        Expanded(
                          child: Text(
                            context.t.common.monthlyDuesPerApartment,
                            style: AppTypography.body2.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSizes.spacingS),
                        Text(
                          '₺${building.dueAmount!.toStringAsFixed(0)}',
                          style: AppTypography.body1.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Bina kartının sağ üstünde — işlemler alt sayfasını açar.
  Widget _buildBuildingActionsMenu(BuildingEntity building) {
    return SizedBox(
      width: AppSizes.minTouchTargetComfort,
      height: AppSizes.minTouchTargetComfort,
      child: IconButton(
        tooltip: MaterialLocalizations.of(context).showMenuTooltip,
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.more_vert,
          color: AppColors.textSecondary,
          size: AppSizes.iconSize,
        ),
        onPressed: () => _openBuildingActionsSheet(building),
      ),
    );
  }

  Future<void> _openBuildingActionsSheet(BuildingEntity building) async {
    final action = await BuildingActionsSheet.show(
      context,
      building: building,
    );
    if (!mounted || action == null) return;
    _onBuildingMenuAction(building, action);
  }

  /// Alt sayfa kapandıktan sonra düzenleme sheet / dialog aç (çakışmayı önler).
  void _onBuildingMenuAction(BuildingEntity building, BuildingMenuAction action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (action) {
        case BuildingMenuAction.edit:
          EditBuildingBottomSheet.show(context, building: building);
          break;
        case BuildingMenuAction.collection:
          EditBuildingCollectionBottomSheet.show(context, building: building);
          break;
        case BuildingMenuAction.delete:
          unawaited(DeleteBuildingDialog.show(context, building: building));
          break;
      }
    });
  }

  void _onAddBuildingPressed() {
    context.push('/manager-dashboard/add-building');
  }

  void _onCreateInviteCodePressed() {
    context.push('/manager-dashboard/invite-code');
  }

  void _onBuildingTapped(BuildingEntity building) {
    context.push('/manager-dashboard/buildings/${building.id}');
  }

  Widget _buildDuesTab() {
    return const ManagerDuesTab();
  }

  Widget _buildSettingsTab() {
    return const SettingsTab();
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
                  onTap: () => _onBuildingTapped(building),
                  splashColor: AppColors.border.withValues(alpha: 0.4),
                  highlightColor: AppColors.border.withValues(alpha: 0.25),
                  child: _buildManagedBuildingHeader(
                    building,
                    showChevron: true,
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
  }
}

class _BuildingsAsyncSection extends StatelessWidget {
  final AsyncValue<List<BuildingEntity>> buildingsAsync;
  final VoidCallback onRetry;
  final List<Widget> Function(List<BuildingEntity>) buildList;

  const _BuildingsAsyncSection({
    required this.buildingsAsync,
    required this.onRetry,
    required this.buildList,
  });

  @override
  Widget build(BuildContext context) {
    return buildingsAsync.when(
      data: (list) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buildList(list),
      ),
      // Veri varken arka planda yenileniyor (refresh) → eski listeyi göster.
      // Sadece ilk yüklemede (data null iken) loader çıkar.
      loading: () {
        final cached = buildingsAsync.valueOrNull;
        if (cached != null && cached.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: buildList(cached),
          );
        }
        return const _BuildingsLoadingPlaceholder();
      },
      error: (err, _) => _BuildingsErrorPlaceholder(
        message: userFacingError(err),
        onRetry: onRetry,
      ),
    );
  }
}

class _BuildingsLoadingPlaceholder extends StatelessWidget {
  const _BuildingsLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTypography.body2.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w500,
    );
    // Tam genişlikte bir alan açıp spinner + yazıyı hem yatay hem dikey
    // olarak Center ile ortalıyoruz. Yükseklik ekrana göre dinamik:
    // hero card ve başlığın altında kalan boşluğun ortasına denk gelsin.
    final placeholderHeight = MediaQuery.of(context).size.height * 0.32;
    return SizedBox(
      width: double.infinity,
      height: placeholderHeight,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spacingS),
            Text(context.t.common.loadingBuildings, style: textStyle),
          ],
        ),
      ),
    );
  }
}

class _BuildingsErrorPlaceholder extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _BuildingsErrorPlaceholder({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacingM,
        AppSizes.spacingL,
        AppSizes.spacingM,
        AppSizes.spacingL,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: AppColors.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 28),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: Text(
                  context.t.common.loadFailed,
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            message,
            style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.spacingM),
          SizedBox(
            height: AppSizes.buttonHeightSecondary,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 20),
              label: Text(context.t.common.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSummaryCard extends StatelessWidget {
  final int totalApartments;
  final double collectionRate;
  final int overdueCount;

  const _HeroSummaryCard({
    required this.totalApartments,
    required this.collectionRate,
    required this.overdueCount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DashboardMetricTile.kTileHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DashboardMetricTile(
              icon: Icons.apartment_outlined,
              animatedValue: totalApartments,
              label: context.t.common.totalApartments,
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: DashboardMetricTile(
              icon: Icons.trending_up,
              animatedValue: collectionRate.round(),
              valuePrefix: '%',
              label: context.t.common.collection,
              valueColor: AppColors.success,
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: DashboardMetricTile(
              icon: Icons.warning_amber_rounded,
              animatedValue: overdueCount,
              label: context.t.common.overdueStatus,
              valueColor: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagerQuickActionsRow extends StatelessWidget {
  final int openTicketCount;
  final int monthExpenseCount;
  final int monthAnnouncementCount;
  final int pendingDekontCount;
  final VoidCallback onTickets;
  final VoidCallback onExpenses;
  final VoidCallback onAnnouncement;
  final VoidCallback onDekonts;

  const _ManagerQuickActionsRow({
    required this.openTicketCount,
    required this.monthExpenseCount,
    required this.monthAnnouncementCount,
    required this.pendingDekontCount,
    required this.onTickets,
    required this.onExpenses,
    required this.onAnnouncement,
    required this.onDekonts,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.faz2;
    final dekontT = context.t.features.dekont;
    return Column(
      children: [
        SizedBox(
          height: DashboardActionTile.compactRowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: DashboardActionTile(
                  icon: Icons.support_agent_outlined,
                  value: openTicketCount.toString(),
                  label: t.tickets,
                  valueColor: AppColors.info,
                  compact: true,
                  onTap: onTickets,
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: DashboardActionTile(
                  icon: Icons.receipt_long_outlined,
                  value: monthExpenseCount.toString(),
                  label: t.expenses,
                  valueColor: AppColors.accent,
                  compact: true,
                  onTap: onExpenses,
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: DashboardActionTile(
                  icon: Icons.campaign_outlined,
                  value: monthAnnouncementCount.toString(),
                  label: t.announcement,
                  valueColor: AppColors.primaryLight,
                  compact: true,
                  onTap: onAnnouncement,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        SizedBox(
          width: double.infinity,
          height: AppSizes.minTouchTargetComfort,
          child: DashboardActionTile(
            icon: Icons.rate_review_outlined,
            value: pendingDekontCount.toString(),
            label: dekontT.reviewAction,
            iconColor: AppColors.textPrimary,
            valueColor: AppColors.textPrimary,
            compact: false,
            onTap: onDekonts,
          ),
        ),
      ],
    );
  }
}
