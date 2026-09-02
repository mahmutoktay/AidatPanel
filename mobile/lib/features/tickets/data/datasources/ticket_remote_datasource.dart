import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/paginated_list_result.dart';
import '../../../../core/network/pagination_parse.dart';
import '../models/create_ticket_request.dart';
import '../models/ticket_model.dart';

abstract class TicketRemoteDataSource {
  Future<PaginatedListResult<TicketModel>> getMyTickets({
    String? status,
    String? category,
    String? cursor,
    bool paginated = true,
  });

  Future<PaginatedListResult<TicketModel>> getBuildingTickets(
    String buildingId, {
    String? status,
    String? category,
    String? cursor,
    bool paginated = true,
  });

  Future<TicketModel> getTicketById(String ticketId);

  Future<TicketModel> createTicket(
    String apartmentId,
    CreateTicketRequest request,
  );

  Future<TicketModel> uploadTicketAttachment({
    required String ticketId,
    required Uint8List bytes,
    required String filename,
  });

  Future<void> addTicketUpdate(String ticketId, String message);

  Future<TicketModel> patchTicketStatus(String ticketId, String status);
}

class TicketRemoteDataSourceImpl implements TicketRemoteDataSource {
  final DioClient _dioClient;

  TicketRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  Map<String, dynamic> _query({
    String? status,
    String? category,
    String? cursor,
    required bool paginated,
  }) {
    return paginatedQuery(
      cursor: cursor,
      limit: AppConstants.pageSize,
      paginated: paginated,
      extra: {
        'status': ?status,
        'category': ?category,
      },
    );
  }

  @override
  Future<PaginatedListResult<TicketModel>> getMyTickets({
    String? status,
    String? category,
    String? cursor,
    bool paginated = true,
  }) async {
    final response = await _dioClient.get(
      ApiConstants.myTickets,
      queryParameters: _query(
        status: status,
        category: category,
        cursor: cursor,
        paginated: paginated,
      ),
    );
    return parsePaginatedList(response.data['data'], TicketModel.fromJson);
  }

  @override
  Future<PaginatedListResult<TicketModel>> getBuildingTickets(
    String buildingId, {
    String? status,
    String? category,
    String? cursor,
    bool paginated = true,
  }) async {
    final response = await _dioClient.get(
      ApiConstants.buildingTickets(buildingId),
      queryParameters: _query(
        status: status,
        category: category,
        cursor: cursor,
        paginated: paginated,
      ),
    );
    return parsePaginatedList(response.data['data'], TicketModel.fromJson);
  }

  @override
  Future<TicketModel> getTicketById(String ticketId) async {
    final response = await _dioClient.get(ApiConstants.ticket(ticketId));
    return TicketModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<TicketModel> createTicket(
    String apartmentId,
    CreateTicketRequest request,
  ) async {
    final response = await _dioClient.post(
      ApiConstants.apartmentTickets(apartmentId),
      data: request.toJson(),
    );
    return TicketModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<TicketModel> uploadTicketAttachment({
    required String ticketId,
    required Uint8List bytes,
    required String filename,
  }) async {
    Future<FormData> buildForm() async => FormData.fromMap({
          'file': MultipartFile.fromBytes(bytes, filename: filename),
        });

    final response = await _dioClient.postMultipart(
      ApiConstants.ticketAttachment(ticketId),
      data: await buildForm(),
      rebuildFormData: buildForm,
    );
    return TicketModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> addTicketUpdate(String ticketId, String message) async {
    await _dioClient.post(
      ApiConstants.ticketUpdates(ticketId),
      data: {'message': message},
    );
  }

  @override
  Future<TicketModel> patchTicketStatus(String ticketId, String status) async {
    final response = await _dioClient.patch(
      ApiConstants.ticketStatus(ticketId),
      data: {'status': status},
    );
    return TicketModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
