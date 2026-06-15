import 'package:flutter/material.dart';

import 'dashboard_secondary_scaffold.dart';

/// Filtre başlığı + yenilenebilir liste gövdesi için ortak push ekran kabuğu.
class DashboardFilterableListScreen extends StatelessWidget {
  final String title;
  final Widget? header;
  final Widget list;
  final Future<void> Function()? onRefresh;
  final List<Widget>? actions;
  final bool showNotificationAction;
  final VoidCallback? onBack;

  const DashboardFilterableListScreen({
    super.key,
    required this.title,
    required this.list,
    this.header,
    this.onRefresh,
    this.actions,
    this.showNotificationAction = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final body = DashboardListScreenBody(
      header: header,
      list: onRefresh == null
          ? list
          : RefreshIndicator(onRefresh: onRefresh!, child: list),
    );

    return DashboardSecondaryScaffold(
      title: title,
      actions: actions,
      showNotificationAction: showNotificationAction,
      onBack: onBack,
      body: body,
    );
  }
}
