import 'package:flutter/material.dart';
import '../../../../shared/widgets/action_chevron.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../domain/entities/ticket_entity.dart';
import '../utils/ticket_labels.dart';
import '../utils/ticket_status_style.dart';
import 'ticket_moderation_badges.dart';

class TicketListCard extends StatelessWidget {
  final TicketEntity ticket;
  final VoidCallback? onTap;
  final String? subtitlePrefix;
  /// Sakin listesi: daire/kategori satırı gizlenir.
  final bool showSubtitleMeta;

  const TicketListCard({
    super.key,
    required this.ticket,
    this.onTap,
    this.subtitlePrefix,
    this.showSubtitleMeta = true,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = ticketStatusColor(ticket.status);
    final date =
        '${ticket.createdAt.day}.${ticket.createdAt.month}.${ticket.createdAt.year}';
    final apt = ticket.apartmentNumber?.trim();
    final meta = showSubtitleMeta
        ? [
            if (subtitlePrefix != null && subtitlePrefix!.isNotEmpty)
              subtitlePrefix,
            if (apt != null && apt.isNotEmpty) apt,
            ticket.category.label(context),
          ].join(' · ')
        : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
        child: Ink(
          decoration: DashboardScreenStyle.whiteCard().copyWith(
            border: Border.all(
              color: statusColor.withValues(alpha: 0.15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.cardPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _categoryIcon(ticket.category),
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ticket.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.h4.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacingS),
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
                              ticket.status.label(context),
                              style: AppTypography.caption.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (meta.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.spacingXS),
                        Text(
                          meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSizes.spacingS),
                      TicketModerationBadges(
                        isReported: ticket.isReported,
                        needsReview: ticket.needsReview,
                      ),
                      if (ticket.isReported || ticket.needsReview)
                        const SizedBox(height: AppSizes.spacingXS),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 14,
                            color: AppColors.textDisabled,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textDisabled,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const ActionChevron(),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
}
