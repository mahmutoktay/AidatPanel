import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/strings.g.dart';
import '../../../../../shared/widgets/action_chevron.dart';
import '../../../domain/resident_home_activity_item.dart';
import '../../../../dues/domain/entities/due_entity.dart';
import '../../../../notifications/domain/entities/notification_entity.dart';
import '../../../../dues/domain/entities/due_transaction_entity.dart';
import 'resident_home_activity_row.dart';

class ResidentRecentActivitySection extends StatelessWidget {
  static const int previewLimit = 5;

  const ResidentRecentActivitySection({
    super.key,
    required this.transactions,
    required this.announcements,
    required this.dues,
    required this.isLoading,
    required this.onOpenAnnouncement,
  });

  final List<DueTransactionEntity> transactions;
  final List<NotificationEntity> announcements;
  final List<DueEntity> dues;
  final bool isLoading;
  final void Function(NotificationEntity notification) onOpenAnnouncement;

  @override
  Widget build(BuildContext context) {
    final t = context.t.common;
    final feed = buildResidentHomeActivityFeed(
      transactions: transactions,
      announcements: announcements,
    );
    final preview = feed.take(previewLimit).toList(growable: false);
    final duesById = duesByIdMap(dues);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                t.recentMovements,
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ),
            TextButton(
                onPressed: () =>
                    context.push('/resident-dashboard/activity-history'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.chartBlue,
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t.seeAll,
                      style: AppTypography.body2.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const ActionChevron(size: 20),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingS),
        if (isLoading && preview.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.spacingL),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (preview.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.t.features.dues.transactions.residentEmptyTitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingXS),
                Text(
                  context.t.features.dues.transactions.residentEmptySubtitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              for (final item in preview)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
                  child: ResidentHomeActivityRow(
                    item: item,
                    duesById: duesById,
                    onTap: _onTap(context, item),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  VoidCallback? _onTap(BuildContext context, ResidentHomeActivityItem item) {
    final transaction = item.transaction;
    if (transaction?.dekontId != null) {
      return () => context.push('/dekonts/${transaction!.dekontId}');
    }
    final announcement = item.announcement;
    if (announcement != null) {
      return () => onOpenAnnouncement(announcement);
    }
    return null;
  }
}
