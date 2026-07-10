import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/user_profile_avatar.dart';
import '../../domain/entities/ticket_entity.dart';

class TicketDetailResidentInfoCard extends StatelessWidget {
  final TicketEntity ticket;

  const TicketDetailResidentInfoCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.tickets;
    final name =
        ticket.residentName ?? ticket.creatorName ?? t.defaultResidentName;
    final phone = ticket.residentPhone ?? '';
    final apt = ticket.apartmentNumber ?? '';
    final apartmentLabel = apt.isNotEmpty
        ? t.apartmentNumberTag.replaceAll('{number}', apt)
        : t.apartmentInfoMissing;

    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: DashboardScreenStyle.whiteCard().copyWith(
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UserProfileAvatar(
            userName: name,
            profilePicture: ticket.residentProfilePicture,
            size: 88,
          ),
          const SizedBox(width: AppSizes.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  apartmentLabel,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          phone,
                          style: AppTypography.body1.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
