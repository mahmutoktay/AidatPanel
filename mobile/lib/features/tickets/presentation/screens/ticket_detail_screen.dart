import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/ticket_entity.dart';
import '../providers/manager_open_tickets_count_provider.dart';
import '../providers/tickets_provider.dart';
import '../utils/ticket_labels.dart';
import '../widgets/ticket_detail_manager_actions.dart';
import '../widgets/ticket_detail_resident_info_card.dart';
import '../widgets/ticket_detail_timeline.dart';
import '../widgets/ticket_status_stepper.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final _noteController = TextEditingController();
  bool _submitting = false;
  TicketStatus? _selectedStatus;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    ref.invalidate(ticketDetailProvider(widget.ticketId));
    await ref.read(ticketDetailProvider(widget.ticketId).future);
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(ticketDetailProvider(widget.ticketId));
    final isManager =
        ref.watch(authStateProvider.select((state) => state.user?.role)) ==
        UserRole.manager;
    final t = context.t.features.tickets;

    return DashboardSecondaryScaffold(
      title: t.detailTitle,
      fallbackRoute: isManager ? '/manager-dashboard/tickets' : null,
      onFallback: isManager
          ? null
          : () {
              ref.read(residentTabIndexProvider.notifier).update(2);
              context.go('/resident-dashboard');
            },
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: AppSizes.screenBodyScrollPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(userFacingError(e), textAlign: TextAlign.center),
                const SizedBox(height: AppSizes.spacingM),
                FilledButton(
                  onPressed: _reload,
                  child: Text(context.t.common.tryAgain),
                ),
              ],
            ),
          ),
        ),
        data: (ticket) => RefreshIndicator(
          onRefresh: _reload,
          color: AppColors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSizes.screenBodyScrollPadding,
            children: [
              _TicketHeaderCard(
                ticket: ticket,
                showSubtitleMeta: isManager,
                showStatusChip: isManager,
              ),
              const SizedBox(height: AppSizes.spacingM),
              if (isManager) ...[
                TicketDetailResidentInfoCard(ticket: ticket),
                const SizedBox(height: AppSizes.spacingM),
              ],
              _SurfaceSection(
                title: context.t.features.tickets.fieldDescription,
                child: Text(
                  ticket.description,
                  textAlign: TextAlign.center,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.45,
                  ),
                ),
              ),
              if (ticket.updates.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spacingL),
                Text(
                  t.updatesTitle,
                  style: AppTypography.h4.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingM),
                TicketDetailUpdatesTimeline(updates: ticket.updates),
              ],
              if (!isManager) ...[
                const SizedBox(height: AppSizes.spacingL),
                TicketStatusStepper(currentStatus: ticket.status),
              ],
              if (isManager) ...[
                const SizedBox(height: AppSizes.spacingL),
                TicketDetailManagerActions(
                  ticket: ticket,
                  noteController: _noteController,
                  submitting: _submitting,
                  selectedStatus: _selectedStatus,
                  onStatusChanged: (status) {
                    setState(() {
                      _selectedStatus = status;
                    });
                  },
                  onNoteChanged: () {
                    setState(() {});
                  },
                  onSubmit: () => _onSubmitChanges(ticket.id, ticket.status),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmitChanges(
    String ticketId,
    TicketStatus originalStatus,
  ) async {
    final status = _selectedStatus;
    final cleanNote = _noteController.text.trim();
    if (status == null && cleanNote.isEmpty) return;

    setState(() => _submitting = true);
    try {
      if (status != null && status != originalStatus) {
        await ref
            .read(ticketRepositoryProvider)
            .updateTicketStatus(ticketId: ticketId, status: status);
      }
      if (cleanNote.isNotEmpty) {
        await ref
            .read(ticketRepositoryProvider)
            .addManagerUpdate(ticketId: ticketId, message: cleanNote);
        _noteController.clear();
      }
      ref.invalidate(ticketDetailProvider(ticketId));
      ref.invalidate(managerOpenTicketsCountProvider);

      setState(() {
        _selectedStatus = null;
      });

      if (mounted) {
        ref
            .read(toastProvider.notifier)
            .show(
              context.t.features.tickets.statusUpdated,
              type: ToastType.success,
            );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ref
            .read(toastProvider.notifier)
            .show(userFacingError(e), type: ToastType.error);
      }
    } catch (e) {
      if (mounted) {
        ref
            .read(toastProvider.notifier)
            .show(userFacingError(e), type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _TicketHeaderCard extends StatelessWidget {
  final TicketEntity ticket;
  final bool showSubtitleMeta;
  final bool showStatusChip;

  const _TicketHeaderCard({
    required this.ticket,
    this.showSubtitleMeta = true,
    this.showStatusChip = true,
  });

  IconData _categoryIcon(TicketCategory category) {
    switch (category) {
      case TicketCategory.complaint:
        return Icons.report_problem_outlined;
      case TicketCategory.request:
        return Icons.handyman_outlined;
      case TicketCategory.malfunction:
        return Icons.build_circle_outlined;
      case TicketCategory.other:
        return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(ticket.status);
    final date =
        '${ticket.createdAt.day}.${ticket.createdAt.month}.${ticket.createdAt.year}';
    final apt = ticket.apartmentNumber?.trim();
    final meta = showSubtitleMeta
        ? [
            if (apt != null && apt.isNotEmpty) apt,
            ticket.category.label(context),
          ].join(' · ')
        : ticket.category.label(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding * 1.25),
      decoration: DashboardScreenStyle.whiteCard().copyWith(
        border: Border.all(
          color: statusColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withValues(alpha: 0.16),
                      statusColor.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  _categoryIcon(ticket.category),
                  color: statusColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.title,
                      style: AppTypography.h3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        meta,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),
          Divider(color: AppColors.lineLight, height: 1),
          const SizedBox(height: AppSizes.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 16,
                    color: AppColors.textDisabled,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    date,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textDisabled,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (showStatusChip)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    ticket.status.label(context).toUpperCase(),
                    style: AppTypography.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

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
}

class _SurfaceSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SurfaceSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: DashboardScreenStyle.whiteCard().copyWith(
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.fill,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Text(
                title.toUpperCase(),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingL),
          child,
        ],
      ),
    );
  }
}
