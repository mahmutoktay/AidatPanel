import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/notifications/notification_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dekont/presentation/providers/dekont_provider.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../../../dues/presentation/providers/resident_due_transactions_provider.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../notifications/presentation/utils/notification_labels.dart';
import '../../../notifications/presentation/widgets/notification_detail_sheet.dart';
import '../../domain/activity_history_range.dart';
import '../../domain/resident_home_activity_item.dart';
import '../widgets/activity_history/activity_history_range_bar.dart';
import '../widgets/resident_home/resident_home_activity_row.dart';

class ResidentActivityHistoryScreen extends ConsumerStatefulWidget {
  const ResidentActivityHistoryScreen({super.key});

  @override
  ConsumerState<ResidentActivityHistoryScreen> createState() =>
      _ResidentActivityHistoryScreenState();
}

class _ResidentActivityHistoryScreenState
    extends ConsumerState<ResidentActivityHistoryScreen> {
  ActivityHistoryRange _selectedRange = ActivityHistoryRange.thisMonth;
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  Future<void> _loadHistory() async {
    await Future.wait([
      ref.read(duesNotifierProvider.notifier).loadMyDues(),
      ref.read(myDekontsNotifierProvider.notifier).load(refresh: true),
      ref.read(notificationsNotifierProvider.notifier).load(refresh: true),
    ]);
    await _loadMoreNotificationsIfNeeded();
    if (mounted) setState(() => _initialLoadDone = true);
  }

  Future<void> _loadMoreNotificationsIfNeeded() async {
    var guard = 0;
    while (mounted && guard < 8) {
      guard++;
      final state = ref.read(notificationsNotifierProvider);
      if (!state.canLoadMore) break;
      await ref.read(notificationsNotifierProvider.notifier).loadMore();
    }
  }

  Future<void> _refresh() => _loadHistory();

  Map<ActivityHistoryRange, String> _rangeLabels(BuildContext context) {
    final t = context.t.features.dashboard.activityHistory;
    return {
      ActivityHistoryRange.today: t.rangeToday,
      ActivityHistoryRange.thisWeek: t.rangeThisWeek,
      ActivityHistoryRange.thisMonth: t.rangeThisMonth,
      ActivityHistoryRange.threeMonths: t.rangeThreeMonths,
      ActivityHistoryRange.sixMonths: t.rangeSixMonths,
    };
  }

  Future<void> _openAnnouncement(NotificationEntity notification) async {
    if (!notification.isRead) {
      await ref
          .read(notificationsNotifierProvider.notifier)
          .markRead(notification.id);
    }
    if (!mounted) return;

    var shown = notification;
    for (final item in ref.read(notificationsNotifierProvider).items) {
      if (item.id == notification.id) {
        shown = item;
        break;
      }
    }

    final role = ref.read(authStateProvider).user?.role;
    final path = shown.toPayload().resolveNavigationPath(role: role);

    await NotificationDetailSheet.show(
      context,
      notification: shown,
      onMarkRead: () {},
      onNavigate: path != null
          ? () => navigateFromNotificationPath(context, ref, path)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final screenT = t.features.dashboard.activityHistory;
    final duesState = ref.watch(duesNotifierProvider);
    final transactionsState = ref.watch(residentDueTransactionsProvider);
    final notificationsState = ref.watch(notificationsNotifierProvider);

    final announcements = notificationsState.items
        .where((item) => item.type == NotificationType.announcement)
        .toList(growable: false);

    final feed = filterByActivityHistoryRange(
      buildResidentHomeActivityFeed(
        transactions: transactionsState.transactions,
        announcements: announcements,
      ),
      _selectedRange,
      (item) => item.occurredAt,
    );

    final duesById = duesByIdMap(duesState.dues);
    final isLoading = !_initialLoadDone &&
        (transactionsState.isLoading || notificationsState.isLoading);

    return DashboardSecondaryScaffold(
      title: screenT.title,
      fallbackRoute: '/resident-dashboard',
      showNotificationAction: true,
      body: ColoredBox(
        color: AppColors.dashboardBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: AppSizes.screenBodyScrollPadding.copyWith(
                top: AppSizes.spacingS,
                bottom: AppSizes.spacingS,
              ),
              child: ActivityHistoryRangeBar(
                selected: _selectedRange,
                labels: _rangeLabels(context),
                onSelected: (range) => setState(() => _selectedRange = range),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: AppColors.primary,
                child: isLoading
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Center(child: CircularProgressIndicator()),
                        ],
                      )
                    : feed.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: AppSizes.screenBodyScrollPadding,
                            children: [
                              EmptyStateWidget(
                                icon: Icons.history_rounded,
                                title: screenT.emptyTitle,
                                subtitle: screenT.emptySubtitle,
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: AppSizes.screenBodyScrollPadding.copyWith(
                              top: 0,
                              bottom: AppSizes.spacingXL,
                            ),
                            itemCount: feed.length,
                            itemBuilder: (context, index) {
                              final item = feed[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSizes.spacingS,
                                ),
                                child: ResidentHomeActivityRow(
                                  item: item,
                                  duesById: duesById,
                                  onTap: _onTap(item),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback? _onTap(ResidentHomeActivityItem item) {
    final transaction = item.transaction;
    if (transaction?.dekontId != null) {
      return () => context.push('/dekonts/${transaction!.dekontId}');
    }
    final announcement = item.announcement;
    if (announcement != null) {
      return () => _openAnnouncement(announcement);
    }
    return null;
  }
}
