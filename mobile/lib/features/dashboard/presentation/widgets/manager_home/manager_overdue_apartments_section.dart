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
  final VoidCallback? onSeeMore;
  final String? remindingDueId;

  const ManagerOverdueApartmentsSection({
    super.key,
    required this.items,
    this.onRemind,
    this.onSeeMore,
    this.remindingDueId,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;
    final previewItems = items.take(previewLimit).toList(growable: false);
    final hiddenCount = items.length - previewItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ManagerDashboardSectionHeader(
          title: t.overdueApartments,
          trailing: ManagerDashboardPill(
            label: t.apartmentCountBadge.replaceAll('{count}', '${items.length}'),
          ),
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
          ManagerDashboardCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: previewItems.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: AppColors.fill,
                    indent: AppSizes.spacingM,
                    endIndent: AppSizes.spacingM,
                  ),
                  itemBuilder: (context, index) {
                    return ManagerOverdueApartmentRow(
                      item: previewItems[index],
                      onRemind: onRemind,
                      isReminding: remindingDueId == previewItems[index].dueId,
                    );
                  },
                ),
                if (hiddenCount > 0 && onSeeMore != null) ...[
                  Divider(height: 1, color: AppColors.fill),
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.minTouchTarget,
                    child: TextButton(
                      onPressed: onSeeMore,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.chartBlue,
                      ),
                      child: Text(
                        t.seeMoreOverdue.replaceAll('{count}', '$hiddenCount'),
                        style: AppTypography.body2.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
