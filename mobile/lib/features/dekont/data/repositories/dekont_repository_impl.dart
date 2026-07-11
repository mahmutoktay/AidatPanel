import '../../../../core/network/api_exception.dart';
import '../../../../core/network/paginated_list_result.dart';
import '../../../../core/utils/api_user_message.dart';
import '../../domain/errors/duplicate_dekont_exception.dart';
import '../../../../l10n/strings.g.dart';
import '../../debug/dekont_debug_log.dart';
import '../../../../core/utils/upload_file_utils.dart';
import '../../domain/entities/dekont_entity.dart';
import '../../domain/entities/payment_collection_entity.dart';
import '../../domain/entities/dekont_upload_result.dart';
import '../../domain/repositories/dekont_repository.dart';
import '../datasources/dekont_remote_datasource.dart';
import '../models/dekont_model.dart';

class DekontRepositoryImpl implements DekontRepository {
  final DekontRemoteDataSource _remote;

  DekontRepositoryImpl({required DekontRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<PaymentCollectionEntity> getPaymentCollection() async {
    dekontDebugLog('repository.getPaymentCollection');
    try {
      return (await _remote.getPaymentCollection()).toEntity();
    } on ApiException catch (e) {
      dekontDebugLog('repository.getPaymentCollection api', e.message);
      rethrow;
    } catch (e, st) {
      dekontDebugLog('repository.getPaymentCollection fail', '$e\n$st');
      throw ApiException(
        message: LocaleSettings
            .instance
            .currentTranslations
            .features
            .dekont
            .errorPaymentInfo,
      );
    }
  }

  @override
  Future<DekontUploadResult> uploadDekont({
    required String fileName,
    required List<int> fileBytes,
    String? filePath,
    String? dueId,
    List<String>? dueIds,
  }) async {
    dekontDebugLog('repository.uploadDekont', {
      'fileName': fileName,
      'bytes': fileBytes.length,
      'dueId': dueId,
      'dueIds': dueIds,
    });
    try {
      final entity = (await _remote.uploadDekont(
        fileName: fileName,
        fileBytes: fileBytes,
        filePath: filePath,
        dueId: dueId,
        dueIds: dueIds,
      )).toEntity();
      dekontDebugLog(
        'repository.uploadDekont ok',
        '${entity.id} ${entity.status.apiValue}',
      );
      return DekontUploadResult(dekont: entity);
    } on ApiException catch (e) {
      dekontDebugLog(
        'repository.uploadDekont api',
        'status=${e.statusCode} msg=${e.message}',
      );

      if (e.statusCode == 409) {
        final existing = await _resolveConflictEntity(e);
        if (existing != null) {
          dekontDebugLog('repository.uploadDekont duplicate', existing.id);
          throw DuplicateDekontException(
            dekont: existing,
            message: e.message,
            responseData: e.responseData,
          );
        }
      }

      if (_shouldAttemptRecovery(e)) {
        final recovered = await _tryRecoverUploadedDekont(
          fileName: fileName,
          sizeBytes: fileBytes.length,
          dueId: dueId,
        );
        if (recovered != null) {
          dekontDebugLog('repository.uploadDekont recovered', recovered.id);
          return DekontUploadResult(dekont: recovered, recovered: true);
        }
      }

      throw ApiException(
        message: mapApiUserMessage(e, context: ApiMessageContext.dekont),
        statusCode: e.statusCode,
        originalException: e.originalException,
        responseData: e.responseData,
      );
    } catch (e, st) {
      if (e is DuplicateDekontException) rethrow;
      dekontDebugLog('repository.uploadDekont unexpected', '$e\n$st');

      if (e is! NetworkException && _shouldAttemptRecoveryForUnknown(e)) {
        final recovered = await _tryRecoverUploadedDekont(
          fileName: fileName,
          sizeBytes: fileBytes.length,
          dueId: dueId,
        );
        if (recovered != null) {
          dekontDebugLog(
            'repository.uploadDekont recovered-after-timeout',
            recovered.id,
          );
          return DekontUploadResult(dekont: recovered, recovered: true);
        }
      }

      final wrapped = e is ApiException
          ? e
          : ApiException(message: e.toString(), originalException: e);
      throw ApiException(
        message: mapApiUserMessage(wrapped, context: ApiMessageContext.dekont),
        statusCode: wrapped.statusCode,
        originalException: e,
      );
    }
  }

  bool _shouldAttemptRecovery(ApiException e) {
    if (e is NetworkException) return false;
    if (e.statusCode == 409) return false;
    if (e.statusCode == 401 || e.statusCode == 403) return false;
    if (e.statusCode == 400 || e.statusCode == 422 || e.statusCode == 413) {
      return false;
    }
    return true;
  }

  bool _shouldAttemptRecoveryForUnknown(Object e) {
    if (e is NetworkException) return false;
    if (e is ApiException) return _shouldAttemptRecovery(e);
    return true;
  }

  Future<DekontEntity?> _resolveConflictEntity(ApiException e) async {
    final root = e.responseData;
    if (root == null) return null;
    final payload = root['data'];
    if (payload is! Map) return null;
    final map = Map<String, dynamic>.from(payload);
    final dekontJson = map['dekont'];
    if (dekontJson is Map) {
      try {
        return DekontModel.fromJson(
          Map<String, dynamic>.from(dekontJson),
        ).toEntity();
      } catch (_) {
        return null;
      }
    }
    final id = map['dekontId'];
    if (id is String && id.isNotEmpty) {
      try {
        return (await _remote.getDekont(id)).toEntity();
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Sunucu kaydetti ama istemci yanıtı alamadı — listeden bul.
  Future<DekontEntity?> _tryRecoverUploadedDekont({
    required String fileName,
    required int sizeBytes,
    String? dueId,
  }) async {
    dekontDebugLog('repository.recover-upload start');
    const delays = [
      Duration.zero,
      Duration(milliseconds: 800),
      Duration(seconds: 2),
    ];
    for (var attempt = 0; attempt < delays.length; attempt++) {
      if (delays[attempt] > Duration.zero) {
        await Future.delayed(delays[attempt]);
      }
      try {
        final recovered = await _matchRecoveredDekont(
          fileName: fileName,
          sizeBytes: sizeBytes,
          dueId: dueId,
        );
        if (recovered != null) {
          dekontDebugLog('repository.recover-upload ok', {
            'id': recovered.id,
            'attempt': attempt + 1,
          });
          return recovered;
        }
      } catch (e, st) {
        dekontDebugLog('repository.recover-upload attempt fail', '$e\n$st');
      }
    }
    dekontDebugLog('repository.recover-upload', 'not-found');
    return null;
  }

  Future<DekontEntity?> _matchRecoveredDekont({
    required String fileName,
    required int sizeBytes,
    String? dueId,
  }) async {
    final safeName = UploadFileUtils.safeFileName(
      fileName,
      fallback: 'dekont.pdf',
    );
    final result = await _remote.getMyDekonts(paginated: false);
    if (result.items.isEmpty) return null;

    DekontModel? best;

    for (final m in result.items) {
      final nameMatch =
          m.originalFilename == safeName || m.originalFilename == fileName;
      final sizeMatch = m.sizeBytes == sizeBytes;
      final dueMatch = dueId == null || dueId.isEmpty || m.dueId == dueId;
      if (nameMatch && sizeMatch && dueMatch) {
        if (best == null || m.createdAt.isAfter(best.createdAt)) {
          best = m;
        }
      }
    }

    return best?.toEntity();
  }

  @override
  Future<DekontEntity> getDekont(String id) async {
    try {
      return (await _remote.getDekont(id)).toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: LocaleSettings
            .instance
            .currentTranslations
            .features
            .dekont
            .errorDetailLoad,
      );
    }
  }

  @override
  Future<PaginatedListResult<DekontEntity>> getMyDekonts({
    String? status,
    String? cursor,
    bool paginated = true,
  }) async {
    try {
      final result = await _remote.getMyDekonts(
        status: status,
        cursor: cursor,
        paginated: paginated,
      );
      return PaginatedListResult(
        items: result.items.map((m) => m.toEntity()).toList(),
        nextCursor: result.nextCursor,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: LocaleSettings
            .instance
            .currentTranslations
            .features
            .dekont
            .errorListLoad,
      );
    }
  }

  @override
  Future<PaginatedListResult<DekontEntity>> getBuildingDekonts(
    String buildingId, {
    String? status,
    String? apartmentId,
    String? cursor,
    bool paginated = true,
  }) async {
    try {
      final result = await _remote.getBuildingDekonts(
        buildingId,
        status: status,
        apartmentId: apartmentId,
        cursor: cursor,
        paginated: paginated,
      );
      return PaginatedListResult(
        items: result.items.map((m) => m.toEntity()).toList(),
        nextCursor: result.nextCursor,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: LocaleSettings
            .instance
            .currentTranslations
            .features
            .dekont
            .errorListLoad,
      );
    }
  }

  @override
  Future<DekontEntity> reviewDekont({
    required String id,
    required DekontReviewDecision decision,
    String? note,
    String? dueId,
    List<String>? dueIds,
    double? amount,
  }) async {
    dekontDebugLog('repository.reviewDekont', {
      'id': id,
      'decision': decision.name,
      'dueId': dueId,
      'dueIds': dueIds,
      'amount': amount,
    });
    try {
      final apiDecision = decision == DekontReviewDecision.approve
          ? 'APPROVE'
          : 'REJECT';
      final entity = (await _remote.reviewDekont(
        id: id,
        decision: apiDecision,
        note: note,
        dueId: dueId,
        dueIds: dueIds,
        amount: amount,
      )).toEntity();
      dekontDebugLog('repository.reviewDekont ok', entity.status.apiValue);
      return entity;
    } on ApiException catch (e) {
      dekontDebugLog('repository.reviewDekont api', e.message);
      throw ApiException(
        message: mapApiUserMessage(e, context: ApiMessageContext.dekont),
        statusCode: e.statusCode,
      );
    } catch (e, st) {
      dekontDebugLog('repository.reviewDekont fail', '$e\n$st');
      throw ApiException(
        message: LocaleSettings
            .instance
            .currentTranslations
            .features
            .dekont
            .reviewFailed,
      );
    }
  }

  @override
  Future<List<int>> getDekontFileBytes(
    String id, {
    bool download = false,
  }) async {
    try {
      return await _remote.getDekontFileBytes(id, download: download);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: LocaleSettings
            .instance
            .currentTranslations
            .features
            .dekont
            .errorFileDownload,
      );
    }
  }
}
