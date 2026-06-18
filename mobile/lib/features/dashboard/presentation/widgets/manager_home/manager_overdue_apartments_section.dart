import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/strings.g.dart';
import '../../../domain/entities/manager_dashboard_entities.dart';
import 'manager_dashboard_card.dart';
import 'manager_overdue_apartment_row.dart';

/// Ödemesi geciken daireler listesi — önizleme en fazla 4 satır.
class ManagerOverdueApartmentsSection extends StatelessWidget {
  static const int previewLimit = 4;

  final List<ManagerOverdueApartmentItem> items;
  final void Function(ManagerOverdueApartmentItem item)? onRemind;
  final VoidCallback? onSeeAll;
  final String? remindingDueId;

  const ManagerOverdueApartmentsSection({
    super.key,
    required this.items,
    this.onRemind,
    this.onSeeAll,
    this.remindingDueId,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;
    final previewItems = items.take(previewLimit).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                t.overdueApartments,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
              ),
            ),
            if (items.isNotEmpty) ...[
              ManagerDashboardPill(
                label: t.apartmentCountBadge.replaceAll(
                  '{count}',
                  '${items.length}',
                ),
              ),
              if (onSeeAll != null) ...[
                const SizedBox(width: AppSizes.spacingS),
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.chartBlue,
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.t.common.all,
                        style: AppTypography.body2.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
        const SizedBox(height: AppSizes.spacingS),
        if (items.isEmpty)
          ManagerDashboardCard(
            child: Text(
              t.noOverdueApartments,
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          Column(
            children: [
              for (var i = 0; i < previewItems.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSizes.spacingM),
                ManagerOverdueApartmentRow(
                  item: previewItems[i],
                  onRemind: onRemind,
                  isReminding: remindingDueId == previewItems[i].dueId,
                ),
              ],
            ],
          ),
      ],
    );
  }
}
