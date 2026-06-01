import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../router/app_router.dart';
import 'fcm_provider.dart';
import 'fcm_sync.dart' show syncFcmWithService;
import 'notification_navigation.dart';
import 'notification_payload.dart';
import 'notification_toast.dart';

/// FCM dinleyicileri + oturum açılınca token senkronu + bildirimden navigasyon.
class FcmScope extends ConsumerStatefulWidget {
  final Widget child;

  const FcmScope({super.key, required this.child});

  @override
  ConsumerState<FcmScope> createState() => _FcmScopeState();
}

class _FcmScopeState extends ConsumerState<FcmScope> with WidgetsBindingObserver {
  static const _pollInterval = Duration(seconds: 5);
  static const _pollIntervalWhenUnread = Duration(seconds: 3);

  Timer? _badgePollTimer;
  bool _pollRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFcm());
  }

  @override
  void dispose() {
    _stopBadgePolling();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startBadgePolling() {
    _badgePollTimer?.cancel();
    _scheduleNextPoll();
  }

  void _scheduleNextPoll() {
    final unread = ref.read(notificationsNotifierProvider).unreadCount;
    final delay = unread > 0 ? _pollIntervalWhenUnread : _pollInterval;
    _badgePollTimer = Timer(delay, () async {
      await _pollNotifications();
      if (mounted && _badgePollTimer != null) {
        _scheduleNextPoll();
      }
    });
  }

  void _stopBadgePolling() {
    _badgePollTimer?.cancel();
    _badgePollTimer = null;
  }

  /// FCM gelmezse bile rozet + yeni bildirim toast'u (liste ekranı kendi poll'una sahip).
  Future<void> _pollNotifications() async {
    if (!ref.read(authStateProvider).isAuthenticated) return;
    if (_pollRunning) return;
    _pollRunning = true;
    try {
      await pollAndShowNotificationToasts(ref);
    } finally {
      _pollRunning = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!ref.read(authStateProvider).isAuthenticated) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _startBadgePolling();
        unawaited(_pollNotifications());
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _stopBadgePolling();
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _onPushMessage(RemoteMessage message) {
    if (!ref.read(authStateProvider).isAuthenticated) return;

    final notifier = ref.read(notificationsNotifierProvider.notifier);
    final notificationId = message.data['notificationId']?.toString().trim();
    if (notificationId != null && notificationId.isNotEmpty) {
      notifier.markNotificationToasted(notificationId);
    }

    showNotificationToastFromRemote(ref, message);
    notifier.onPushReceived();
  }

  Future<void> _initFcm() async {
    final fcm = ref.read(fcmServiceProvider);
    await fcm.attachListeners(
      onOpenFromNotification: _navigateFromPayload,
      onForegroundMessage: _onPushMessage,
    );

    final auth = ref.read(authStateProvider);
    if (auth.isAuthenticated) {
      await syncFcmWithService(fcm);
      final notifier = ref.read(notificationsNotifierProvider.notifier);
      await notifier.pollForNewNotifications();
      _startBadgePolling();
    }
  }

  void _navigateFromPayload(NotificationPayload payload) {
    final role = ref.read(authStateProvider).user?.role;
    final path = payload.resolveNavigationPath(role: role);
    if (path == null) return;

    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    navigateFromNotificationPath(ctx, ref, path);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.isAuthenticated && next.user != null) {
        final wasAuth = previous?.isAuthenticated ?? false;
        if (!wasAuth || previous?.user?.id != next.user?.id) {
          final fcm = ref.read(fcmServiceProvider);
          syncFcmWithService(fcm);
          final notifier = ref.read(notificationsNotifierProvider.notifier);
          notifier.resetToastTracking();
          unawaited(notifier.pollForNewNotifications());
          _startBadgePolling();
        }
      } else {
        _stopBadgePolling();
        ref.read(notificationsNotifierProvider.notifier).resetToastTracking();
      }
    });

    return widget.child;
  }
}
