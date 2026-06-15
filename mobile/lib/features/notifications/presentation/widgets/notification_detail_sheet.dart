import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../l10n/strings.g.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dekont/domain/entities/dekont_entity.dart';
import '../../../dekont/presentation/providers/dekont_provider.dart';
import '../../../dekont/presentation/utils/dekont_labels.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../../../tickets/domain/entities/ticket_entity.dart';
import '../../../tickets/presentation/providers/tickets_provider.dart';
import '../../../tickets/presentation/utils/ticket_labels.dart';
import '../../domain/entities/notification_entity.dart';
import '../utils/notification_labels.dart';
import '../utils/notification_style.dart';

/// Bildirim detayı — türe özel zengin alt sayfa; ilgili kayda geçiş.
class NotificationDetailSheet {
  NotificationDetailSheet._();

  static Future<void> show(
    BuildContext context, {
    required NotificationEntity notification,
    required VoidCallback onMarkRead,
    VoidCallback? onNavigate,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NotificationDetailSheetBody(
        notification: notification,
        onMarkRead: onMarkRead,
        onNavigate: onNavigate,
      ),
    );
  }
}

class _NotificationDetailSheetBody extends ConsumerWidget {
  final NotificationEntity notification;
  final VoidCallback onMarkRead;
  final VoidCallback? onNavigate;

  const _NotificationDetailSheetBody({
    required this.notification,
    required this.onMarkRead,
    this.onNavigate,
  });

  String _actionLabel(BuildContext context) {
    final t = context.t.features.notifications;
    switch (notification.type) {
      case NotificationType.ticketCreated:
      case NotificationType.ticketUpdate:
        return t.actionViewTicket;
      case NotificationType.dekontReceived:
      case NotificationType.dekontNeedsReview:
      case NotificationType.dekontMatched:
      case NotificationType.dekontPaymentApplied:
        return t.actionViewDekont;
      case NotificationType.dueReminder:
      case NotificationType.duePaid:
      case NotificationType.expenseAdded:
        return t.actionViewDue;
      default:
        return t.viewRelated;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = notification;
    final visual = notificationVisual(n.type);
    final dateStr = AppDateFormat.dateTimeMedium(n.createdAt);
    final t = context.t.features.notifications;
    final role = ref.read(authStateProvider).user?.role;
    final path = n.toPayload().resolveNavigationPath(role: role);
    final canNavigate = path != null && onNavigate != null;

    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.86;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DashboardScreenStyle.cardRadius),
        ),
        boxShadow: DashboardScreenStyle.cardShadow,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.spacingM,
          AppSizes.spacingS,
          AppSizes.spacingM,
          AppSizes.spacingXL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: AppSizes.spacingXS),
                decoration: BoxDecoration(
                  color: AppColors.lineLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
              const SizedBox(height: AppSizes.spacingM),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: visual.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(visual.icon, color: visual.color, size: 28),
                  ),
                  const SizedBox(width: AppSizes.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.type.label(context),
                          style: AppTypography.caption.copyWith(
                            color: visual.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!n.isRead)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.infoBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        t.unreadBadge,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingL),
              Text(
                n.title,
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSizes.spacingM),
              _DetailSection(notification: n),
              const SizedBox(height: AppSizes.spacingXL),
              if (canNavigate)
                SizedBox(
                  height: AppSizes.buttonHeightPrimary,
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      if (!n.isRead) onMarkRead();
                      Navigator.of(context).pop();
                      onNavigate!();
                    },
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(_actionLabel(context)),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: AppSizes.spacingS),
            SizedBox(
              height: AppSizes.buttonHeightSecondary,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  if (!n.isRead) onMarkRead();
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(context.t.common.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Türe göre detay gövdesini seçer; ilgili kayıt çekilemezse bildirim
/// gövdesine düşer (kullanıcı asla boş ekranla kalmaz).
class _DetailSection extends ConsumerWidget {
  final NotificationEntity notification;

  const _DetailSection({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = notification;
    final payload = n.toPayload();

    switch (n.type) {
      case NotificationType.ticketCreated:
      case NotificationType.ticketUpdate:
        final ticketId = payload.ticketId;
        if (ticketId == null) return _GenericBody(body: n.body);
        return _TicketDetailSection(
          ticketId: ticketId,
          fallbackBody: n.body,
        );
      case NotificationType.dekontReceived:
      case NotificationType.dekontNeedsReview:
      case NotificationType.dekontMatched:
      case NotificationType.dekontPaymentApplied:
        final dekontId = payload.dekontId;
        if (dekontId == null) return _GenericBody(body: n.body);
        return _DekontDetailSection(
          dekontId: dekontId,
          fallbackBody: n.body,
        );
      case NotificationType.dueReminder:
      case NotificationType.duePaid:
      case NotificationType.expenseAdded:
        return _DueDetailSection(
          dueId: payload.dueId,
          fallbackBody: n.body,
        );
      case NotificationType.announcement:
      case NotificationType.system:
      case NotificationType.other:
        return _GenericBody(body: n.body);
    }
  }
}

// ---------------------------------------------------------------------------
// Talep (ticket) detayı
// ---------------------------------------------------------------------------

class _TicketDetailSection extends ConsumerWidget {
  final String ticketId;
  final String fallbackBody;

  const _TicketDetailSection({
    required this.ticketId,
    required this.fallbackBody,
  });

  Color _statusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return AppColors.warning;
      case TicketStatus.inProgress:
        return AppColors.info;
      case TicketStatus.resolved:
        return AppColors.success;
      case TicketStatus.closed:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ticketDetailProvider(ticketId));
    final t = context.t.features.notifications;

    return async.when(
      loading: () => const _DetailLoading(),
      error: (_, _) => _GenericBody(body: fallbackBody),
      data: (ticket) {
        final statusColor = _statusColor(ticket.status);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusPill(
                  label: ticket.status.label(context),
                  color: statusColor,
                  background: statusColor.withValues(alpha: 0.15),
                ),
                const SizedBox(width: AppSizes.spacingS),
                Flexible(
                  child: Text(
                    ticket.category.label(context),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingM),
            if (ticket.apartmentNumber != null)
              _InfoRow(
                label: t.fieldApartment,
                value: ticket.apartmentNumber!,
              ),
            _InfoRow(
              label: t.fieldCreatedAt,
              value: AppDateFormat.dateTimeMedium(ticket.createdAt),
            ),
            const SizedBox(height: AppSizes.spacingS),
            _SectionLabel(t.fieldDescription),
            _SectionBox(
              child: Text(
                ticket.description,
                style: AppTypography.body1.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.45,
                ),
              ),
            ),
            if (ticket.updates.isNotEmpty) ...[
              const SizedBox(height: AppSizes.spacingM),
              _SectionLabel(t.fieldLatestUpdate),
              _SectionBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.updates.last.message,
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppDateFormat.dateShortNoYear(
                        ticket.updates.last.createdAt,
                      ),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Dekont detayı
// ---------------------------------------------------------------------------

class _DekontDetailSection extends ConsumerWidget {
  final String dekontId;
  final String fallbackBody;

  const _DekontDetailSection({
    required this.dekontId,
    required this.fallbackBody,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dekontDetailProvider(dekontId));
    final t = context.t.features.notifications;

    return async.when(
      loading: () => const _DetailLoading(),
      error: (_, _) => _GenericBody(body: fallbackBody),
      data: (DekontEntity dekont) {
        final visual = dekontStatusVisual(context, dekont.status);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusPill(
              label: visual.label,
              color: visual.color,
              background: visual.background,
            ),
            const SizedBox(height: AppSizes.spacingM),
            if (dekont.parsedAmount != null && dekont.parsedAmount!.isNotEmpty)
              _InfoRow(label: t.fieldAmount, value: dekont.parsedAmount!),
            if (dekont.apartment != null)
              _InfoRow(label: t.fieldApartment, value: dekont.apartment!.number),
            if (dekont.uploadedBy != null)
              _InfoRow(
                label: t.fieldUploadedBy,
                value: dekont.uploadedBy!.name,
              ),
            _InfoRow(
              label: t.fieldCreatedAt,
              value: AppDateFormat.dateTimeMedium(dekont.createdAt),
            ),
            if (dekont.rejectionReason != null &&
                dekont.rejectionReason!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.spacingM),
              _SectionLabel(t.fieldRejectionReason),
              _SectionBox(
                background: AppColors.errorBg,
                borderColor: AppColors.error.withValues(alpha: 0.35),
                child: Text(
                  dekont.rejectionReason!,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.error,
                    height: 1.45,
                  ),
                ),
              ),
            ],
            if (dekont.reviewNote != null && dekont.reviewNote!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.spacingM),
              _SectionLabel(t.fieldManagerNote),
              _SectionBox(
                child: Text(
                  dekont.reviewNote!,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Aidat (due) detayı — tekil GET yok; yüklü listeden yerel arama.
// ---------------------------------------------------------------------------

class _DueDetailSection extends ConsumerWidget {
  final String? dueId;
  final String fallbackBody;

  const _DueDetailSection({
    required this.dueId,
    required this.fallbackBody,
  });

  ({String label, Color color, Color background}) _statusVisual(
    BuildContext context,
    DueStatus status,
  ) {
    final c = context.t.common;
    switch (status) {
      case DueStatus.paid:
        return (
          label: c.paidStatus,
          color: AppColors.success,
          background: AppColors.successBg,
        );
      case DueStatus.overdue:
        return (
          label: c.overdueStatus,
          color: AppColors.error,
          background: AppColors.errorBg,
        );
      case DueStatus.pending:
        return (
          label: c.pendingStatus,
          color: AppColors.warning,
          background: AppColors.warningBg,
        );
      case DueStatus.waived:
        return (
          label: c.waivedStatus,
          color: AppColors.textSecondary,
          background: AppColors.fill,
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t.features.notifications;
    DueEntity? due;
    if (dueId != null) {
      for (final d in ref.watch(duesNotifierProvider).dues) {
        if (d.id == dueId) {
          due = d;
          break;
        }
      }
    }

    if (due == null) return _GenericBody(body: fallbackBody);

    final visual = _statusVisual(context, due.status);
    final amount = due.amount == due.amount.roundToDouble()
        ? due.amount.toStringAsFixed(0)
        : due.amount.toStringAsFixed(2);
    final period = AppDateFormat.monthYear(DateTime(due.year, due.month));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusPill(
          label: visual.label,
          color: visual.color,
          background: visual.background,
        ),
        const SizedBox(height: AppSizes.spacingM),
        _InfoRow(label: t.fieldAmount, value: '$amount ${due.currency}'),
        _InfoRow(label: t.fieldPeriod, value: period),
        _InfoRow(label: t.fieldApartment, value: due.apartmentNumber),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Genel gövde (duyuru / sistem / fallback)
// ---------------------------------------------------------------------------

class _GenericBody extends StatelessWidget {
  final String body;

  const _GenericBody({required this.body});

  @override
  Widget build(BuildContext context) {
    return _SectionBox(
      child: Text(
        body,
        style: AppTypography.bodyLarge.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ortak küçük parçalar
// ---------------------------------------------------------------------------

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.spacingL),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _StatusPill({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingXS),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SectionBox extends StatelessWidget {
  final Widget child;
  final Color? background;
  final Color? borderColor;

  const _SectionBox({
    required this.child,
    this.background,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: (background != null
              ? DashboardScreenStyle.whiteCard(color: background)
              : DashboardScreenStyle.whiteCard())
          .copyWith(
        border: borderColor != null
            ? Border.all(color: borderColor!)
            : Border.all(color: AppColors.lineLight),
      ),
      child: child,
    );
  }
}
