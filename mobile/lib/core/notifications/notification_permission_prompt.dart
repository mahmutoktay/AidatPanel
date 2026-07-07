import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../l10n/strings.g.dart';
import '../theme/app_typography.dart';
import 'fcm_platform.dart';
import 'fcm_provider.dart';
import 'notification_permissions.dart';
import 'realtime/notification_delivery_provider.dart';

/// Giriş sonrası ana sayfada tek seferlik bildirim izni açıklama diyaloğu.
Future<void> maybeShowNotificationPermissionPrompt(
  BuildContext context,
  WidgetRef ref,
) async {
  if (!isFcmSupported || !(Platform.isAndroid || Platform.isIOS)) return;

  final user = ref.read(authStateProvider).user;
  if (user == null) return;

  final storage = ref.read(secureStorageProvider);
  if (await storage.hasSeenNotificationPermissionPrompt(user.id)) return;

  final alreadyGranted = await isNotificationPermissionGranted(
    messaging: FirebaseMessaging.instance,
  );
  await storage.markNotificationPermissionPromptSeen(user.id);
  if (alreadyGranted) {
    await ref.read(fcmServiceProvider).syncTokenToBackend(forceUpload: true);
    return;
  }

  if (!context.mounted) return;

  final t = context.t.features.notifications.permissionPrompt;
  final isResident = user.role == UserRole.resident;
  final accepted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          isResident ? t.residentTitle : t.managerTitle,
          style: AppTypography.h4.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Text(
          isResident ? t.residentBody : t.managerBody,
          style: AppTypography.body1.copyWith(height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(t.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(t.allow),
          ),
        ],
      );
    },
  );

  if (accepted != true || !context.mounted) return;

  final granted = await requestNotificationPermissions(
    messaging: FirebaseMessaging.instance,
  );
  if (!context.mounted) return;

  if (granted) {
    await ref.read(fcmServiceProvider).syncTokenToBackend(forceUpload: true);
    await ref
        .read(notificationDeliveryCoordinatorProvider)
        .onAuthenticated(force: true);
  }
}
