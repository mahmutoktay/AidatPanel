import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Sistem tepsisi bildirimi — özellikle uygulama ön plandayken FCM göstermez.
class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  static const String channelId = 'aidatpanel_high';
  static const String channelName = 'Bildirimler';
  static const String channelDescription = 'AidatPanel bildirimleri';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidInit =
        AndroidInitializationSettings('@drawable/ic_stat_notification');
    const darwinInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );

    await _plugin.initialize(initSettings);

    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              channelId,
              channelName,
              description: channelDescription,
              importance: Importance.high,
            ),
          );
    }

    _initialized = true;
  }

  /// Arka plan isolate'inde tekrar çağrılabilir.
  Future<void> ensureInitialized() => initialize();

  /// Tray bildirimi. [fromForeground]: ön planda FCM tray göstermez, her zaman yerel.
  Future<void> showFromRemoteMessage(
    RemoteMessage message, {
    bool fromForeground = false,
  }) async {
    await ensureInitialized();

    final title = _resolveTitle(message);
    final body = _resolveBody(message);
    if (title == null || title.isEmpty) return;

    // Arka planda sistem notification payload ile zaten gösterdiyse çift olmasın.
    if (!fromForeground && message.notification != null) return;

    final id = _notificationId(message);

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    try {
      await _plugin.show(id, title, body ?? '', details);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[LocalNotification] show hata: $e\n$st');
      }
    }
  }

  int _notificationId(RemoteMessage message) {
    final raw = message.messageId ??
        message.data['notificationId']?.toString() ??
        '${message.sentTime?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}';
    return raw.hashCode & 0x7FFFFFFF;
  }

  String? _resolveTitle(RemoteMessage message) {
    final fromNotification = message.notification?.title?.trim();
    if (fromNotification != null && fromNotification.isNotEmpty) {
      return fromNotification;
    }
    final fromData = message.data['title']?.toString().trim();
    if (fromData != null && fromData.isNotEmpty) return fromData;
    return null;
  }

  String? _resolveBody(RemoteMessage message) {
    final fromNotification = message.notification?.body?.trim();
    if (fromNotification != null && fromNotification.isNotEmpty) {
      return fromNotification;
    }
    final fromData = message.data['body']?.toString().trim();
    if (fromData != null && fromData.isNotEmpty) return fromData;
    return null;
  }
}
