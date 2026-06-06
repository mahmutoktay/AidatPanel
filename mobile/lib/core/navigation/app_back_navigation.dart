import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../platform/system_navigator_bridge.dart';

/// Merkezi geri tuşu: GoRouter stack + sekme + çift geri ile çıkış.
///
/// Dashboard üzerinde [PopScope] + `canPop: false` kullanılmaz; GoRouter'ın
/// iç navigator'ı ile çakışıp tüm geri olaylarını yutuyordu.
class AppBackNavigation {
  AppBackNavigation._();

  static const Duration exitGracePeriod = Duration(seconds: 2);

  static DateTime? _lastExitRequest;

  static void resetExitTimer() {
    _lastExitRequest = null;
  }

  /// Dashboard [BackButtonListener] — `true` = olay tüketildi.
  static bool handleDashboardBackPressed(
    BuildContext context, {
    required String dashboardRootPath,
    required int currentTabIndex,
    required String exitHintMessage,
    required VoidCallback goToHomeTab,
    required void Function(String message) onExitHint,
  }) {
    final path = _currentPath(context);
    final rootNavigator = Navigator.of(context, rootNavigator: true);

    // Tam ekran üst route (parentNavigatorKey ile root'ta açılan sayfalar).
    if (path != dashboardRootPath) {
      final router = GoRouter.of(context);
      if (router.canPop()) {
        resetExitTimer();
        router.pop();
        return true;
      }
      if (rootNavigator.canPop()) {
        resetExitTimer();
        rootNavigator.pop();
        return true;
      }
      // GoRouter stack boşsa bile, dashboard kökü değilsek kullanıcıyı
      // uygulamadan çıkarmak yerine dashboard'a yönlendir.
      resetExitTimer();
      goToHomeTab();
      return true;
    }

    // GoRouter path'i dashboard kökü görünse de root navigator üzerinde
    // MaterialPageRoute/dialog gibi üst route açık olabilir.
    if (rootNavigator.canPop()) {
      resetExitTimer();
      rootNavigator.pop();
      return true;
    }

    // Dashboard kökü — önce Ana Sayfa sekmesi.
    if (currentTabIndex != 0) {
      resetExitTimer();
      goToHomeTab();
      return true;
    }

    final now = DateTime.now();
    if (_lastExitRequest != null &&
        now.difference(_lastExitRequest!) <= exitGracePeriod) {
      resetExitTimer();
      unawaited(SystemNavigatorBridge.moveAppToBackground());
      return true;
    }

    _lastExitRequest = now;
    onExitHint(exitHintMessage);
    return true;
  }

  /// Login vb. — stack varsa pop, yoksa arka plan.
  static bool handleAuthBackPressed(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return true;
    }

    final router = GoRouter.maybeOf(context);
    if (router != null && router.canPop()) {
      router.pop();
      return true;
    }

    unawaited(SystemNavigatorBridge.moveAppToBackground());
    return true;
  }

  static String _currentPath(BuildContext context) {
    return GoRouterState.of(context).uri.path;
  }
}
