import 'package:flutter/material.dart';

import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_filter_chips_row.dart';
import '../../domain/entities/due_entity.dart';

class DuesFilterChipsRow extends StatelessWidget {
  final DueStatus? selectedStatus;
  final bool enabled;
  final ValueChanged<DueStatus?> onChanged;

  const DuesFilterChipsRow({
    super.key,
    required this.selectedStatus,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.common;
    return DashboardFilterChipsRow(
      enabled: enabled,
      chips: [
        DashboardFilterChipItem(
          label: t.all,
          selected: selectedStatus == null,
          onTap: () => onChanged(null),
        ),
        DashboardFilterChipItem(
          label: t.paidStatus,
          selected: selectedStatus == DueStatus.paid,
          onTap: () => onChanged(DueStatus.paid),
        ),
        DashboardFilterChipItem(
          label: t.pendingStatus,
          selected: selectedStatus == DueStatus.pending,
          onTap: () => onChanged(DueStatus.pending),
        ),
        DashboardFilterChipItem(
          label: t.overdueStatus,
          selected: selectedStatus == DueStatus.overdue,
          onTap: () => onChanged(DueStatus.overdue),
        ),
      ],
    );
  }
}
