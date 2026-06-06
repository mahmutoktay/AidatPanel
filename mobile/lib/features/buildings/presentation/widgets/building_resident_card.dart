import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/tint_dashboard_tile.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';
import '../utils/apartment_ui_utils.dart';

class BuildingResidentCard extends StatelessWidget {
  final int index;
  final ApartmentEntity apt;
  final bool selectionMode;
  final bool selected;
  final ValueChanged<ApartmentEntity> onToggleSelection;
  final VoidCallback onShowDetails;

  const BuildingResidentCard({
    super.key,
    required this.index,
    required this.apt,
    required this.selectionMode,
    required this.selected,
    required this.onToggleSelection,
    required this.onShowDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isOccupied = apt.isOccupied;
    final statusInfo = ApartmentUiUtils.getStatusInfo(context, apt.paymentStatus);
    final showSelection = selectionMode && isOccupied;

    const tileRadius = BorderRadius.all(Radius.circular(12));
    final perMonthLabel = context.t.common.perMonth
        .trim()
        .replaceAll('/', '')
        .trim();

    final card = Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: tileRadius,
        border: showSelection && selected
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isOccupied
                          ? AppColors.primary.withValues(alpha: 0.18)
                          : AppColors.borderColor.withValues(alpha: 0.6),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isOccupied
                      ? Text(
                          '$index',
                          style: AppTypography.body1.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        )
                      : Icon(
                          Icons.person_off_outlined,
                          size: 24,
                          color: AppColors.textSecondary,
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ApartmentUiUtils.formatApartmentLabel(context, apt.apartmentNumber),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOccupied
                            ? apt.residentName
                            : context.t.common.emptyApartmentText,
                        style: AppTypography.body1.copyWith(
                          color: isOccupied
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          fontStyle: isOccupied
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isOccupied)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusInfo.label,
                      style: AppTypography.caption.copyWith(
                        color: statusInfo.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      context.t.common.vacantBadge,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            if (showSelection) ...[
              const SizedBox(height: AppSizes.spacingS),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '₺${apt.monthlyDues.toStringAsFixed(0)} $perMonthLabel',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: AppSizes.spacingS),
              Container(
                padding: const EdgeInsets.all(AppSizes.spacingS),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DashboardMetricTile(
                      icon: Icons.payments_outlined,
                      label: context.t.common.monthlyDues,
                      value: '₺${apt.monthlyDues.toStringAsFixed(0)}',
                      animateValue: false,
                    ),
                    if (isOccupied) ...[
                      const SizedBox(height: AppSizes.spacingS),
                      _buildApartmentDetailsAction(context, onTap: onShowDetails),
                    ],
                  ],
                ),
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
    return card;
  }

  Widget _buildApartmentDetailsAction(
    BuildContext context, {
    required VoidCallback onTap,
  }) {
    const actionRadius = BorderRadius.all(Radius.circular(12));

    return Material(
      color: AppColors.fill,
      borderRadius: actionRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: actionRadius,
        splashColor: AppColors.border.withValues(alpha: 0.4),
        highlightColor: AppColors.border.withValues(alpha: 0.25),
        child: SizedBox(
          height: AppSizes.minTouchTargetComfort,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.info_outline_rounded,
                    size: 22,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.t.common.residentDetailsLink,
                    style: AppTypography.body1.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
