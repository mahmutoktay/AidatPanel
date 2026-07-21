import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import 'realtime/notification_delivery_coordinator.dart';
import 'realtime/notification_delivery_provider.dart';

/// Bildirim iletimi: FCM + poll (+ ileride WebSocket) — [NotificationDeliveryCoordinator].
class FcmScope extends ConsumerStatefulWidget {
  final Widget child;

  const FcmScope({super.key, required this.child});

  @override
  ConsumerState<FcmScope> createState() => _FcmScopeState();
}

class _FcmScopeState extends ConsumerState<FcmScope> with WidgetsBindingObserver {
  NotificationDeliveryCoordinator? _coordinator;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // dispose içinde ref.read güvenli değil — coordinator alanı kullan.
    _coordinator?.detach();
    _coordinator = null;
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final coordinator = ref.read(notificationDeliveryCoordinatorProvider);
    _coordinator = coordinator;
    coordinator.attach(ref);
    await coordinator.start();
    if (!mounted) return;
    if (ref.read(authStateProvider).isAuthenticated) {
      await coordinator.onAuthenticated(force: true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!ref.read(authStateProvider).isAuthenticated) return;
    final coordinator = ref.read(notificationDeliveryCoordinatorProvider);

    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_onResumed(coordinator));
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        unawaited(coordinator.stop());
      case AppLifecycleState.inactive:
        break;
    }
  }

  Future<void> _onResumed(NotificationDeliveryCoordinator coordinator) async {
    await coordinator.start();
    await coordinator.onForegroundResumed();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      final coordinator = ref.read(notificationDeliveryCoordinatorProvider);
      _coordinator = coordinator;
      if (next.isAuthenticated && next.user != null) {
        final wasAuth = previous?.isAuthenticated ?? false;
        if (!wasAuth || previous?.user?.id != next.user?.id) {
          coordinator.attach(ref);
          unawaited(coordinator.start());
          unawaited(coordinator.onAuthenticated(force: true));
        }
      } else {
        unawaited(coordinator.onLoggedOut());
      }
    });

    return widget.child;
  }
}
