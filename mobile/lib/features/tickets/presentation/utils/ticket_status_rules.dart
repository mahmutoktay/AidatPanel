import '../../domain/entities/ticket_entity.dart';

/// Backend `ticketService` — `ALLOWED_STATUS_TRANSITIONS` ile birebir.
List<TicketStatus> allowedNextStatuses(TicketStatus current) {
  switch (current) {
    case TicketStatus.open:
      return [TicketStatus.inProgress, TicketStatus.closed];
    case TicketStatus.inProgress:
      return [TicketStatus.resolved, TicketStatus.open];
    case TicketStatus.resolved:
      return [TicketStatus.inProgress];
    case TicketStatus.closed:
      return [TicketStatus.open];
  }
}

/// Yönetici detayında gösterilen tek dokunuş aksiyon hedefleri (Geri Al hariç).
List<TicketStatus> managerActionTargets(TicketStatus current) {
  switch (current) {
    case TicketStatus.open:
      return [TicketStatus.inProgress, TicketStatus.closed];
    case TicketStatus.inProgress:
      return [TicketStatus.resolved];
    case TicketStatus.resolved:
    case TicketStatus.closed:
      return [];
  }
}

/// `POST .../updates` — yalnızca OPEN / IN_PROGRESS (aksi 409).
bool canAddManagerNote(TicketStatus status) {
  return status == TicketStatus.open || status == TicketStatus.inProgress;
}

bool canChangeStatus(TicketStatus status) =>
    managerActionTargets(status).isNotEmpty;
