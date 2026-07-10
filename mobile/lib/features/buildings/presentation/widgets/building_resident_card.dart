import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/user_profile_avatar.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';
import '../utils/apartment_ui_utils.dart';
import 'building_summary_card.dart';

class BuildingResidentCard extends StatelessWidget {
  final ApartmentEntity apt;
  final bool selectionMode;
  final bool selected;
  final ValueChanged<ApartmentEntity> onToggleSelection;
  final VoidCallback onShowDetails;
  final VoidCallback? onInvite;

  const BuildingResidentCard({
    super.key,
    required this.apt,
    required this.selectionMode,
    required this.selected,
    required this.onToggleSelection,
    required this.onShowDetails,
    this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    final isOccupied = apt.isOccupied;

    if (!isOccupied && !selectionMode) {
      return _VacantApartmentCard(
        apt: apt,
        onTap: onShowDetails,
        onInvite: onInvite,
      );
    }

    return _OccupiedResidentCard(
      apt: apt,
      selectionMode: selectionMode,
      selected: selected,
      onToggleSelection: onToggleSelection,
      onShowDetails: onShowDetails,
    );
  }
}

class _VacantApartmentCard extends StatelessWidget {
  const _VacantApartmentCard({
    required this.apt,
    required this.onTap,
    this.onInvite,
  });

  final ApartmentEntity apt;
  final VoidCallback onTap;
  final VoidCallback? onInvite;

  @override
  Widget build(BuildContext context) {
    final apartmentLabel =
        ApartmentUiUtils.formatApartmentLabel(context, apt.apartmentNumber);
    const tileRadius = BorderRadius.all(Radius.circular(20));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: tileRadius,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingM,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: tileRadius,
            boxShadow: BuildingSummaryCard.cardShadow,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apartmentLabel,
                      style: AppTypography.body1.copyWith(
                        color: AppColors.inkDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.t.common.emptyApartment,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (onInvite != null) ...[
                const SizedBox(width: 8),
                SizedBox(
                  height: AppSizes.minTouchTarget,
                  child: TextButton(
                    onPressed: onInvite,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(48, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text(
                      context.t.common.inviteResident,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OccupiedResidentCard extends StatelessWidget {
  const _OccupiedResidentCard({
    required this.apt,
    required this.selectionMode,
    required this.selected,
    required this.onToggleSelection,
    required this.onShowDetails,
  });

  final ApartmentEntity apt;
  final bool selectionMode;
  final bool selected;
  final ValueChanged<ApartmentEntity> onToggleSelection;
  final VoidCallback onShowDetails;

  @override
  Widget build(BuildContext context) {
    final showSelection = selectionMode;
    final duesStatus =
        ApartmentUiUtils.getDuesStatusInfo(context, apt.paymentStatus);
    final apartmentLabel =
        ApartmentUiUtils.formatApartmentLabel(context, apt.apartmentNumber);
    final duesText = '₺${apt.monthlyDues.toStringAsFixed(0)}';

    const tileRadius = BorderRadius.all(Radius.circular(20));

    final card = Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: tileRadius,
        boxShadow: BuildingSummaryCard.cardShadow,
        border: showSelection && selected
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.85),
                width: 1.5,
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showSelection) ...[
                  SizedBox(
                    width: AppSizes.minTouchTarget,
                    height: AppSizes.minTouchTarget,
                    child: Icon(
                      selected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingS),
                ],
                UserProfileAvatar(
                  userId: apt.resident?.id,
                  userName: apt.residentName,
                  profilePicture: apt.resident?.profilePicture,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apartmentLabel,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.mutedText,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        apt.residentName,
                        style: AppTypography.body1.copyWith(
                          color: AppColors.inkDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  label: duesStatus.label,
                  color: duesStatus.color,
                  backgroundColor: duesStatus.bgColor,
                ),
              ],
            ),
            if (showSelection) ...[
              const SizedBox(height: AppSizes.spacingS),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$duesText · ${context.t.common.monthlyDues}',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: AppSizes.spacingM),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          duesText,
                          style: AppTypography.body1.copyWith(
                            color: AppColors.inkDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          context.t.common.monthlyDues,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.mutedText,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    context.t.common.details,
                    style: AppTypography.body2.copyWith(
                      color: AppColors.inkDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 22),
                ],
              ),
            ],
          ],
        ),
      ),
    );

    if (showSelection) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: tileRadius,
          onTap: () => onToggleSelection(apt),
          child: card,
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: tileRadius,
        onTap: onShowDetails,
        child: card,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          height: 1.2,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}
