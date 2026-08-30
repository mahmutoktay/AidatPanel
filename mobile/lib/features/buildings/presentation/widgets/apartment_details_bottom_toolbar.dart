import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/detail_bottom_toolbar.dart';

/// Sakin detay sheet alt araç çubuğu — Düzenle, Sakini Çıkar.
class ApartmentDetailsBottomToolbar extends StatelessWidget {
  const ApartmentDetailsBottomToolbar({
    super.key,
    required this.onEdit,
    required this.onRemoveResident,
    this.onTicketRestriction,
    this.hasActiveTicketRestriction = false,
  });

  final VoidCallback onEdit;
  final VoidCallback onRemoveResident;
  final VoidCallback? onTicketRestriction;
  final bool hasActiveTicketRestriction;

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return DetailBottomToolbar(
      actions: [
        DetailToolbarAction(
          icon: Icons.edit_outlined,
          label: t.common.editApartment,
          onTap: onEdit,
        ),
        if (onTicketRestriction != null)
          DetailToolbarAction(
            icon: hasActiveTicketRestriction
                ? Icons.lock_open_outlined
                : Icons.lock_clock_outlined,
            label: hasActiveTicketRestriction
                ? t.features.tickets.restrictionManageAction
                : t.features.tickets.restrictionApplyAction,
            onTap: onTicketRestriction!,
            color: AppColors.statusAmber,
          ),
        DetailToolbarAction(
          icon: Icons.person_remove_outlined,
          label: t.common.removeResident,
          onTap: onRemoveResident,
          color: AppColors.statusRed,
        ),
      ],
    );
  }
}
