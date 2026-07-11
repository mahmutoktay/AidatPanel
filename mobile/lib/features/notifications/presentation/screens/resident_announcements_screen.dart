import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../domain/entities/notification_entity.dart';
import '../providers/notifications_provider.dart';
import '../utils/notification_time.dart';
import '../widgets/notification_detail_sheet.dart';
import '../widgets/notification_list_tile.dart';

/// Sakin — yalnızca yönetim duyuruları listesi.
class ResidentAnnouncementsScreen extends ConsumerStatefulWidget {
  const ResidentAnnouncementsScreen({super.key});

  @override
  ConsumerState<ResidentAnnouncementsScreen> createState() =>
      _ResidentAnnouncementsScreenState();
}

class _ResidentAnnouncementsScreenState
    extends ConsumerState<ResidentAnnouncementsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    attachPaginationScroll(
      _scrollController,
      () => ref.read(notificationsNotifierProvider.notifier).loadMore(),
      canLoad: () => ref.read(notificationsNotifierProvider).canLoadMore,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    if (!mounted) return;
    await ref.read(notificationsNotifierProvider.notifier).load(refresh: true);
  }

  Future<void> _openAnnouncement(NotificationEntity n) async {
    if (!n.isRead) {
      await ref.read(notificationsNotifierProvider.notifier).markRead(n.id);
    }
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
      onNavigate: null,
    );
  }

  List<NotificationEntity> _announcements(List<NotificationEntity> items) {
    return items
        .where((n) => n.type == NotificationType.announcement)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsNotifierProvider);
    final announcements = _announcements(state.items);

    return DashboardSecondaryScaffold(
      title: context.t.common.announcements,
      body: DashboardListScreenBody(
        list: RefreshIndicator(
          onRefresh: _reload,
          color: AppColors.primary,
          child: _buildList(context, state, announcements),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    NotificationsState state,
    List<NotificationEntity> announcements,
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

    if (announcements.isEmpty) {
      final t = context.t.features.notifications.resident;
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyStateWidget(
            icon: Icons.campaign_outlined,
            title: t.announcementsEmptyTitle,
            subtitle: t.announcementsEmptySubtitle,
          ),
        ],
      );
    }

    final rows = _buildRows(announcements);
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
            onTap: () => _openAnnouncement(n),
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
