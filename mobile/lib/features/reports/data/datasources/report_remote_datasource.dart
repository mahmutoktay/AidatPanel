import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/report_entity.dart';

abstract class ReportRemoteDataSource {
  Future<ReportFileResult> downloadReport(ReportDownloadParams params);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  ReportRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<ReportFileResult> downloadReport(ReportDownloadParams params) async {
    final query = <String, dynamic>{
      'type': params.type == ReportType.monthly ? 'monthly' : 'annual',
      'year': params.year,
    };
    if (params.type == ReportType.monthly && params.month != null) {
      query['month'] = params.month;
    }

<<<<<<< HEAD
    final path = params.isSiteReport
        ? ApiConstants.siteReports(params.siteId!)
        : ApiConstants.buildingReports(params.buildingId!);

    if (kDebugMode) {
      debugPrint(
        '[reports] GET $path base=${ApiConstants.baseUrl} query=$query',
=======
    final endpoint = params.isSiteReport
        ? ApiConstants.siteReports(params.siteId!)
        : ApiConstants.buildingReports(params.buildingId);

    if (kDebugMode) {
      debugPrint(
        '[reports] GET $endpoint base=${ApiConstants.baseUrl} query=$query',
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
      );
    }

    final response = await _dioClient.get<List<int>>(
<<<<<<< HEAD
      path,
=======
      endpoint,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
      queryParameters: query,
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(minutes: 2),
      ),
    );

    final bytes = response.data ?? [];
    if (bytes.isEmpty) {
      throw ApiException(
        message: 'report_file_empty',
        statusCode: response.statusCode,
      );
    }

    final jsonError = _tryParseJsonErrorBytes(bytes);
    if (jsonError != null) {
      throw ApiException(message: jsonError, statusCode: response.statusCode);
    }

    return ReportFileResult(bytes: bytes, fileName: _buildFileName(params));
  }

  String _buildFileName(ReportDownloadParams params) {
<<<<<<< HEAD
    final slug = params.displayName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final prefix = params.isSiteReport ? 'site-rapor' : 'rapor';
    final safeSlug = slug.isEmpty ? (params.isSiteReport ? 'site' : 'bina') : slug;
=======
    final label = params.isSiteReport ? params.siteName : params.buildingName;
    final slug = (label ?? '')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final safeSlug = slug.isEmpty
        ? (params.isSiteReport ? 'site' : 'bina')
        : slug;
    final prefix = params.isSiteReport ? 'site-rapor' : 'rapor';
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    if (params.type == ReportType.annual) {
      return '$prefix-yillik-$safeSlug-${params.year}.pdf';
    }
    final m = (params.month ?? 1).toString().padLeft(2, '0');
    return '$prefix-$safeSlug-${params.year}-$m.pdf';
  }

  String? _tryParseJsonErrorBytes(List<int> bytes) {
    if (bytes.isEmpty || bytes.length > 4096) return null;
    if (bytes.first != 0x7b && bytes.first != 0x5b) return null;
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is Map<String, dynamic>) {
        if (decoded['success'] == false) {
          final msg = decoded['message'];
          if (msg is String && msg.trim().isNotEmpty) return msg.trim();
        }
        final msg = decoded['message'];
        if (msg is String && msg.trim().isNotEmpty) return msg.trim();
      }
    } catch (_) {}
    return null;
  }
}
