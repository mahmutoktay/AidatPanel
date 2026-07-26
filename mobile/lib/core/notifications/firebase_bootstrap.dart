import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../firebase_options.dart';
import '../security/recaptcha_enterprise_service.dart';
import 'fcm_platform.dart';
import 'local_notification_service.dart';

/// Arka planda gelen FCM mesajları (top-level, isolate girişi).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // flutter_local_notifications arka plan isolate'inde binding şart.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    debugPrint('[FCM background] ${message.messageId} data=${message.data}');
  }
  if (Platform.isAndroid) {
    final granted = await Permission.notification.isGranted;
    if (!granted) {
      if (kDebugMode) {
        debugPrint(
          '[FCM background] Bildirim izni yok — tray gösterilemedi. '
          'Uygulamayı açıp izin verin.',
        );
      }
      return;
    }
  }
  // Backend notification+data gönderir: kapalıyken Android tray'i FCM gösterir.
  // Yerel bildirim ekleme → çift bildirim. Yalnızca data-only mesajda yerel göster.
  await LocalNotificationService.instance.showFromRemoteMessage(message);
}

/// Production (`main.dart`) için Firebase + arka plan handler.
Future<void> initFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Phone Auth SMS defense — native reCAPTCHA Enterprise SDK link + Auth config.
  await RecaptchaEnterpriseService.initialize();
  await LocalNotificationService.instance.initialize();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  if (kDebugMode && isFcmSupported && (Platform.isAndroid || Platform.isIOS)) {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    debugPrint('[FCM] başlangıç auth=${settings.authorizationStatus}');
    if (Platform.isAndroid) {
      debugPrint(
        '[FCM] POST_NOTIFICATIONS=${await Permission.notification.status}',
      );
    }
  }
}
