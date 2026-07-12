import 'package:flutter/material.dart';

import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/sliding_segmented_control.dart';
import '../../domain/entities/due_entity.dart';

/// Aidat durum filtresi — bildirimlerdeki kaydırmalı segment + sayılar.
class DuesStatusFilterBar extends StatelessWidget {
  final int paidCount;
  final int pendingCount;
  final int overdueCount;
  final DueStatus? selectedStatus;
  final ValueChanged<DueStatus?> onChanged;
  final bool enabled;

  const DuesStatusFilterBar({
    super.key,
    required this.paidCount,
    required this.pendingCount,
    required this.overdueCount,
    required this.selectedStatus,
    required this.onChanged,
    this.enabled = true,
  });

  int get _selectedIndex {
    switch (selectedStatus) {
      case DueStatus.paid:
        return 1;
      case DueStatus.pending:
        return 2;
      case DueStatus.overdue:
        return 3;
      case DueStatus.waived:
      case null:
        return 0;
    }
  }

  void _onIndexChanged(int index) {
    final next = switch (index) {
      1 => DueStatus.paid,
      2 => DueStatus.pending,
      3 => DueStatus.overdue,
      _ => null,
    };
    if (next == selectedStatus) return;
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final common = context.t.common;
    return SlidingSegmentedControl(
      segments: [
        common.all,
        '${common.paidStatus} $paidCount',
        '${common.pendingStatus} $pendingCount',
        '${common.overdueStatus} $overdueCount',
      ],
      selectedIndex: _selectedIndex,
      onChanged: _onIndexChanged,
      enabled: enabled,
      fontSize: 12,
      height: 48,
    );
  }
}
