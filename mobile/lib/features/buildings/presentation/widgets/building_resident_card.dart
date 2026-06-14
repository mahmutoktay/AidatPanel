import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/user_profile_avatar.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';
import '../utils/apartment_ui_utils.dart';

class BuildingResidentCard extends StatelessWidget {
  final ApartmentEntity apt;
  final bool selectionMode;
  final bool selected;
  final ValueChanged<ApartmentEntity> onToggleSelection;
  final VoidCallback onShowDetails;

  const BuildingResidentCard({
    super.key,
    required this.apt,
    required this.selectionMode,
    required this.selected,
    required this.onToggleSelection,
    required this.onShowDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isOccupied = apt.isOccupied;
    final showSelection = selectionMode && isOccupied;
    final duesStatus = isOccupied
        ? ApartmentUiUtils.getDuesStatusInfo(context, apt.paymentStatus)
        : null;
    final apartmentLabel =
        ApartmentUiUtils.formatApartmentLabel(context, apt.apartmentNumber);
    final duesText = '₺${apt.monthlyDues.toStringAsFixed(0)}';

    const tileRadius = BorderRadius.all(Radius.circular(12));

    final card = Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: tileRadius,
        border: Border.all(
          color: showSelection && selected
              ? AppColors.primary.withValues(alpha: 0.85)
              : AppColors.borderColor.withValues(alpha: 0.14),
          width: showSelection && selected ? 1.5 : 0.5,
        ),
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
                  isVacant: !isOccupied,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apartmentLabel,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOccupied
                            ? apt.residentName
                            : context.t.common.noResidentInApartment,
                        style: AppTypography.body1.copyWith(
                          color: isOccupied
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
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
                if (isOccupied && duesStatus != null)
                  _StatusChip(
                    label: duesStatus.label,
                    color: duesStatus.color,
                    backgroundColor: duesStatus.bgColor,
                  )
                else
                  _StatusChip(
                    label: context.t.common.vacantBadge,
                    color: AppColors.textSecondary,
                    backgroundColor: AppColors.surface,
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
              _DuesActionRow(
                duesText: duesText,
                monthlyDuesLabel: context.t.common.monthlyDues,
                detailsLabel: context.t.common.details,
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
          splashColor: AppColors.border.withValues(alpha: 0.4),
          highlightColor: AppColors.border.withValues(alpha: 0.25),
          onTap: () => onToggleSelection(apt),
          child: card,
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: tileRadius,
        splashColor: AppColors.border.withValues(alpha: 0.4),
        highlightColor: AppColors.border.withValues(alpha: 0.25),
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

class _DuesActionRow extends StatelessWidget {
  const _DuesActionRow({
    required this.duesText,
    required this.monthlyDuesLabel,
    required this.detailsLabel,
  });

  final String duesText;
  final String monthlyDuesLabel;
  final String detailsLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                duesText,
                style: AppTypography.body1.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                monthlyDuesLabel,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(
          height: AppSizes.minTouchTarget,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                detailsLabel,
                style: AppTypography.body2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textSecondary.withValues(alpha: 0.85),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
