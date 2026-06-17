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
    final email = ticket.residentEmail ?? '';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Text(
                t.residentInfoTitle.toUpperCase(),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 12),
              UserProfileAvatar(
                userName: name,
                profilePicture: ticket.residentProfilePicture,
                size: 110,
              ),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      apartmentLabel,
                      textAlign: TextAlign.center,
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                    if (phone.isNotEmpty || email.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      if (phone.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.phone_outlined,
                                size: 15,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                phone,
                                style: AppTypography.body1.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (email.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.mail_outline_rounded,
                                size: 15,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                email,
                                style: AppTypography.body1.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
