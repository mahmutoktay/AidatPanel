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
  });

  final VoidCallback onEdit;
  final VoidCallback onRemoveResident;

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
