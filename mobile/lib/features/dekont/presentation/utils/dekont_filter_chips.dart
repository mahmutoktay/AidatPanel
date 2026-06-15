import 'package:flutter/material.dart';

import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_filter_chips_row.dart';

List<DashboardFilterChipItem> dekontStatusFilterChips(
  BuildContext context, {
  required String? selectedFilterKey,
  required void Function(String? filterKey) onSelected,
}) {
  final t = context.t.features.dekont;
  return [
    DashboardFilterChipItem(
      label: t.filterAll,
      selected: selectedFilterKey == null,
      onTap: () => onSelected(null),
    ),
    DashboardFilterChipItem(
      label: t.filterPending,
      selected: selectedFilterKey == 'pending',
      onTap: () => onSelected('pending'),
    ),
    DashboardFilterChipItem(
      label: t.filterApproved,
      selected: selectedFilterKey == 'approved',
      onTap: () => onSelected('approved'),
    ),
    DashboardFilterChipItem(
      label: t.filterRejected,
      selected: selectedFilterKey == 'rejected',
      onTap: () => onSelected('rejected'),
    ),
  ];
}
