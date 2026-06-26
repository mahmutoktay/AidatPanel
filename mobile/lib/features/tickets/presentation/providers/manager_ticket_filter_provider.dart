import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/ticket_entity.dart';

class TicketFilterNotifier extends Notifier<TicketStatus?> {
  @override
  TicketStatus? build() => null;
  void select(TicketStatus? status) => state = status;
}

/// Manager ticket listesi için filtre state'i.
/// `null` = tüm durumlar göster.
final managerTicketFilterProvider =
    NotifierProvider<TicketFilterNotifier, TicketStatus?>(
  TicketFilterNotifier.new,
);
