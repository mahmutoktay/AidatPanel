import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/notifications/notification_navigation.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/premium_filter_button.dart';
import '../../../../shared/widgets/premium_filter_picker.dart';
import '../../../../shared/widgets/premium_filter_sheet.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/notification_entity.dart';
import '../providers/notifications_provider.dart';
import '../utils/notification_labels.dart';
import '../utils/notification_time.dart';
import '../widgets/notification_detail_sheet.dart';
import '../widgets/notification_list_tile.dart';

enum _NotificationFilter { all, unread }

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with WidgetsBindingObserver {
  static const _pollInterval = Duration(seconds: 60);

  final _scrollController = ScrollController();
  Timer? _pollTimer;
  _NotificationFilter _filter = _NotificationFilter.unread;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    attachPaginationScroll(
      _scrollController,
      () => ref.read(notificationsNotifierProvider.notifier).loadMore(),
      canLoad: () => ref.read(notificationsNotifierProvider).canLoadMore,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
    _pollTimer = Timer.periodic(_pollInterval, (_) => _reload());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reload();
    }
  }

  Future<void> _reload() async {
    if (!mounted) return;
    await ref.read(notificationsNotifierProvider.notifier).load(refresh: true);
  }

  Future<void> _openNotification(NotificationEntity n) async {
    if (!n.isRead) {
      await ref.read(notificationsNotifierProvider.notifier).markRead(n.id);
    }

    final role = ref.read(authStateProvider).user?.role;
    final path = n.toPayload().resolveNavigationPath(role: role);

    if (!mounted) return;

    var shown = n;
    for (final e in ref.read(notificationsNotifierProvider).items) {
      if (e.id == n.id) {
        shown = e;
        break;
      }
    }

    await NotificationDetailSheet.show(
      context,
      notification: shown,
      onMarkRead: () {},
      onNavigate: path != null
          ? () => navigateFromNotificationPath(context, ref, path)
          : null,
    );
  }

  String _notificationFilterLabel(BuildContext context, _NotificationFilter filter) {
    return filter == _NotificationFilter.unread
        ? context.t.features.notifications.filterUnread
        : context.t.features.notifications.filterAll;
  }

  Future<void> _openFilterSheet() async {
    var draftFilter = _filter;
    final common = context.t.common;
    final t = context.t.features.notifications;

    await PremiumFilterSheet.show(
      context: context,
      title: common.filter,
      applyLabel: common.apply,
      fieldBuilder: (ctx, setSheetState) {
        return [
          PremiumFilterFieldConfig(
            label: common.status,
            value: _notificationFilterLabel(ctx, draftFilter),
            hint: t.filterUnread,
            icon: Icons.visibility_outlined,
            onTap: () async {
              final picked = await showPremiumSingleSelectPicker<_NotificationFilter>(
                context: ctx,
                title: common.status,
                selected: draftFilter,
                options: [
                  PremiumFilterPickerOption(
                    value: _NotificationFilter.unread,
                    label: t.filterUnread,
                    icon: Icons.mark_email_unread_outlined,
                  ),
                  PremiumFilterPickerOption(
                    value: _NotificationFilter.all,
                    label: t.filterAll,
                    icon: Icons.inbox_outlined,
                  ),
                ],
              );
              if (picked == null) return;
              setSheetState(() => draftFilter = picked);
            },
          ),
        ];
      },
      onApply: () => setState(() => _filter = draftFilter),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsNotifierProvider);
    final t = context.t.features.notifications;

    final visible = _filter == _NotificationFilter.unread
        ? state.items.where((n) => !n.isRead).toList()
        : state.items;

    final filterLabel = _filter == _NotificationFilter.unread
        ? t.filterUnread
        : t.filterAll;

    return DashboardSecondaryScaffold(
      title: context.t.common.notifications,
      actions: [
        if (state.unreadCount > 0)
          IconButton(
            tooltip: t.markAllRead,
            onPressed: state.isLoading
                ? null
                : () => ref
                      .read(notificationsNotifierProvider.notifier)
                      .markAllRead(),
            icon: Icon(Icons.done_all_rounded, color: AppColors.inkDark),
          ),
      ],
      body: DashboardListScreenBody(
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PremiumFilterButton(
              hasActiveFilters: _filter != _NotificationFilter.unread,
              onPressed: _openFilterSheet,
            ),
            const SizedBox(height: AppSizes.spacingM),
            DashboardSectionTitle(
              title: filterLabel,
              trailing: _CountBadge(count: visible.length),
            ),
            if (state.isLoading && state.items.isNotEmpty) ...[
              const SizedBox(height: AppSizes.spacingS),
              LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: AppColors.lineLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.statusBlue,
                ),
              ),
            ],
          ],
        ),
        list: RefreshIndicator(
          onRefresh: _reload,
          color: AppColors.primary,
          child: _buildList(context, state, visible),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    NotificationsState state,
    List<NotificationEntity> visible,
  ) {
    if (state.isLoading && state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (state.error != null && state.items.isEmpty) {
      final t = context.t.features.notifications;
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
          Padding(
            padding: AppSizes.screenBodyScrollPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.loadError,
                  style: AppTypography.body1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spacingM),
                FilledButton(
                  onPressed: () => ref
                      .read(notificationsNotifierProvider.notifier)
                      .load(refresh: true),
                  child: Text(context.t.common.tryAgain),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (visible.isEmpty) {
      final unreadFilter = _filter == _NotificationFilter.unread;
      final t = context.t.features.notifications;
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyStateWidget(
            icon: unreadFilter
                ? Icons.mark_email_read_outlined
                : Icons.notifications_none_outlined,
            title: unreadFilter ? t.emptyUnreadTitle : t.emptyTitle,
            subtitle: unreadFilter ? t.emptyUnreadSubtitle : t.emptySubtitle,
          ),
        ],
      );
    }

    final rows = _buildRows(visible);
    final itemCount = rows.length + (state.isLoadingMore ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppSizes.screenBodyScrollPadding,
      itemCount: itemCount,
      itemBuilder: (context, i) {
        if (i >= rows.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.spacingM),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final row = rows[i];
        if (row is _SectionRow) {
          return Padding(
            padding: EdgeInsets.only(
              top: i == 0 ? 0 : AppSizes.spacingM,
              bottom: AppSizes.spacingS,
            ),
            child: Text(
              row.section.label(context),
              style: AppTypography.caption.copyWith(
                color: AppColors.mutedText,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        }

        final n = (row as _ItemRow).notification;
        return Padding(
          padding: DashboardScreenStyle.listItemPadding,
          child: NotificationListTile(
            notification: n,
            onTap: () => _openNotification(n),
          ),
        );
      },
    );
  }

  List<_Row> _buildRows(List<NotificationEntity> items) {
    final rows = <_Row>[];
    NotificationDateSection? current;
    for (final n in items) {
      final section = notificationSectionFor(n.createdAt);
      if (section != current) {
        current = section;
        rows.add(_SectionRow(section));
      }
      rows.add(_ItemRow(n));
    }
    return rows;
  }
}

sealed class _Row {
  const _Row();
}

class _SectionRow extends _Row {
  final NotificationDateSection section;
  const _SectionRow(this.section);
}

class _ItemRow extends _Row {
  final NotificationEntity notification;
  const _ItemRow(this.notification);
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingS,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lineLight),
      ),
      child: Text(
        count.toString(),
        style: AppTypography.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
