import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingInviteCodeNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? code) => state = code;

  void clear() => state = null;
}

final pendingInviteCodeProvider =
    NotifierProvider<PendingInviteCodeNotifier, String?>(
  PendingInviteCodeNotifier.new,
);

void clearPendingInviteCode(WidgetRef ref) {
  ref.read(pendingInviteCodeProvider.notifier).clear();
}

void setPendingInviteCode(WidgetRef ref, String code) {
  ref.read(pendingInviteCodeProvider.notifier).set(code);
}

String? readPendingInviteCode(WidgetRef ref) {
  return ref.read(pendingInviteCodeProvider);
}
