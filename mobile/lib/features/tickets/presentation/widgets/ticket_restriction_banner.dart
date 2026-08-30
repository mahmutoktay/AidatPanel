import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../domain/entities/ticket_restriction_entity.dart';
import 'ticket_restriction_active_card.dart';

class TicketRestrictionBanner extends StatelessWidget {
  const TicketRestrictionBanner({
    super.key,
    required this.restriction,
  });

  final TicketRestrictionEntity restriction;

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.tickets;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: AppColors.statusAmber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.statusAmber.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: AppColors.statusAmber, size: 22),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: Text(
                  t.restrictionBannerIntro,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),
          TicketRestrictionActiveCard(
            reason: restriction.reason,
            expiresAt: restriction.expiresAt,
            compact: true,
          ),
        ],
      ),
    );
  }
}
