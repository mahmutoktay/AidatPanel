import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../domain/entities/ticket_update_entity.dart';

class TicketDetailUpdatesTimeline extends StatelessWidget {
  final List<TicketUpdateEntity> updates;
  final bool viewerIsResident;

  const TicketDetailUpdatesTimeline({
    super.key,
    required this.updates,
    this.viewerIsResident = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < updates.length; i++)
          TicketDetailTimelineEntry(
            update: updates[i],
            isLast: i == updates.length - 1,
            viewerIsResident: viewerIsResident,
          ),
      ],
    );
  }
}

class TicketDetailTimelineEntry extends StatelessWidget {
  final TicketUpdateEntity update;
  final bool isLast;
  final bool viewerIsResident;

  const TicketDetailTimelineEntry({
    super.key,
    required this.update,
    required this.isLast,
    this.viewerIsResident = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.tickets;
    final dateStr = AppDateFormat.dateShort(update.createdAt);
    final isManagerUpdate = update.fromRole == 'MANAGER';
    final themeColor = isManagerUpdate ? AppColors.brand : AppColors.success;
    final roleText = viewerIsResident
        ? (isManagerUpdate
            ? t.managerUpdateForResident
            : t.residentUpdateLabel)
        : (isManagerUpdate ? t.managerUpdateLabel : t.residentUpdateLabel);
    final roleBg = themeColor.withValues(alpha: 0.08);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 6),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: themeColor, width: 2.5),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: themeColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.border.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSizes.spacingM),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.spacingL),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.spacingM),
                decoration: DashboardScreenStyle.whiteCard().copyWith(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: themeColor.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: roleBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: themeColor.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            roleText.toUpperCase(),
                            style: AppTypography.body2.copyWith(
                              color: themeColor,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Text(
                          dateStr,
                          style: AppTypography.body2.copyWith(
                            color: AppColors.textDisabled,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    Text(
                      update.message,
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
