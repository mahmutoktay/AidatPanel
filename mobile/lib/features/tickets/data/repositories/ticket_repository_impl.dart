import 'dart:typed_data';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/paginated_list_result.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/entities/ticket_restriction_entity.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../datasources/ticket_remote_datasource.dart';
import '../models/create_ticket_request.dart';
import '../models/ticket_model.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketRemoteDataSource _remoteDataSource;

  TicketRepositoryImpl({required TicketRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<PaginatedListResult<TicketEntity>> getMyTickets({
    TicketStatus? status,
    TicketCategory? category,
    String? cursor,
    bool paginated = true,
  }) async {
    try {
      final result = await _remoteDataSource.getMyTickets(
        status: status != null ? TicketModel.statusToApi(status) : null,
        category: category != null ? TicketModel.categoryToApi(category) : null,
        cursor: cursor,
        paginated: paginated,
      );
      return PaginatedListResult(
        items: result.items.map((m) => m.toEntity()).toList(),
        nextCursor: result.nextCursor,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'my_tickets_fetch_failed');
    }
  }

  @override
  Future<PaginatedListResult<TicketEntity>> getBuildingTickets(
    String buildingId, {
    TicketStatus? status,
    TicketCategory? category,
    String? cursor,
    bool paginated = true,
  }) async {
    try {
      final result = await _remoteDataSource.getBuildingTickets(
        buildingId,
        status: status != null ? TicketModel.statusToApi(status) : null,
        category: category != null ? TicketModel.categoryToApi(category) : null,
        cursor: cursor,
        paginated: paginated,
      );
      return PaginatedListResult(
        items: result.items.map((m) => m.toEntity()).toList(),
        nextCursor: result.nextCursor,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'building_tickets_fetch_failed');
    }
  }

  @override
  Future<TicketEntity> getTicketById(String ticketId) async {
    try {
      final model = await _remoteDataSource.getTicketById(ticketId);
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'ticket_detail_fetch_failed');
    }
  }

  @override
  Future<TicketEntity> createTicket({
    required String apartmentId,
    required String title,
    required String description,
    required TicketCategory category,
    Uint8List? attachmentBytes,
    String? attachmentFilename,
  }) async {
    try {
      var model = await _remoteDataSource.createTicket(
        apartmentId,
        CreateTicketRequest(
          title: title.trim(),
          description: description.trim(),
          category: TicketModel.categoryToApi(category),
        ),
      );
      if (attachmentBytes != null && attachmentBytes.isNotEmpty) {
        final name = (attachmentFilename != null && attachmentFilename.isNotEmpty)
            ? attachmentFilename
            : 'ticket.jpg';
        model = await _remoteDataSource.uploadTicketAttachment(
          ticketId: model.id,
          bytes: attachmentBytes,
          filename: name,
        );
      }
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'ticket_create_failed');
    }
  }

  @override
  Future<TicketEntity> addManagerUpdate({
    required String ticketId,
    required String message,
  }) async {
    try {
      await _remoteDataSource.addTicketUpdate(ticketId, message.trim());
      return getTicketById(ticketId);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'ticket_note_add_failed');
    }
  }

  @override
  Future<TicketEntity> updateTicketStatus({
    required String ticketId,
    required TicketStatus status,
  }) async {
    try {
      final model = await _remoteDataSource.patchTicketStatus(
        ticketId,
        TicketModel.statusToApi(status),
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'ticket_status_update_failed');
    }
  }

  @override
  Future<void> reportTicket({
    required String ticketId,
    String? ticketUpdateId,
  }) async {
    try {
      await _remoteDataSource.reportTicket(
        ticketId: ticketId,
        ticketUpdateId: ticketUpdateId,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'ticket_report_failed');
    }
  }

  @override
  Future<TicketRestrictionStatusEntity> getMyTicketRestriction() async {
    try {
      final model = await _remoteDataSource.getMyTicketRestriction();
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'ticket_restriction_fetch_failed');
    }
  }

  @override
  Future<TicketRestrictionStatusEntity> getApartmentTicketRestriction(
    String apartmentId,
  ) async {
    try {
      final model =
          await _remoteDataSource.getApartmentTicketRestriction(apartmentId);
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'ticket_restriction_fetch_failed');
    }
  }

  @override
  Future<TicketRestrictionStatusEntity> createApartmentTicketRestriction({
    required String apartmentId,
    required String ticketId,
    String? note,
  }) async {
    try {
      final model = await _remoteDataSource.createApartmentTicketRestriction(
        apartmentId: apartmentId,
        ticketId: ticketId,
        note: note,
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'ticket_restriction_create_failed');
    }
  }

  @override
  Future<void> liftApartmentTicketRestriction(String apartmentId) async {
    try {
      await _remoteDataSource.liftApartmentTicketRestriction(apartmentId);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'ticket_restriction_lift_failed');
    }
  }
}
