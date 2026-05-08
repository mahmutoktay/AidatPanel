import 'package:flutter/material.dart';

import '../../../dashboard/presentation/screens/resident_dashboard_screen.dart'
    as dashboard;

@Deprecated('Use features/dashboard/presentation/screens/resident_dashboard_screen.dart')
class ResidentDashboardScreen extends StatelessWidget {
  const ResidentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const dashboard.ResidentDashboardScreen();
  }
}
