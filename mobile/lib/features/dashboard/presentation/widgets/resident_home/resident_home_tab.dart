import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/notifications/notification_navigation.dart';
import '../../../../../core/notifications/notification_toast.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../dekont/presentation/providers/dekont_provider.dart';
import '../../../../dues/presentation/providers/dues_provider.dart';
import '../../../../dues/presentation/providers/resident_due_transactions_provider.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../../auth/presentation/providers/pending_rejoin_invite_provider.dart';
import '../../../../notifications/domain/entities/notification_entity.dart';
import '../../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../../notifications/presentation/utils/notification_labels.dart';
import '../../../../notifications/presentation/widgets/notification_detail_sheet.dart';
import 'resident_debt_summary_card.dart';
import 'resident_no_building_card.dart';
import 'resident_rejoin_bottom_sheet.dart';
import 'resident_home_quick_actions_row.dart';
import 'resident_recent_activity_section.dart';
import '../../../../feature_tour/presentation/feature_tour_targets.dart';

/// Sakin ana sayfa — borç özeti, hızlı işlemler, birleşik son hareketler.
class ResidentHomeTab extends ConsumerStatefulWidget {
  const ResidentHomeTab({
    super.key,
    required this.onGoToDuesTab,
    required this.onGoToIssuesTab,
  });

  final VoidCallback onGoToDuesTab;
  final VoidCallback onGoToIssuesTab;

  @override
  ConsumerState<ResidentHomeTab> createState() => _ResidentHomeTabState();
}

class _ResidentHomeTabState extends ConsumerState<ResidentHomeTab> {
  bool _handledPendingInvite = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureDataLoaded();
      _maybeOpenPendingRejoin();
    });
  }

  Future<void> _maybeOpenPendingRejoin() async {
    if (_handledPendingInvite || !mounted) return;
    final apartmentId = ref.read(authStateProvider).user?.apartmentId;
    if (apartmentId != null && apartmentId.isNotEmpty) return;

    final pending = ref.read(pendingRejoinInviteCodeProvider.notifier).take();
    if (pending == null || pending.isEmpty) return;

    _handledPendingInvite = true;
    await ResidentRejoinBottomSheet.show(context, initialCode: pending);
  }

  Future<void> _openRejoinSheet({String? initialCode}) async {
    await ResidentRejoinBottomSheet.show(context, initialCode: initialCode);
  }

  Future<void> _ensureDataLoaded() async {
    if (!mounted) return;
    final duesState = ref.read(duesNotifierProvider);
    if (duesState.dues.isEmpty && !duesState.isLoading) {
      await ref.read(duesNotifierProvider.notifier).loadMyDues();
    }
    final dekontsState = ref.read(myDekontsNotifierProvider);
    if (dekontsState.dekonts.isEmpty && !dekontsState.isLoading) {
      await ref.read(myDekontsNotifierProvider.notifier).load(refresh: true);
    }
    final notificationsState = ref.read(notificationsNotifierProvider);
    if (notificationsState.items.isEmpty && !notificationsState.isLoading) {
      await ref.read(notificationsNotifierProvider.notifier).load(refresh: true);
    }
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(duesNotifierProvider.notifier).loadMyDues(),
      ref.read(myDekontsNotifierProvider.notifier).load(refresh: true),
      ref.read(notificationsNotifierProvider.notifier).load(refresh: true),
      pollAndShowNotificationToasts(ref),
    ]);
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
    ref.listen<String?>(pendingRejoinInviteCodeProvider, (previous, next) {
      if (next == null || next.isEmpty || _handledPendingInvite) return;
      final apartmentId = ref.read(authStateProvider).user?.apartmentId;
      if (apartmentId != null && apartmentId.isNotEmpty) return;
      _handledPendingInvite = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final code = ref.read(pendingRejoinInviteCodeProvider.notifier).take();
        if (code == null) return;
        await ResidentRejoinBottomSheet.show(context, initialCode: code);
      });
    });

    final duesState = ref.watch(duesNotifierProvider);
    final transactionsState = ref.watch(residentDueTransactionsProvider);
    final notificationsState = ref.watch(notificationsNotifierProvider);
    final apartmentId = ref.watch(
      authStateProvider.select((state) => state.user?.apartmentId),
    );
    final hasApartment = apartmentId != null && apartmentId.isNotEmpty;
    final announcements = notificationsState.items
        .where((item) => item.type == NotificationType.announcement)
        .toList(growable: false);
    final isFeedLoading = transactionsState.isLoading ||
        (notificationsState.isLoading && announcements.isEmpty);

    return ColoredBox(
      color: AppColors.surface,
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.brand,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSizes.screenBodyScrollPadding.copyWith(
            top: 0,
            bottom: AppSizes.spacingXL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!hasApartment)
                ResidentNoBuildingCard(
                  key: FeatureTourTargets.summary,
                  onJoinTap: () => _openRejoinSheet(),
                )
              else
                ResidentDebtSummaryCard(
                  key: FeatureTourTargets.summary,
                  dues: duesState.dues,
                  isLoading: duesState.isLoading,
                ),
              const SizedBox(height: AppSizes.spacingM),
              ResidentHomeQuickActionsRow(
                key: FeatureTourTargets.quickActions,
                hasApartment: hasApartment,
                onJoinBuilding: () => _openRejoinSheet(),
                onGoToDuesTab: widget.onGoToDuesTab,
                onGoToIssuesTab: widget.onGoToIssuesTab,
              ),
              const SizedBox(height: AppSizes.spacingL),
              ResidentRecentActivitySection(
                transactions: transactionsState.transactions,
                announcements: announcements,
                dues: duesState.dues,
                isLoading: isFeedLoading,
                onOpenAnnouncement: _openAnnouncement,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
