import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manager dashboard için tab index state provider
/// TabController ile sync edilir, BottomNavigationBar'ın currentIndex'ini yönetir
class ManagerTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void update(int index) => state = index;

  void reset() => state = 0;
}

final managerTabIndexProvider =
    NotifierProvider<ManagerTabIndexNotifier, int>(ManagerTabIndexNotifier.new);

class ResidentTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void update(int index) => state = index;

  void reset() => state = 0;
}

final residentTabIndexProvider =
    NotifierProvider<ResidentTabIndexNotifier, int>(ResidentTabIndexNotifier.new);

/// Manager dashboard tab index'ini sıfırlar (logout/login için)
void resetManagerTabIndex(WidgetRef ref) {
  ref.read(managerTabIndexProvider.notifier).reset();
}

/// Resident dashboard tab index'ini sıfırlar (logout/login için)
void resetResidentTabIndex(WidgetRef ref) {
  ref.read(residentTabIndexProvider.notifier).reset();
}

class ResidentDueHighlightNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? dueId) => state = dueId;
}

/// Bildirimden aidat kaydına geçişte vurgulanacak due id (sakin).
final residentDueHighlightIdProvider =
    NotifierProvider<ResidentDueHighlightNotifier, String?>(
  ResidentDueHighlightNotifier.new,
);

/// Bildirimden aidat kaydına geçişte bina + filtre (yönetici).
class ManagerDueNavigationIntent {
  final String? buildingId;

  /// `overdue`, `paid`, `pending`, `waived` — Aidatlar sekmesi durum filtresi.
  final String? statusFilter;

  const ManagerDueNavigationIntent({
    this.buildingId,
    this.statusFilter,
  });
}

class ManagerDueNavigationIntentNotifier
    extends Notifier<ManagerDueNavigationIntent?> {
  @override
  ManagerDueNavigationIntent? build() => null;

  void update(ManagerDueNavigationIntent? intent) => state = intent;
}

final managerDueNavigationIntentProvider =
    NotifierProvider<ManagerDueNavigationIntentNotifier,
        ManagerDueNavigationIntent?>(
  ManagerDueNavigationIntentNotifier.new,
);

class ManagerDueHighlightNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? dueId) => state = dueId;
}

/// Bildirimden aidat kaydına geçişte vurgulanacak due id (yönetici).
final managerDueHighlightIdProvider =
    NotifierProvider<ManagerDueHighlightNotifier, String?>(
  ManagerDueHighlightNotifier.new,
);
