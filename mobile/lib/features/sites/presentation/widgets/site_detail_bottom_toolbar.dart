import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';

/// Site detay ekranı alt araç çubuğu — Sil, Düzenle, Giderler, Rapor.
class SiteDetailBottomToolbar extends StatelessWidget {
  const SiteDetailBottomToolbar({
    super.key,
    required this.onDelete,
    required this.onEdit,
    required this.onExpenses,
    required this.onReport,
  });

  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onExpenses;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final sitesT = context.t.features.sites;

    return Material(
      elevation: 8,
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.borderColor.withValues(alpha: 0.35),
              ),
            ),
          ),
          child: Row(
            children: [
              _ToolbarAction(
                icon: Icons.delete_outline,
                label: t.common.delete,
                onTap: onDelete,
                color: AppColors.statusRed,
              ),
              _ToolbarAction(
                icon: Icons.edit_outlined,
                label: t.common.edit,
                onTap: onEdit,
              ),
              _ToolbarAction(
                icon: Icons.receipt_long_outlined,
                label: sitesT.commonExpenses,
                onTap: onExpenses,
              ),
              _ToolbarAction(
                icon: Icons.download_rounded,
                label: t.features.reports.menuDownload,
                onTap: onReport,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  const _ToolbarAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final actionColor = color ?? AppColors.inkDark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: actionColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: actionColor,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
