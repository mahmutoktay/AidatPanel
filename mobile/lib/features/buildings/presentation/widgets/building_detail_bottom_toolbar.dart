import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/detail_bottom_toolbar.dart';

/// Bina detay ekranı alt araç çubuğu — Düzenle, Sil, Rapor, Aidat Ayarları, Çoklu Seç.
class BuildingDetailBottomToolbar extends StatelessWidget {
  const BuildingDetailBottomToolbar({
    super.key,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
    required this.onDueSettings,
    required this.onMultiSelect,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReport;
  final VoidCallback onDueSettings;
  final VoidCallback onMultiSelect;

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return DetailBottomToolbar(
      actions: [
        DetailToolbarAction(
          icon: Icons.delete_outline,
          label: t.common.delete,
          onTap: onDelete,
          color: AppColors.statusRed,
        ),
        DetailToolbarAction(
          icon: Icons.edit_outlined,
          label: t.common.edit,
          onTap: onEdit,
        ),
        DetailToolbarAction(
          icon: Icons.download_rounded,
          label: t.features.reports.menuDownload,
          onTap: onReport,
        ),
        DetailToolbarAction(
          icon: Icons.payments_outlined,
          label: t.common.dueSettings,
          onTap: onDueSettings,
        ),
        DetailToolbarAction(
          icon: Icons.checklist_rounded,
          label: t.common.multiSelectResidents,
          onTap: onMultiSelect,
        ),
      ],
    );
  }
}
