import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/ticket_entity.dart';

class TicketFilterNotifier extends Notifier<TicketStatus?> {
  @override
  TicketStatus? build() => null;

  void select(TicketStatus? status) {
    // "Açık" filtre seçeneği kaldırıldı; tümü olarak göster.
    if (status == TicketStatus.open) {
      state = null;
      return;
    }
    state = status;
  }
}

/// Manager ticket listesi için filtre state'i.
/// `null` = tüm durumlar göster.
final managerTicketFilterProvider =
    NotifierProvider<TicketFilterNotifier, TicketStatus?>(
  TicketFilterNotifier.new,
);
