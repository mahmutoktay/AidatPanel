import 'package:flutter_riverpod/flutter_riverpod.dart';

class _DekontFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? key) => state = key;
}

/// Manager dekont listesi için filtre state'i.
/// `null` = tüm durumlar göster, diğer değerler: 'pending', 'approved', 'rejected'.
final managerDekontFilterProvider =
    NotifierProvider<_DekontFilterNotifier, String?>(
  _DekontFilterNotifier.new,
);
