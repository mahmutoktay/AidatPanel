import 'package:flutter/material.dart';

import '../../../dashboard/presentation/screens/manager_dashboard_screen.dart'
    as dashboard;

@Deprecated('Use features/dashboard/presentation/screens/manager_dashboard_screen.dart')
class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const dashboard.ManagerDashboardScreen();
  }
}
