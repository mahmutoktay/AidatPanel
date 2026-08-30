import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../l10n/strings.g.dart';
import '../utils/ticket_restriction_reason_parser.dart';

class TicketRestrictionActiveCard extends StatelessWidget {
  const TicketRestrictionActiveCard({
    super.key,
    required this.reason,
    required this.expiresAt,
    this.compact = false,
  });

  final String reason;
  final DateTime expiresAt;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.tickets;
    final parsed = parseTicketRestrictionReason(reason);
    final expiresLabel =
        AppDateFormat.dateShort(expiresAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: parsed.hasStructuredContent
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.block_rounded,
                      size: 20,
                      color: AppColors.statusAmber.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: AppSizes.spacingS),
                    Expanded(
                      child: Text(
                        t.restrictionActiveTitle,
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                if (parsed.ticketTitle != null || parsed.ticketBody != null) ...[
                  const SizedBox(height: AppSizes.spacingM),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.spacingM),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.8),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.restrictionQuotedTicket,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (parsed.ticketTitle != null) ...[
                          const SizedBox(height: AppSizes.spacingXS),
                          Text(
                            parsed.ticketTitle!,
                            style: AppTypography.body1.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.35,
                            ),
                          ),
                        ],
                        if (parsed.ticketBody != null) ...[
                          const SizedBox(height: AppSizes.spacingXS),
                          Text(
                            parsed.ticketBody!,
                            style: AppTypography.body2.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (parsed.managerNote != null) ...[
                  const SizedBox(height: AppSizes.spacingM),
                  Text(
                    t.restrictionManagerNote,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXS),
                  Text(
                    parsed.managerNote!,
                    style: AppTypography.body2.copyWith(height: 1.4),
                  ),
                ],
                const SizedBox(height: AppSizes.spacingM),
                Text(
                  t.restrictionEndsAt.replaceAll('{expiresAt}', expiresLabel),
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.restrictionActiveTitle,
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingS),
                Text(
                  parsed.fallback,
                  style: AppTypography.body2.copyWith(height: 1.4),
                ),
                const SizedBox(height: AppSizes.spacingS),
                Text(
                  t.restrictionEndsAt.replaceAll('{expiresAt}', expiresLabel),
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
    );
  }
}
