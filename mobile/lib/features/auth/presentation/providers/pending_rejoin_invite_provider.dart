import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Deep link veya dış kaynaktan gelen, rejoin sheet'te önceden doldurulacak davet kodu.
class PendingRejoinInviteNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? code) {
    final trimmed = code?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      state = null;
      return;
    }
    state = trimmed.toUpperCase().replaceAll(RegExp(r'\s+'), '');
  }

  String? take() {
    final value = state;
    state = null;
    return value;
  }
}

final pendingRejoinInviteCodeProvider =
    NotifierProvider<PendingRejoinInviteNotifier, String?>(
  PendingRejoinInviteNotifier.new,
);
