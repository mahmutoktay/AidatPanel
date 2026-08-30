import 'dart:typed_data';

import '../../../../core/network/paginated_list_result.dart';
import '../entities/ticket_entity.dart';
import '../entities/ticket_restriction_entity.dart';

abstract class TicketRepository {
  Future<PaginatedListResult<TicketEntity>> getMyTickets({
    TicketStatus? status,
    TicketCategory? category,
    String? cursor,
    bool paginated = true,
  });

  Future<PaginatedListResult<TicketEntity>> getBuildingTickets(
    String buildingId, {
    TicketStatus? status,
    TicketCategory? category,
    String? cursor,
    bool paginated = true,
  });

  Future<TicketEntity> getTicketById(String ticketId);

  Future<TicketEntity> createTicket({
    required String apartmentId,
    required String title,
    required String description,
    required TicketCategory category,
    Uint8List? attachmentBytes,
    String? attachmentFilename,
  });

  Future<TicketEntity> addManagerUpdate({
    required String ticketId,
    required String message,
  });

  Future<TicketEntity> updateTicketStatus({
    required String ticketId,
    required TicketStatus status,
  });

  Future<void> reportTicket({
    required String ticketId,
    String? ticketUpdateId,
  });

  Future<TicketRestrictionStatusEntity> getMyTicketRestriction();

  Future<TicketRestrictionStatusEntity> getApartmentTicketRestriction(
    String apartmentId,
  );

  Future<TicketRestrictionStatusEntity> createApartmentTicketRestriction({
    required String apartmentId,
    required String ticketId,
    String? note,
  });

  Future<void> liftApartmentTicketRestriction(String apartmentId);
}
