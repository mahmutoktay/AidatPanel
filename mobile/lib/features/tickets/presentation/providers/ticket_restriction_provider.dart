import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/ticket_restriction_entity.dart';
import 'tickets_provider.dart';

final myTicketRestrictionProvider =
    FutureProvider<TicketRestrictionStatusEntity>((ref) async {
  return ref.watch(ticketRepositoryProvider).getMyTicketRestriction();
});

final apartmentTicketRestrictionProvider =
    FutureProvider.family<TicketRestrictionStatusEntity, String>(
  (ref, apartmentId) async {
    return ref
        .watch(ticketRepositoryProvider)
        .getApartmentTicketRestriction(apartmentId);
  },
);
