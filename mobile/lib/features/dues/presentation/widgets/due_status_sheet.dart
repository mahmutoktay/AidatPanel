import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../domain/entities/due_entity.dart';

/// Aidat kartı ⋮ menüsü — durum seçimi alt sayfa olarak açılır.
class DueStatusSheet extends StatelessWidget {
  const DueStatusSheet({
    super.key,
    required this.due,
    required this.monthLabel,
  });

  final DueEntity due;
  final String monthLabel;

  static Future<DueStatus?> show(
    BuildContext context, {
    required DueEntity due,
    required String monthLabel,
  }) {
    return showModalBottomSheet<DueStatus>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DueStatusSheet(due: due, monthLabel: monthLabel),
    );
  }

  static const _selectableStatuses = [
    DueStatus.paid,
    DueStatus.pending,
    DueStatus.overdue,
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final allowedStatuses = due.resident == null
        ? _selectableStatuses.where((s) => s != DueStatus.paid).toList()
        : _selectableStatuses;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DashboardScreenStyle.cardRadius),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizes.spacingM,
        AppSizes.spacingS,
        AppSizes.spacingM,
        AppSizes.spacingM + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SheetHandle(),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            '${due.apartmentNumber} — $monthLabel',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            context.t.common.status,
            style: AppTypography.body2.copyWith(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          for (var i = 0; i < allowedStatuses.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSizes.spacingS),
            _StatusRow(
              status: allowedStatuses[i],
              isCurrent: due.status == allowedStatuses[i],
              onTap: () => Navigator.pop(context, allowedStatuses[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.borderColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.status,
    required this.isCurrent,
    required this.onTap,
  });

  final DueStatus status;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = _statusVisual(context, status);
    final icon = switch (status) {
      DueStatus.paid => Icons.check_circle_outline,
      DueStatus.pending => Icons.schedule_outlined,
      DueStatus.overdue => Icons.warning_amber_outlined,
      DueStatus.waived => Icons.block_outlined,
    };
    const radius = BorderRadius.all(
      Radius.circular(DashboardScreenStyle.pillRadius),
    );

    return Material(
      color: isCurrent ? visual.bg : AppColors.fill,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
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
                    borderRadius: BorderRadius.circular(
                      DashboardScreenStyle.pillRadius,
                    ),
                    border: Border.all(color: visual.fg.withValues(alpha: 0.18)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 22, color: visual.fg),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: visual.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    visual.label,
                    style: AppTypography.caption.copyWith(
                      color: visual.fg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                if (isCurrent)
                  Icon(Icons.check, size: AppSizes.listRowIconSize, color: visual.fg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusVisual {
  const _StatusVisual({
    required this.label,
    required this.fg,
    required this.bg,
  });

  final String label;
  final Color fg;
  final Color bg;
}

_StatusVisual _statusVisual(BuildContext context, DueStatus status) {
  switch (status) {
    case DueStatus.paid:
      return _StatusVisual(
        label: context.t.common.paidStatus,
        fg: AppColors.success,
        bg: AppColors.successBg,
      );
    case DueStatus.overdue:
      return _StatusVisual(
        label: context.t.common.overdueStatus,
        fg: AppColors.error,
        bg: AppColors.errorBg,
      );
    case DueStatus.waived:
      return _StatusVisual(
        label: context.t.common.waivedStatus,
        fg: AppColors.textSecondary,
        bg: AppColors.fill,
      );
    case DueStatus.pending:
      return _StatusVisual(
        label: context.t.common.pendingStatus,
        fg: AppColors.warning,
        bg: AppColors.warningBg,
      );
  }
}
