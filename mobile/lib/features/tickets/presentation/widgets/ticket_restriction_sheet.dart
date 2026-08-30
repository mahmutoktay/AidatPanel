import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/entities/ticket_restriction_entity.dart';
import '../providers/ticket_restriction_provider.dart';
import '../providers/tickets_provider.dart';
import 'ticket_restriction_active_card.dart';

class TicketRestrictionSheet {
  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required String apartmentId,
    required String buildingId,
    required TicketRestrictionStatusEntity initialStatus,
  }) {
    return PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (sheetContext) => _TicketRestrictionSheetBody(
        pageContext: context,
        sheetContext: sheetContext,
        ref: ref,
        apartmentId: apartmentId,
        buildingId: buildingId,
        initialStatus: initialStatus,
      ),
    );
  }
}

class _TicketRestrictionSheetBody extends ConsumerStatefulWidget {
  const _TicketRestrictionSheetBody({
    required this.pageContext,
    required this.sheetContext,
    required this.ref,
    required this.apartmentId,
    required this.buildingId,
    required this.initialStatus,
  });

  final BuildContext pageContext;
  final BuildContext sheetContext;
  final WidgetRef ref;
  final String apartmentId;
  final String buildingId;
  final TicketRestrictionStatusEntity initialStatus;

  @override
  ConsumerState<_TicketRestrictionSheetBody> createState() =>
      _TicketRestrictionSheetBodyState();
}

class _TicketRestrictionSheetBodyState
    extends ConsumerState<_TicketRestrictionSheetBody> {
  final _noteController = TextEditingController();
  bool _submitting = false;
  bool _loadingTickets = true;
  late TicketRestrictionStatusEntity _status;
  List<TicketEntity> _tickets = [];
  String? _selectedTicketId;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTickets());
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    setState(() => _loadingTickets = true);
    try {
      final result = await widget.ref
          .read(ticketRepositoryProvider)
          .getBuildingTickets(widget.buildingId, paginated: false);
      if (!mounted) return;
      setState(() {
        _tickets = result.items
            .where((ticket) => ticket.apartmentId == widget.apartmentId)
            .toList(growable: false);
        _loadingTickets = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingTickets = false);
    }
  }

  Future<void> _applyRestriction() async {
    final t = widget.pageContext.t.features.tickets;
    final ticketId = _selectedTicketId;
    if (ticketId == null || ticketId.isEmpty) {
      widget.ref.read(toastProvider.notifier).show(
            t.restrictionTicketRequired,
            type: ToastType.error,
          );
      return;
    }

    setState(() => _submitting = true);
    try {
      final result = await widget.ref
          .read(ticketRepositoryProvider)
          .createApartmentTicketRestriction(
            apartmentId: widget.apartmentId,
            ticketId: ticketId,
            note: _noteController.text.trim(),
          );
      ref.invalidate(apartmentTicketRestrictionProvider(widget.apartmentId));
      if (!widget.sheetContext.mounted) return;
      setState(() {
        _status = result;
        _selectedTicketId = null;
        _noteController.clear();
      });
      widget.ref.read(toastProvider.notifier).show(
            t.restrictionApplied,
            type: ToastType.success,
          );
    } on ApiException catch (e) {
      if (mounted) {
        widget.ref.read(toastProvider.notifier).show(
              userFacingError(e),
              type: ToastType.error,
            );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _liftRestriction() async {
    setState(() => _submitting = true);
    try {
      await widget.ref
          .read(ticketRepositoryProvider)
          .liftApartmentTicketRestriction(widget.apartmentId);
      ref.invalidate(apartmentTicketRestrictionProvider(widget.apartmentId));
      if (!widget.sheetContext.mounted) return;
      setState(() => _status = const TicketRestrictionStatusEntity(active: false));
      widget.ref.read(toastProvider.notifier).show(
            widget.pageContext.t.features.tickets.restrictionLifted,
            type: ToastType.success,
          );
      Navigator.of(widget.sheetContext).pop();
    } on ApiException catch (e) {
      if (mounted) {
        widget.ref.read(toastProvider.notifier).show(
              userFacingError(e),
              type: ToastType.error,
            );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.tickets;
    final active = _status.active ? _status.restriction : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacingL,
        AppSizes.spacingS,
        AppSizes.spacingL,
        AppSizes.spacingL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.restrictionSheetTitle,
            style: AppTypography.h4.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSizes.spacingM),
          if (active != null) ...[
            TicketRestrictionActiveCard(
              reason: active.reason,
              expiresAt: active.expiresAt,
            ),
            const SizedBox(height: AppSizes.spacingM),
            SizedBox(
              height: AppSizes.buttonHeightSecondary,
              child: OutlinedButton(
                onPressed: _submitting ? null : _liftRestriction,
                child: Text(t.restrictionLiftAction),
              ),
            ),
          ] else ...[
            Text(
              t.restrictionSheetSubtitle,
              style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              t.restrictionSelectTicket,
              style: AppTypography.body1.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSizes.spacingS),
            if (_loadingTickets)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSizes.spacingL),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_tickets.isEmpty)
              Text(
                t.restrictionNoTickets,
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = _tickets[index];
                    final preview = ticket.description.trim().isNotEmpty
                        ? ticket.description.trim().split('\n').first
                        : ticket.title;
                    return RadioListTile<String>(
                      value: ticket.id,
                      groupValue: _selectedTicketId,
                      onChanged: _submitting
                          ? null
                          : (value) => setState(() => _selectedTicketId = value),
                      title: Text(
                        preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        AppDateFormat.dateShort(ticket.createdAt),
                        style: AppTypography.caption,
                      ),
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
              ),
            const SizedBox(height: AppSizes.spacingM),
            TextField(
              controller: _noteController,
              enabled: !_submitting,
              maxLength: 300,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: t.restrictionNoteLabel,
                hintText: t.restrictionNoteHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            SizedBox(
              height: AppSizes.buttonHeightPrimary,
              child: FilledButton(
                onPressed: _submitting || _tickets.isEmpty ? null : _applyRestriction,
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(t.restrictionApplyAction),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
