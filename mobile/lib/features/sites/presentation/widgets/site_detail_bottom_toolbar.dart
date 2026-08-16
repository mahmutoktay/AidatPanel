import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/detail_bottom_toolbar.dart';

/// Site detay ekranı alt araç çubuğu —
/// Rapor → Giderler → Düzenle → Sil.
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

    return DetailBottomToolbar(
      actions: [
        DetailToolbarAction(
          icon: Icons.download_rounded,
          label: t.features.reports.menuDownload,
          onTap: onReport,
        ),
        DetailToolbarAction(
          icon: Icons.receipt_long_outlined,
          label: sitesT.commonExpenses,
          onTap: onExpenses,
        ),
        DetailToolbarAction(
          icon: Icons.edit_outlined,
          label: t.common.edit,
          onTap: onEdit,
        ),
        DetailToolbarAction(
          icon: Icons.delete_outline,
          label: t.common.delete,
          onTap: onDelete,
          color: AppColors.statusRed,
        ),
      ],
    );
  }
}
