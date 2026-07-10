import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../domain/entities/ticket_entity.dart';
import '../utils/ticket_status_rules.dart';

/// Yönetici talep detayı — duruma göre tek dokunuşlu aksiyon butonları.
class TicketDetailManagerActions extends StatelessWidget {
  final TicketEntity ticket;
  final bool submitting;
  final ValueChanged<TicketStatus> onAction;

  const TicketDetailManagerActions({
    super.key,
    required this.ticket,
    required this.submitting,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final targets = managerActionTargets(ticket.status);
    if (targets.isEmpty) return const SizedBox.shrink();

    final t = context.t.features.tickets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ticket.status == TicketStatus.open) ...[
          SizedBox(
            height: AppSizes.buttonHeightPrimary,
            child: FilledButton(
              onPressed: submitting
                  ? null
                  : () => onAction(TicketStatus.inProgress),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.success.withValues(
                  alpha: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: AppTypography.button,
              ),
              child: submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(t.actionApprove),
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          SizedBox(
            height: AppSizes.buttonHeightPrimary,
            child: OutlinedButton(
              onPressed: submitting
                  ? null
                  : () => onAction(TicketStatus.closed),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: AppTypography.button,
              ),
              child: Text(t.actionReject),
            ),
          ),
        ] else if (ticket.status == TicketStatus.inProgress) ...[
          SizedBox(
            height: AppSizes.buttonHeightPrimary,
            child: FilledButton(
              onPressed: submitting
                  ? null
                  : () => onAction(TicketStatus.resolved),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.success.withValues(
                  alpha: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: AppTypography.button,
              ),
              child: submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(t.actionMarkDone),
            ),
          ),
        ],
      ],
    );
  }
}
