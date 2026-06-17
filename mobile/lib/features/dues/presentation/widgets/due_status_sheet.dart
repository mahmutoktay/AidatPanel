import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
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
    return PremiumBottomSheetScaffold.show<DueStatus>(
      context: context,
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
    final allowedStatuses = due.resident == null
        ? _selectableStatuses.where((s) => s != DueStatus.paid).toList()
        : _selectableStatuses;

    return PremiumBottomSheetScaffold(
      scrollable: false,
      titleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < allowedStatuses.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSizes.spacingXS),
            _StatusTile(
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

class _StatusTile extends StatelessWidget {
  const _StatusTile({
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

    return PremiumActionSheetTile(
      icon: icon,
      label: visual.label,
      iconColor: visual.fg,
      iconBackground: visual.bg,
      trailing: isCurrent
          ? Icon(Icons.check, size: AppSizes.listRowIconSize, color: visual.fg)
          : null,
      onTap: onTap,
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
