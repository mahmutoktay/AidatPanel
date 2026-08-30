import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/list_cache_refresh.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/ticket_entity.dart';
import '../providers/tickets_provider.dart';
import '../widgets/ticket_detail_content_card.dart';
import '../widgets/ticket_detail_bottom_toolbar.dart';
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
  bool _submitting = false;
  bool _reporting = false;
  bool _reportSubmitted = false;

  Future<void> _reportTicket({String? ticketUpdateId}) async {
    if (_reporting) return;
    setState(() => _reporting = true);
    try {
      await ref.read(ticketRepositoryProvider).reportTicket(
            ticketId: widget.ticketId,
            ticketUpdateId: ticketUpdateId,
          );
      ref.invalidate(ticketDetailProvider(widget.ticketId));
      invalidateTicketsRelatedCaches(ref);
      if (!mounted) return;
      setState(() => _reportSubmitted = true);
      ref.read(toastProvider.notifier).show(
            context.t.features.tickets.reportSuccess,
            type: ToastType.success,
          );
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
      if (mounted) setState(() => _reporting = false);
    }
  }

  Future<void> _reload() async {
    ref.invalidate(ticketDetailProvider(widget.ticketId));
    await ref.read(ticketDetailProvider(widget.ticketId).future);
  }

  Future<void> _applyStatus({
    required String ticketId,
    required TicketStatus fromStatus,
    required TicketStatus toStatus,
    bool offerUndo = true,
  }) async {
    if (_submitting || fromStatus == toStatus) return;

    setState(() => _submitting = true);
    try {
      await ref.read(ticketRepositoryProvider).updateTicketStatus(
            ticketId: ticketId,
            status: toStatus,
          );
      ref.invalidate(ticketDetailProvider(ticketId));
      invalidateTicketsRelatedCaches(ref);

      if (!mounted) return;

      final t = context.t.features.tickets;
      ScaffoldMessenger.of(context).clearSnackBars();
      if (offerUndo) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.statusUpdated),
            duration: const Duration(seconds: 5),
            // Flutter 3.44+: aksiyonlu SnackBar varsayılan persist:true —
            // süre dolunca kaybolmaz; geri alma için süreye izin ver.
            persist: false,
            action: SnackBarAction(
              label: t.undo,
              onPressed: () {
                _applyStatus(
                  ticketId: ticketId,
                  fromStatus: toStatus,
                  toStatus: fromStatus,
                  offerUndo: false,
                );
              },
            ),
          ),
        );
      } else {
        ref.read(toastProvider.notifier).show(
              t.statusUpdated,
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
      bottomNavigationBar: detail.maybeWhen(
        data: (ticket) {
          final canReport = !ticket.isReported &&
              !_reportSubmitted &&
              isManager;
          if (!canReport) return null;
          return TicketDetailBottomToolbar(
            isSubmitting: _reporting,
            onReport: () => _reportTicket(),
          );
        },
        orElse: () => null,
      ),
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
          color: AppColors.brand,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSizes.screenBodyScrollPadding,
            children: [
              if (isManager) ...[
                TicketDetailResidentInfoCard(ticket: ticket),
                const SizedBox(height: AppSizes.spacingM),
              ],
              TicketDetailContentCard(
                ticket: ticket,
                showStatusChip: true,
              ),
              if (ticket.updates.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spacingL),
                TicketDetailUpdatesTimeline(
                  updates: ticket.updates,
                  viewerIsResident: !isManager,
                  onReportUpdate: ticket.isReported || _reportSubmitted
                      ? null
                      : isManager
                      ? (updateId, fromRole) {
                          if (fromRole == 'RESIDENT') {
                            _reportTicket(ticketUpdateId: updateId);
                          }
                        }
                      : (updateId, fromRole) {
                          if (fromRole == 'MANAGER') {
                            _reportTicket(ticketUpdateId: updateId);
                          }
                        },
                ),
              ],
              if (!isManager) ...[
                const SizedBox(height: AppSizes.spacingL),
                TicketStatusStepper(currentStatus: ticket.status),
              ],
              if (isManager) ...[
                const SizedBox(height: AppSizes.spacingL),
                TicketDetailManagerActions(
                  ticket: ticket,
                  submitting: _submitting,
                  onAction: (next) => _applyStatus(
                    ticketId: ticket.id,
                    fromStatus: ticket.status,
                    toStatus: next,
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
