import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

/// Android 13+ (POST_NOTIFICATIONS) ve iOS bildirim izinleri.
/// `false` → tray push gösterilmez (in-app liste yine çalışır).
Future<bool> requestNotificationPermissions({
  required FirebaseMessaging messaging,
}) async {
  if (Platform.isAndroid) {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      status = await Permission.notification.request();
      if (kDebugMode) {
        debugPrint('[FCM] Android bildirim izni: $status');
      }
    }
    if (!status.isGranted && kDebugMode) {
      debugPrint(
        '[FCM] Bildirim izni yok — kapalıyken sistem tray push gelmez. '
        'Ayarlar → Aidat Paneli → Bildirimler.',
      );
    }
    return status.isGranted;
  }

  if (Platform.isIOS) {
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (kDebugMode) {
      debugPrint('[FCM] iOS izin durumu: ${settings.authorizationStatus}');
    }
    final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!granted && kDebugMode) {
      debugPrint(
        '[FCM] Bildirim izni yok — kapalıyken sistem tray push gelmez.',
      );
    }
    return granted;
  }

  return true;
}
