import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/detail_bottom_toolbar.dart';

class TicketDetailBottomToolbar extends StatelessWidget {
  const TicketDetailBottomToolbar({
    super.key,
    required this.onReport,
    this.isSubmitting = false,
  });

  final VoidCallback onReport;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.tickets;

    return DetailBottomToolbar(
      actions: [
        DetailToolbarAction(
          icon: Icons.flag_outlined,
          label: t.reportInappropriate,
          color: AppColors.statusRed,
          onTap: isSubmitting ? () {} : onReport,
        ),
      ],
    );
  }
}
