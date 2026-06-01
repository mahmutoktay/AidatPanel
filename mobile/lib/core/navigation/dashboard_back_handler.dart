import 'package:flutter/material.dart';

import 'app_back_navigation.dart';

/// Dashboard ekranlarını sarar; geri tuşunu [BackButtonListener] ile yönetir.
class DashboardBackHandler extends StatelessWidget {
  const DashboardBackHandler({
    super.key,
    required this.dashboardRootPath,
    required this.currentTabIndex,
    required this.exitHintMessage,
    required this.onExitHint,
    required this.goToHomeTab,
    required this.child,
  });

  final String dashboardRootPath;
  final int currentTabIndex;
  final String exitHintMessage;
  final void Function(String message) onExitHint;
  final VoidCallback goToHomeTab;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
      onBackButtonPressed: () async =>
          AppBackNavigation.handleDashboardBackPressed(
            context,
            dashboardRootPath: dashboardRootPath,
            currentTabIndex: currentTabIndex,
            exitHintMessage: exitHintMessage,
            goToHomeTab: goToHomeTab,
            onExitHint: onExitHint,
          ),
      child: child,
    );
  }
}
