import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';

/// Sakin detay sheet alt araç çubuğu — Düzenle, Sakini Çıkar.
class ApartmentDetailsBottomToolbar extends StatelessWidget {
  const ApartmentDetailsBottomToolbar({
    super.key,
    required this.onEdit,
    required this.onRemoveResident,
  });

  final VoidCallback onEdit;
  final VoidCallback onRemoveResident;

  @override
  Widget build(BuildContext context) {
    final t = context.t;

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
                icon: Icons.edit_outlined,
                label: t.common.editApartment,
                onTap: onEdit,
              ),
              _ToolbarAction(
                icon: Icons.person_remove_outlined,
                label: t.common.removeResident,
                onTap: onRemoveResident,
                color: AppColors.statusRed,
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
