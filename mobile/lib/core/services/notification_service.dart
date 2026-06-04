// Centralized notification service for toast/snackbar handling
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late GlobalKey<NavigatorState> _navigatorKey;

  // Initialize with the navigator key from the app root
  void init(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  void showToast(String message) {
    final context = _navigatorKey.currentContext;
    if (context == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
