import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

/// Android 13+ (POST_NOTIFICATIONS) ve iOS bildirim izinleri.
Future<void> requestNotificationPermissions({
  required FirebaseMessaging messaging,
}) async {
  if (Platform.isAndroid) {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (kDebugMode) {
        debugPrint('[FCM] Android bildirim izni: $result');
      }
    }
    return;
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
  }
}
