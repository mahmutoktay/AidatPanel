import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/dashboard_filter_scope.dart';

class DashboardFilterScopeNotifier extends Notifier<DashboardFilterScope> {
  @override
  DashboardFilterScope build() => const DashboardFilterScope.all();

  void update(DashboardFilterScope scope) => state = scope;

  void reset() => state = const DashboardFilterScope.all();
}

/// Ana sayfa bina/site seçim kapsamı — sekme değişiminde korunur.
final dashboardFilterScopeProvider =
    NotifierProvider<DashboardFilterScopeNotifier, DashboardFilterScope>(
  DashboardFilterScopeNotifier.new,
);
