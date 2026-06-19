import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/providers/navigation_provider.dart';

/// Bildirim deep link'lerini GoRouter ile uyumlu şekilde uygular.
///
/// Dashboard rotalarında sekme değişimi provider üzerinden yapılır;
/// `push` yerine `go` kullanılır ki ayarlar/bildirimler üstünde kalan
/// yığın ana menüye sapmasın. Detay rotalarında `push` kullanılır ki geri
/// tuşu önceki ekrana dönebilsin.
void navigateFromNotificationPath(
  BuildContext context,
  WidgetRef ref,
  String path,
) {
  final uri = Uri.parse(path);
  final loc = uri.path;

  if (loc == '/resident-dashboard') {
    _applyResidentDashboardQuery(ref, uri.queryParameters);
    context.go(uri.toString());
    return;
  }

  if (loc == '/manager-dashboard') {
    _applyManagerDashboardQuery(ref, uri.queryParameters);
    context.go(uri.toString());
    return;
  }

  if (isNotificationDetailPath(loc)) {
    context.push(path);
    return;
  }

  context.go(path);
}

/// `/dekonts/:id`, `/tickets/:id`, `/expenses/:id` gibi detay rotaları.
bool isNotificationDetailPath(String loc) {
  final segments = Uri.parse(loc).pathSegments;
  if (segments.length != 2) return false;
  final id = segments.last;
  if (id == 'create' || id == 'new') return false;
  return switch (segments.first) {
    'dekonts' || 'tickets' || 'expenses' => true,
    _ => false,
  };
}

void _applyResidentDashboardQuery(
  WidgetRef ref,
  Map<String, String> params,
) {
  final tab = params['tab'];
  if (tab == 'dues') {
    ref.read(residentTabIndexProvider.notifier).update(1);
    final dueId = params['dueId'];
    if (dueId != null && dueId.isNotEmpty) {
      ref.read(residentDueHighlightIdProvider.notifier).update(dueId);
    }
  } else if (tab == 'issues') {
    ref.read(residentTabIndexProvider.notifier).update(2);
  } else if (tab == 'menu' || tab == 'settings') {
    ref.read(residentTabIndexProvider.notifier).update(3);
  } else if (tab == 'home' || tab == null) {
    ref.read(residentTabIndexProvider.notifier).update(0);
  }
}

void _applyManagerDashboardQuery(
  WidgetRef ref,
  Map<String, String> params,
) {
  final tab = params['tab'];
  if (tab == 'dues') {
    ref.read(managerTabIndexProvider.notifier).update(2);
    final buildingId = params['buildingId'];
    final dueId = params['dueId'];
    if (buildingId != null && buildingId.isNotEmpty) {
      ref.read(managerDueNavigationIntentProvider.notifier).update(
            ManagerDueNavigationIntent(buildingId: buildingId),
          );
    }
    if (dueId != null && dueId.isNotEmpty) {
      ref.read(managerDueHighlightIdProvider.notifier).update(dueId);
    }
  } else if (tab == 'buildings') {
    ref.read(managerTabIndexProvider.notifier).update(1);
  } else if (tab == 'menu' || tab == 'settings') {
    ref.read(managerTabIndexProvider.notifier).update(3);
  } else if (tab == 'home' || tab == null) {
    ref.read(managerTabIndexProvider.notifier).update(0);
  }
}
