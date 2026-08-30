import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';

class TicketModerationBadges extends StatelessWidget {
  const TicketModerationBadges({
    super.key,
    required this.isReported,
    required this.needsReview,
  });

  final bool isReported;
  final bool needsReview;

  @override
  Widget build(BuildContext context) {
    if (!isReported && !needsReview) return const SizedBox.shrink();

    final t = context.t.features.tickets;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (isReported) _badge(t.badgeReported, AppColors.statusRed),
        if (needsReview) _badge(t.badgeNeedsReview, AppColors.statusAmber),
      ],
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
