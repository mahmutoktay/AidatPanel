import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../domain/entities/due_entity.dart';
import 'dues_screen_style.dart';

class DuesStatCardsRow extends StatelessWidget {
  final int paidCount;
  final int pendingCount;
  final int overdueCount;
  final int totalUnits;
  final DueStatus? selectedStatus;
  final ValueChanged<DueStatus> onStatusTap;

  const DuesStatCardsRow({
    super.key,
    required this.paidCount,
    required this.pendingCount,
    required this.overdueCount,
    required this.totalUnits,
    required this.selectedStatus,
    required this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _DuesStatCard(
            count: paidCount,
            label: context.t.common.paidStatus,
            color: AppColors.statusGreen,
            bgColor: AppColors.statusGreenBg,
            icon: Icons.check_rounded,
            progress: DuesScreenStyle.statusProgressRatio(
              paidCount,
              totalUnits,
            ),
            selected: selectedStatus == DueStatus.paid,
            onTap: () => onStatusTap(DueStatus.paid),
          ),
        ),
        const SizedBox(width: AppSizes.spacingS),
        Expanded(
          child: _DuesStatCard(
            count: pendingCount,
            label: context.t.common.pendingStatus,
            color: AppColors.statusAmber,
            bgColor: AppColors.statusAmberBg,
            icon: Icons.schedule_rounded,
            progress: DuesScreenStyle.statusProgressRatio(
              pendingCount,
              totalUnits,
            ),
            selected: selectedStatus == DueStatus.pending,
            onTap: () => onStatusTap(DueStatus.pending),
          ),
        ),
        const SizedBox(width: AppSizes.spacingS),
        Expanded(
          child: _DuesStatCard(
            count: overdueCount,
            label: context.t.common.overdueStatus,
            color: AppColors.statusRed,
            bgColor: AppColors.statusRedBg,
            icon: Icons.warning_amber_rounded,
            progress: DuesScreenStyle.statusProgressRatio(
              overdueCount,
              totalUnits,
            ),
            selected: selectedStatus == DueStatus.overdue,
            onTap: () => onStatusTap(DueStatus.overdue),
          ),
        ),
      ],
    );
  }
}

class _DuesStatCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;
  final double progress;
  final bool selected;
  final VoidCallback onTap;

  const _DuesStatCard({
    required this.count,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icon,
    required this.progress,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DuesScreenStyle.cardRadius),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 10),
          decoration: DuesScreenStyle.whiteCard().copyWith(
            color: selected ? bgColor.withValues(alpha: 0.55) : null,
            border: selected
                ? Border.all(color: color, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '$count',
                      style: AppTypography.h2.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                        height: 1,
                      ),
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 16, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 4,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: AppColors.lineLight),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(color: color),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
