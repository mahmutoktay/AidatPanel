import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../domain/entities/ticket_entity.dart';
import '../utils/ticket_labels.dart';
import '../utils/ticket_status_rules.dart';

class TicketDetailManagerActions extends StatelessWidget {
  final TicketEntity ticket;
  final TextEditingController noteController;
  final bool submitting;
  final TicketStatus? selectedStatus;
  final ValueChanged<TicketStatus?> onStatusChanged;
  final VoidCallback onNoteChanged;
  final VoidCallback onSubmit;

  const TicketDetailManagerActions({
    super.key,
    required this.ticket,
    required this.noteController,
    required this.submitting,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onNoteChanged,
    required this.onSubmit,
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
        return AppColors.textPrimary;
    }
  }

  Widget _buildTemplateChip(
    BuildContext context,
    String label,
    String templateText,
  ) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        noteController.text = templateText;
        onNoteChanged();
      },
      backgroundColor: AppColors.primary.withValues(alpha: 0.05),
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.12)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: AppTypography.caption.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w800,
        fontSize: 11,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.tickets;
    final nextStatuses = allowedNextStatuses(ticket.status);
    final noteEnabled = canAddManagerNote(ticket.status) && !submitting;

    return Container(
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
          if (canChangeStatus(ticket.status) && nextStatuses.isNotEmpty) ...[
            Text(
              t.changeStatus,
              textAlign: TextAlign.center,
              style: AppTypography.h4.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: AppSizes.spacingM),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSizes.spacingS,
              runSpacing: AppSizes.spacingS,
              children: nextStatuses.map((s) {
                final isSelected = selectedStatus == s;
                final color = _statusColor(s);
                return ChoiceChip(
                  label: Text(s.label(context)),
                  selected: isSelected,
                  onSelected: submitting
                      ? null
                      : (selected) {
                          onStatusChanged(selected ? s : null);
                        },
                  selectedColor: color.withValues(alpha: 0.18),
                  backgroundColor: AppColors.fill,
                  side: BorderSide(
                    color: isSelected
                        ? color
                        : AppColors.border.withValues(alpha: 0.8),
                    width: isSelected ? 1.5 : 1,
                  ),
                  labelStyle: AppTypography.body2.copyWith(
                    color: isSelected ? color : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),
          ],
          if (ticket.status == TicketStatus.closed) ...[
            const SizedBox(height: AppSizes.spacingS),
            Text(
              t.statusClosedHint,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: AppSizes.spacingL),
          Text(
            t.managerNoteOptional,
            textAlign: TextAlign.center,
            style: AppTypography.h4.copyWith(fontWeight: FontWeight.w900),
          ),
          if (noteEnabled) ...[
            const SizedBox(height: AppSizes.spacingM),
            Text(
              t.quickReplyTemplatesTitle.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: AppSizes.spacingS),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTemplateChip(
                  context,
                  t.templateTeamDispatched,
                  t.templateTeamDispatchedText,
                ),
                _buildTemplateChip(
                  context,
                  t.templateWaitingPart,
                  t.templateWaitingPartText,
                ),
                _buildTemplateChip(
                  context,
                  t.templateAppointmentSet,
                  t.templateAppointmentSetText,
                ),
                _buildTemplateChip(
                  context,
                  t.templateResolvedCheck,
                  t.templateResolvedCheckText,
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSizes.spacingM),
          TextField(
            controller: noteController,
            maxLines: 4,
            enabled: noteEnabled,
            onChanged: (_) => onNoteChanged(),
            textAlign: TextAlign.center,
            style: AppTypography.body1.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: noteEnabled ? t.managerNoteOptional : t.noteDisabledClosed,
              hintStyle: AppTypography.body1.copyWith(
                color: AppColors.textDisabled,
              ),
              filled: true,
              fillColor: AppColors.fill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.all(AppSizes.spacingM),
            ),
          ),
          const SizedBox(height: AppSizes.spacingL),
          Center(
            child: SizedBox(
              height: AppSizes.buttonHeightSecondary,
              child: FilledButton.icon(
                onPressed:
                    (selectedStatus != null ||
                            noteController.text.trim().isNotEmpty) &&
                        !submitting
                    ? onSubmit
                    : null,
                icon: submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline, size: 20),
                label: Text(t.confirmChanges),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.actionButton,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: AppTypography.button,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
