import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/month_labels.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../utils/ticket_labels.dart';
import '../utils/ticket_status_style.dart';
import '../../domain/entities/ticket_entity.dart';

class ResidentApplicationCard extends StatelessWidget {
  const ResidentApplicationCard({
    super.key,
    required this.ticket,
    this.onTap,
  });

  final TicketEntity ticket;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = ticketStatusColor(ticket.status);
    final date =
        '${ticket.createdAt.day} ${localizedMonthName(context, ticket.createdAt.month)} ${ticket.createdAt.year}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
        child: Ink(
          decoration: DashboardScreenStyle.whiteCard(),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacingM),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.assignment_outlined,
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.description.trim().isNotEmpty
                            ? ticket.description.trim().split('\n').first
                            : ticket.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ticket.status.residentLabel(context),
                    style: AppTypography.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
