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
import '../utils/notification_style.dart';
import '../utils/notification_time.dart';
import '../widgets/notification_detail_sheet.dart';

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

    final visible = _filter == _NotificationFilter.unread
        ? state.items.where((n) => !n.isRead).toList()
        : state.items;

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
      body: RefreshIndicator(
        onRefresh: _reload,
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.dashboardScreenPaddingHorizontal,
                AppSizes.spacingM,
                AppSizes.dashboardScreenPaddingHorizontal,
                0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Filtre segment butonları
                  _buildFilterSegments(state.unreadCount),
                  const SizedBox(height: AppSizes.spacingL),

                  // Başlık + sayı rozeti
                  _buildListHeader(visible.length),
                  const SizedBox(height: AppSizes.spacingM),

                  // Yükleme göstergesi
                  if (state.isLoading && state.items.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(minHeight: 3),
                      ),
                    ),
                ]),
              ),
            ),

            // Body durumları
            if (state.isLoading && state.items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null && state.items.isEmpty)
              _buildErrorSliver()
            else if (visible.isEmpty)
              _buildEmptySliver()
            else
              _buildNotificationList(visible, locale),

            // Load more
            if (state.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.spacingL),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Filtre segment butonları (fill zemin dashboard stili)
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildFilterSegments(int unreadCount) {
    final t = context.t.features.notifications;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentPill(
              label: t.filterUnread,
              badge: unreadCount > 0 ? unreadCount : null,
              selected: _filter == _NotificationFilter.unread,
              onTap: () => setState(() => _filter = _NotificationFilter.unread),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _SegmentPill(
              label: t.filterAll,
              selected: _filter == _NotificationFilter.all,
              onTap: () => setState(() => _filter = _NotificationFilter.all),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Başlık + sayı rozeti
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildListHeader(int count) {
    final t = context.t.features.notifications;
    final label = _filter == _NotificationFilter.unread
        ? t.filterUnread
        : t.filterAll;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
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
            count.toString(),
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Bildirim listesi
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildNotificationList(
    List<NotificationEntity> visible,
    String locale,
  ) {
    final rows = _buildRows(visible);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.dashboardScreenPaddingHorizontal,
        0,
        AppSizes.dashboardScreenPaddingHorizontal,
        AppSizes.spacingL,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, i) {
          final row = rows[i];
          if (row is _SectionRow) {
            return _SectionHeaderLabel(
              label: row.section.label(context),
              isFirst: i == 0,
            );
          }

          final n = (row as _ItemRow).notification;
          return _buildNotificationCard(context, n, locale);
        }, childCount: rows.length),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Bildirim kartı — fill zemin dashboard stili
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildNotificationCard(
    BuildContext context,
    NotificationEntity n,
    String locale,
  ) {
    final visual = notificationVisual(n.type);
    final unread = !n.isRead;
    final timeStr = notificationRelativeTime(
      context,
      n.createdAt,
      locale: locale,
    );
    final typeLabel = n.type.label(context).trim();
    final title = n.title.trim();
    final showTypeLabel =
        typeLabel.isNotEmpty &&
        title.isNotEmpty &&
        typeLabel.toLowerCase() != title.toLowerCase();
    const tileRadius = BorderRadius.all(Radius.circular(12));

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
      child: Material(
        color: Colors.transparent,
        borderRadius: tileRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openNotification(n),
          borderRadius: tileRadius,
          splashColor: AppColors.border.withValues(alpha: 0.4),
          highlightColor: AppColors.border.withValues(alpha: 0.25),
          child: Container(
            decoration: BoxDecoration(
              color: unread ? AppColors.surface : AppColors.fill,
              borderRadius: tileRadius,
              border: unread
                  ? Border.all(color: visual.color.withValues(alpha: 0.3))
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Üst satır: ikon + tip etiketi + zaman
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: visual.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: visual.color.withValues(alpha: 0.25),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(visual.icon, color: visual.color, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showTypeLabel) ...[
                              Row(
                                children: [
                                  Text(
                                    typeLabel,
                                    style: AppTypography.caption.copyWith(
                                      color: visual.color,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  Text(
                                    timeStr,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (unread) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: visual.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              title,
                              style: AppTypography.body1.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: unread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                fontSize: 17,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  // Alt içerik: body + zaman (tip etiketi yoksa)
                  Container(
                    padding: const EdgeInsets.all(AppSizes.spacingS),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            n.body,
                            style: AppTypography.body2.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!showTypeLabel) ...[
                          const SizedBox(width: AppSizes.spacingS),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                timeStr,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (unread) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: visual.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Hata durumu
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildErrorSliver() {
    final t = context.t.features.notifications;
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: AppSizes.screenBodyScrollPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
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
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Boş durum
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildEmptySliver() {
    final unreadFilter = _filter == _NotificationFilter.unread;
    final t = context.t.features.notifications;
    return SliverFillRemaining(
      hasScrollBody: false,
      child: EmptyStateWidget(
        icon: unreadFilter
            ? Icons.mark_email_read_outlined
            : Icons.notifications_none_outlined,
        title: unreadFilter ? t.emptyUnreadTitle : t.emptyTitle,
        subtitle: unreadFilter ? t.emptyUnreadSubtitle : t.emptySubtitle,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Section + item sıralama
  // ─────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────
// Alt widget'lar
// ─────────────────────────────────────────────────────────────────────

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
        top: isFirst ? 0 : AppSizes.spacingM,
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

/// Dashboard stili segment buton (iç içe fill zemin)
class _SegmentPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badge;

  const _SegmentPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? AppColors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
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
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
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
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$badge',
                      style: AppTypography.caption.copyWith(
                        color: selected ? AppColors.primary : AppColors.error,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
