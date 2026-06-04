import 'package:aidatpanel/core/network/api_exception.dart';
import 'package:aidatpanel/features/dekont/data/models/dekont_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('409 conflict payload', () {
    test('parses embedded dekont from data.dekont', () {
      final body = {
        'success': false,
        'message': 'Bu dekont dosyası daha önce yüklenmiş.',
        'data': {
          'dekontId': 'id-1',
          'dekont': {
            'id': 'id-1',
            'buildingId': 'b1',
            'uploadedById': 'u1',
            'status': 'RECEIVED',
            'source': 'RESIDENT_UPLOAD',
            'originalFilename': 'dekont.pdf',
            'mimeType': 'application/pdf',
            'sizeBytes': 100,
            'createdAt': '2026-06-04T18:00:00.000Z',
            'updatedAt': '2026-06-04T18:00:00.000Z',
          },
        },
      };
      final payload = body['data'] as Map<String, dynamic>;
      final model = DekontModel.fromJson(
        Map<String, dynamic>.from(payload['dekont'] as Map),
      );
      expect(model.id, 'id-1');
      expect(model.sizeBytes, 100);
    });
  });

  group('recovery eligibility', () {
    bool shouldRecover(ApiException e) {
      if (e is NetworkException) return false;
      if (e.statusCode == 409) return false;
      if (e.statusCode == 401 || e.statusCode == 403) return false;
      if (e.statusCode == 400 || e.statusCode == 422 || e.statusCode == 413) {
        return false;
      }
      return true;
    }

    test('network errors skip recovery', () {
      expect(shouldRecover(NetworkException()), isFalse);
    });

    test('409 skips recovery', () {
      expect(
        shouldRecover(ApiException(message: 'dup', statusCode: 409)),
        isFalse,
      );
    });

    test('5xx attempts recovery', () {
      expect(
        shouldRecover(ApiException(message: 'err', statusCode: 500)),
        isTrue,
      );
    });

    test('502 ServerException preserves status for retry', () {
      final ex = ServerException(message: 'Bad Gateway', statusCode: 502);
      expect(ex.statusCode, 502);
      expect(shouldRecover(ex), isTrue);
    });

    test('503 ServerException preserves status for retry', () {
      final ex = ServerException(message: 'Unavailable', statusCode: 503);
      expect(ex.statusCode, 503);
      expect(shouldRecover(ex), isTrue);
    });

    test('ServerException defaults to 500', () {
      expect(ServerException().statusCode, 500);
    });
  });

  group('strict recovery match', () {
    DekontModel model({
      required String id,
      required String name,
      required int size,
      String? dueId,
      DateTime? createdAt,
    }) {
      return DekontModel.fromJson({
        'id': id,
        'buildingId': 'b1',
        'uploadedById': 'u1',
        'dueId': dueId,
        'status': 'RECEIVED',
        'source': 'RESIDENT_UPLOAD',
        'originalFilename': name,
        'mimeType': 'application/pdf',
        'sizeBytes': size,
        'createdAt': (createdAt ?? DateTime.utc(2026, 6, 4, 12)).toIso8601String(),
        'updatedAt': (createdAt ?? DateTime.utc(2026, 6, 4, 12)).toIso8601String(),
      });
    }

    DekontModel? pickStrictMatch({
      required List<DekontModel> list,
      required String safeName,
      required String fileName,
      required int sizeBytes,
      String? dueId,
    }) {
      DekontModel? best;
      for (final m in list) {
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
      return best;
    }

    test('requires filename size and dueId together', () {
      final list = [
        model(id: 'a', name: 'other.pdf', size: 100, dueId: 'due-1'),
        model(id: 'b', name: 'dekont.pdf', size: 200, dueId: 'due-1'),
        model(id: 'c', name: 'dekont.pdf', size: 100, dueId: 'due-1'),
      ];
      final match = pickStrictMatch(
        list: list,
        safeName: 'dekont.pdf',
        fileName: 'dekont.pdf',
        sizeBytes: 100,
        dueId: 'due-1',
      );
      expect(match?.id, 'c');
    });

    test('does not match by size only', () {
      final list = [
        model(id: 'only-size', name: 'x.pdf', size: 100),
      ];
      final match = pickStrictMatch(
        list: list,
        safeName: 'dekont.pdf',
        fileName: 'dekont.pdf',
        sizeBytes: 100,
      );
      expect(match, isNull);
    });
  });
}
