import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/app_currency_format.dart';
import '../../../../../l10n/strings.g.dart';
import '../../../domain/entities/manager_dashboard_entities.dart';

/// Ana sayfa geciken aidat satırı — sakin Son Hareketler satırı ile aynı görsel dil.
class ManagerOverdueFeedRow extends StatelessWidget {
  const ManagerOverdueFeedRow({
    super.key,
    required this.item,
    this.onTap,
    this.onRemind,
    this.isReminding = false,
  });

  final ManagerOverdueApartmentItem item;
  final VoidCallback? onTap;
  final void Function(ManagerOverdueApartmentItem item)? onRemind;
  final bool isReminding;

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;
    final apartmentLabel = item.floor != null
        ? t.apartmentWithFloor
            .replaceAll('{number}', item.apartmentNumber)
            .replaceAll('{floor}', '${item.floor}')
        : t.apartmentTitle.replaceAll('{number}', item.apartmentNumber);

    final subtitleParts = <String>[
      apartmentLabel,
      if (item.buildingName != null) item.buildingName!,
      '${item.overdueDays} ${context.t.common.overdueDays}',
    ];

    final trailing = AppCurrencyFormat.format(
      item.amount,
      decimalDigits: 0,
    );

    final card = Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingM,
              vertical: 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.residentName,
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitleParts.join(' · '),
                        style: AppTypography.body2.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.spacingS),
                if (isReminding)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    trailing,
                    style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (onRemind == null || isReminding) return card;

    return Slidable(
      key: ValueKey<String>(item.dueId),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.34,
        children: [
          SlidableAction(
            onPressed: (_) => onRemind!(item),
            backgroundColor: AppColors.chartBlue,
            foregroundColor: Colors.white,
            icon: Icons.notifications_active_outlined,
            label: t.remind,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
        ],
      ),
      child: card,
    );
  }
}
