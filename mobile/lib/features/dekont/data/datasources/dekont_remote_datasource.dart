import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/paginated_list_result.dart';
import '../../../../core/network/pagination_parse.dart';
import '../../../../core/utils/upload_file_utils.dart';
import '../../debug/dekont_debug_log.dart';
import '../models/dekont_model.dart';

abstract class DekontRemoteDataSource {
  Future<PaymentCollectionModel> getPaymentCollection();

  Future<DekontModel> uploadDekont({
    required String fileName,
    required List<int> fileBytes,
    String? filePath,
    String? dueId,
  });

  Future<DekontModel> getDekont(String id);

  Future<PaginatedListResult<DekontModel>> getMyDekonts({
    String? status,
    String? cursor,
    bool paginated = true,
  });

  Future<PaginatedListResult<DekontModel>> getBuildingDekonts(
    String buildingId, {
    String? status,
    String? apartmentId,
    String? cursor,
    bool paginated = true,
  });

  Future<DekontModel> reviewDekont({
    required String id,
    required String decision,
    String? note,
    String? dueId,
  });

  Future<List<int>> getDekontFileBytes(String id, {bool download = false});
}

class DekontRemoteDataSourceImpl implements DekontRemoteDataSource {
  final DioClient _dioClient;

  DekontRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  Map<String, dynamic>? _query({
    String? status,
    String? apartmentId,
    String? cursor,
    bool paginated = true,
  }) {
    final q = paginatedQuery(
      cursor: cursor,
      limit: paginated ? AppConstants.pageSize : null,
      paginated: paginated,
      extra: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (apartmentId != null && apartmentId.isNotEmpty)
          'apartmentId': apartmentId,
      },
    );
    return q.isEmpty ? null : q;
  }

  @override
  Future<PaymentCollectionModel> getPaymentCollection() async {
    dekontDebugLog('datasource.getPaymentCollection start');
    try {
      final response = await _dioClient.get(ApiConstants.myPaymentCollection);
      final data = response.data['data'] as Map<String, dynamic>;
      final model = PaymentCollectionModel.fromJson(data);
      dekontDebugLog('datasource.getPaymentCollection ok', {
        'buildingId': model.buildingId,
        'configured': model.isCollectionConfigured,
      });
      return model;
    } catch (e, st) {
      dekontDebugLog('datasource.getPaymentCollection fail', '$e\n$st');
      rethrow;
    }
  }

  @override
  Future<DekontModel> uploadDekont({
    required String fileName,
    required List<int> fileBytes,
    String? filePath,
    String? dueId,
  }) async {
    if ((filePath == null || filePath.isEmpty) && fileBytes.isEmpty) {
      throw ApiException(message: 'Dosya boş');
    }

    final safeName = UploadFileUtils.safeFileName(
      fileName,
      fallback: 'dekont.pdf',
    );
    final ext = UploadFileUtils.extensionFromPath(safeName);
    final mime = UploadFileUtils.mimeTypeForExtension(ext);
    if (mime == null) {
      throw ApiException(message: 'Desteklenmeyen dosya türü');
    }

    FormData buildForm() {
      final filePart = MultipartFile.fromBytes(
        fileBytes,
        filename: safeName,
        contentType: DioMediaType.parse(mime),
      );

      final formFields = <String, dynamic>{'file': filePart};
      if (dueId != null && dueId.isNotEmpty) {
        formFields['dueId'] = dueId;
      }
      return FormData.fromMap(formFields);
    }

    dekontDebugLog(
      'datasource.uploadDekont start',
      '$safeName ${(fileBytes.length / 1024).toStringAsFixed(1)} KB dueId=${dueId ?? "-"}',
    );

    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      if (attempt > 0) {
        await Future.delayed(Duration(seconds: attempt * 2));
        dekontDebugLog('datasource.uploadDekont retry', attempt + 1);
      }
      try {
        final response = await _dioClient.postMultipart(
          ApiConstants.dekontUpload,
          data: buildForm(),
          rebuildFormData: () async => buildForm(),
        );
        final code = response.statusCode;
        dekontDebugLog(
          'datasource.uploadDekont response',
          'status=$code attempt=${attempt + 1}',
        );
        if (code != null && code >= 400) {
          throw ApiException(
            message: 'Dekont yüklenemedi',
            statusCode: code,
            responseData: response.data is Map
                ? Map<String, dynamic>.from(response.data as Map)
                : null,
          );
        }
        final model = _parseDekontResponse(response);
        dekontDebugLog(
          'datasource.uploadDekont ok',
          'id=${model.id} status=${model.status}',
        );
        return model;
      } on ApiException catch (e) {
        lastError = e;
        final retryable =
            e.statusCode == 502 || e.statusCode == 503 || e is NetworkException;
        if (!retryable || attempt >= 2) {
          dekontDebugLog(
            'datasource.uploadDekont fail',
            'status=${e.statusCode} msg=${e.message}',
          );
          rethrow;
        }
      } catch (e, st) {
        lastError = e;
        dekontDebugLog('datasource.uploadDekont fail', '$e\n$st');
        rethrow;
      }
    }

    throw lastError ?? ApiException(message: 'Dekont yüklenemedi');
  }

  /// Hata durumunda sunucu JSON döndürdüyse (bytes olarak) mesajı çıkar.
  String? _tryParseJsonErrorBytes(List<int> bytes) {
    if (bytes.isEmpty || bytes.length > 4096) return null;
    if (bytes.first != 0x7b && bytes.first != 0x5b) {
      return null;
    }
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
    } catch (_) {
      return null;
    }
    return null;
  }

  Map<String, dynamic> _decodeBody(dynamic raw) {
    var value = raw;
    if (value is String && value.trim().isNotEmpty) {
      try {
        value = jsonDecode(value);
      } catch (_) {
        throw ApiException(message: 'Sunucu yanıtı okunamadı');
      }
    }
    if (value is! Map) {
      throw ApiException(message: 'Sunucu yanıtı okunamadı');
    }
    return Map<String, dynamic>.from(value);
  }

  Map<String, dynamic> _decodeDataField(dynamic raw) {
    final body = _decodeBody(raw);
    final data = body['data'];
    if (data is! Map) {
      throw ApiException(message: 'Dekont yanıtı eksik');
    }
    return Map<String, dynamic>.from(data);
  }

  DekontModel _parseDekontResponse(Response<dynamic> response) {
    return _parseDekontUploadPayload(
      response.data,
      statusCode: response.statusCode,
    );
  }

  /// Upload yanıtı: `{ success, data }` veya doğrudan dekont nesnesi olabilir.
  DekontModel _parseDekontUploadPayload(dynamic raw, {int? statusCode}) {
    final body = _decodeBody(raw);

    if (body['success'] == false) {
      throw ApiException(
        message: (body['message'] as String?)?.trim().isNotEmpty == true
            ? body['message'] as String
            : 'Dekont yüklenemedi',
        statusCode: statusCode,
      );
    }

    dynamic data = body['data'];
    if (data is! Map) {
      // Bazı proxy'ler / eski API sürümleri yalnızca dekont nesnesi döndürebilir.
      if (body['id'] != null && body['status'] != null) {
        data = body;
      } else {
        throw ApiException(
          message: 'Dekont yanıtı eksik',
          statusCode: statusCode,
        );
      }
    }

    try {
      return DekontModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[dekont-upload] parse hata: $e\n$st\npayload: $data');
      }
      throw ApiException(
        message: 'Dekont yanıtı işlenemedi',
        statusCode: statusCode,
      );
    }
  }

  DekontModel _parseDekontModel(Response<dynamic> response) {
    return DekontModel.fromJson(_decodeDataField(response.data));
  }

  PaginatedListResult<DekontModel> _parseDekontListResponse(dynamic raw) {
    final body = _decodeBody(raw);
    return parsePaginatedList(body['data'], DekontModel.fromJson);
  }

  @override
  Future<DekontModel> getDekont(String id) async {
    dekontDebugLog('datasource.getDekont start', id);
    try {
      final response = await _dioClient.get(ApiConstants.dekont(id));
      final model = _parseDekontModel(response);
      dekontDebugLog('datasource.getDekont ok', '${model.id} ${model.status}');
      return model;
    } catch (e, st) {
      dekontDebugLog('datasource.getDekont fail', '$e\n$st');
      rethrow;
    }
  }

  @override
  Future<PaginatedListResult<DekontModel>> getMyDekonts({
    String? status,
    String? cursor,
    bool paginated = true,
  }) async {
    dekontDebugLog('datasource.getMyDekonts start', 'status=$status');
    try {
      final response = await _dioClient.get(
        ApiConstants.myDekonts,
        queryParameters: _query(
          status: status,
          cursor: cursor,
          paginated: paginated,
        ),
      );
      final result = _parseDekontListResponse(response.data);
      dekontDebugLog(
        'datasource.getMyDekonts ok',
        'count=${result.items.length}',
      );
      return result;
    } catch (e, st) {
      dekontDebugLog('datasource.getMyDekonts fail', '$e\n$st');
      rethrow;
    }
  }

  @override
  Future<PaginatedListResult<DekontModel>> getBuildingDekonts(
    String buildingId, {
    String? status,
    String? apartmentId,
    String? cursor,
    bool paginated = true,
  }) async {
    dekontDebugLog('datasource.getBuildingDekonts start', {
      'buildingId': buildingId,
      'status': status,
      'apartmentId': apartmentId,
    });
    try {
      final response = await _dioClient.get(
        ApiConstants.buildingDekonts(buildingId),
        queryParameters: _query(
          status: status,
          apartmentId: apartmentId,
          cursor: cursor,
          paginated: paginated,
        ),
      );
      final result = _parseDekontListResponse(response.data);
      dekontDebugLog(
        'datasource.getBuildingDekonts ok',
        'count=${result.items.length}',
      );
      return result;
    } catch (e, st) {
      dekontDebugLog('datasource.getBuildingDekonts fail', '$e\n$st');
      rethrow;
    }
  }

  @override
  Future<DekontModel> reviewDekont({
    required String id,
    required String decision,
    String? note,
    String? dueId,
  }) async {
    dekontDebugLog('datasource.reviewDekont start', {
      'id': id,
      'decision': decision,
      'dueId': dueId,
    });
    try {
      final body = <String, dynamic>{'decision': decision};
      if (note != null && note.trim().isNotEmpty) body['note'] = note.trim();
      if (dueId != null && dueId.isNotEmpty) body['dueId'] = dueId;

      final response = await _dioClient.patch(
        ApiConstants.dekontReview(id),
        data: body,
      );
      final model = _parseDekontModel(response);
      dekontDebugLog(
        'datasource.reviewDekont ok',
        '${model.id} ${model.status}',
      );
      return model;
    } catch (e, st) {
      dekontDebugLog('datasource.reviewDekont fail', '$e\n$st');
      rethrow;
    }
  }

  @override
  Future<List<int>> getDekontFileBytes(
    String id, {
    bool download = false,
  }) async {
    dekontDebugLog('datasource.getDekontFileBytes start', {
      'id': id,
      'download': download,
    });
    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      if (attempt > 0) {
        await Future.delayed(Duration(seconds: attempt * 2));
        dekontDebugLog('datasource.getDekontFileBytes retry', attempt + 1);
      }
      try {
        final response = await _dioClient.get<List<int>>(
          ApiConstants.dekontFile(id),
          queryParameters: download ? {'download': '1'} : null,
          options: Options(
            responseType: ResponseType.bytes,
            receiveTimeout: const Duration(minutes: 2),
          ),
        );
        final bytes = response.data ?? [];
        if (bytes.isEmpty) {
          throw ApiException(
            message: 'Dekont dosyası bulunamadı',
            statusCode: response.statusCode,
          );
        }
        final asJson = _tryParseJsonErrorBytes(bytes);
        if (asJson != null) {
          throw ApiException(message: asJson, statusCode: response.statusCode);
        }
        dekontDebugLog(
          'datasource.getDekontFileBytes ok',
          '${bytes.length} bytes',
        );
        return bytes;
      } on ApiException catch (e) {
        lastError = e;
        final retryable =
            e.statusCode == 503 ||
            (e.statusCode == 404 && _hasFilePendingMessage(e.message));
        if (!retryable || attempt >= 2) {
          dekontDebugLog('datasource.getDekontFileBytes fail', e.message);
          rethrow;
        }
      } catch (e, st) {
        lastError = e;
        dekontDebugLog('datasource.getDekontFileBytes fail', '$e\n$st');
        rethrow;
      }
    }
    throw lastError ?? ApiException(message: 'Dekont dosyası bulunamadı');
  }

  bool _hasFilePendingMessage(String message) {
    final m = message.toLowerCase();
    return m.contains('hazırlanıyor') || m.contains('hazirlaniyor');
  }
}
