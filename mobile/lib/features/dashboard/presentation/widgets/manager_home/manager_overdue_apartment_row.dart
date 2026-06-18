import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/app_currency_format.dart';
import '../../../../../l10n/strings.g.dart';
import '../../../../../shared/theme/dashboard_screen_style.dart';
import '../../../domain/entities/manager_dashboard_entities.dart';

class ManagerOverdueApartmentRow extends StatelessWidget {
  final ManagerOverdueApartmentItem item;
  final void Function(ManagerOverdueApartmentItem item)? onRemind;
  final bool isReminding;

  const ManagerOverdueApartmentRow({
    super.key,
    required this.item,
    this.onRemind,
    this.isReminding = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;
    final amountText = AppCurrencyFormat.format(
      item.amount,
      decimalDigits: 0,
    );

    final apartmentLabel = item.floor != null
        ? t.apartmentWithFloor
            .replaceAll('{number}', item.apartmentNumber)
            .replaceAll('{floor}', '${item.floor}')
        : t.apartmentTitle.replaceAll('{number}', item.apartmentNumber);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: DashboardScreenStyle.whiteCard(color: AppColors.surface),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.errorBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              'D${item.apartmentNumber}',
              style: AppTypography.caption.copyWith(
                color: AppColors.chartRed,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  apartmentLabel,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text:
                            '${item.overdueDays} ${context.t.common.overdueDays}',
                        style: const TextStyle(
                          color: AppColors.chartRed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: ' - $amountText'),
                    ],
                  ),
                ),
                if (item.buildingName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.buildingName!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 96,
            height: AppSizes.minTouchTarget,
            child: isReminding
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed:
                        onRemind == null ? null : () => onRemind!(item),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.chartBlue,
                      minimumSize: const Size(88, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      t.remind,
                      style: AppTypography.body2.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      softWrap: false,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
