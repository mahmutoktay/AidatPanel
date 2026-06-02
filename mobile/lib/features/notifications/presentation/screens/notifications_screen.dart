import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/notifications/notification_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
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
  _NotificationFilter _filter = _NotificationFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
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

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    if (max - offset < 120) {
      ref.read(notificationsNotifierProvider.notifier).loadMore();
    }
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsNotifierProvider);
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          context.t.common.notifications,
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (state.unreadCount > 0)
            IconButton(
              tooltip: context.t.features.notifications.markAllRead,
              onPressed: state.isLoading
                  ? null
                  : () => ref
                        .read(notificationsNotifierProvider.notifier)
                        .markAllRead(),
              icon: const Icon(Icons.done_all_rounded),
            ),
        ],
      ),
      body: Column(
        children: [
          _FilterHeader(
            filter: _filter,
            unreadCount: state.unreadCount,
            onFilterChanged: (f) => setState(() => _filter = f),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _reload,
              color: AppColors.primary,
              child: _buildBody(context, state, locale),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    NotificationsState state,
    String locale,
  ) {
    final t = context.t.features.notifications;

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
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
          Center(
            child: Padding(
              padding: AppSizes.screenBodyScrollPadding,
              child: Column(
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
          ),
        ],
      );
    }

    final visible = _filter == _NotificationFilter.unread
        ? state.items.where((n) => !n.isRead).toList()
        : state.items;

    if (visible.isEmpty) {
      final unreadFilter = _filter == _NotificationFilter.unread;
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyStateWidget(
            icon: unreadFilter
                ? Icons.mark_email_read_outlined
                : Icons.notifications_none_outlined,
            title: unreadFilter ? t.emptyUnreadTitle : t.emptyTitle,
            subtitle:
                unreadFilter ? t.emptyUnreadSubtitle : t.emptySubtitle,
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
            padding: EdgeInsets.all(AppSizes.spacingL),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final row = rows[i];
        if (row is _SectionRow) {
          return _SectionHeaderLabel(
            label: row.section.label(context),
            isFirst: i == 0,
          );
        }

        final n = (row as _ItemRow).notification;
        return NotificationListTile(
          notification: n,
          locale: locale,
          onTap: () => _openNotification(n),
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

class _SectionHeaderLabel extends StatelessWidget {
  final String label;
  final bool isFirst;

  const _SectionHeaderLabel({required this.label, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? 0 : AppSizes.spacingS,
        bottom: AppSizes.spacingS,
        left: 2,
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FilterHeader extends StatelessWidget {
  final _NotificationFilter filter;
  final int unreadCount;
  final ValueChanged<_NotificationFilter> onFilterChanged;

  const _FilterHeader({
    required this.filter,
    required this.unreadCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.notifications;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.dashboardScreenPaddingHorizontal,
        AppSizes.spacingS,
        AppSizes.dashboardScreenPaddingHorizontal,
        AppSizes.spacingS,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SegmentButton(
                  label: t.filterAll,
                  selected: filter == _NotificationFilter.all,
                  onTap: () => onFilterChanged(_NotificationFilter.all),
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: _SegmentButton(
                  label: t.filterUnread,
                  badge: unreadCount > 0 ? unreadCount : null,
                  selected: filter == _NotificationFilter.unread,
                  onTap: () => onFilterChanged(_NotificationFilter.unread),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingXS),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badge;

  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.fill,
      borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
        child: Container(
          height: AppSizes.minTouchTarget,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingS),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.button.copyWith(
                    color: selected ? AppColors.surface : AppColors.textPrimary,
                  ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.surface : AppColors.error,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$badge',
                    style: AppTypography.caption.copyWith(
                      color: selected ? AppColors.primary : AppColors.surface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
