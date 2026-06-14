import 'package:aidatpanel/core/network/pagination_parse.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parsePaginatedList', () {
    test('düz dizi parse eder', () {
      final result = parsePaginatedList<Map<String, dynamic>>(
        [
          {'id': '1'},
          {'id': '2'},
        ],
        (json) => json,
      );
      expect(result.items.length, 2);
      expect(result.nextCursor, isNull);
      expect(result.hasMore, isFalse);
    });

    test('items + nextCursor parse eder', () {
      final result = parsePaginatedList<Map<String, dynamic>>(
        {
          'items': [
            {'id': 'a'},
          ],
          'nextCursor': 'cursor-1',
        },
        (json) => json,
      );
      expect(result.items.single['id'], 'a');
      expect(result.nextCursor, 'cursor-1');
      expect(result.hasMore, isTrue);
    });
  });

  group('paginatedQuery', () {
    test('cursor ve limit ekler', () {
      final q = paginatedQuery(cursor: 'abc', limit: 20);
      expect(q['paginated'], 'true');
      expect(q['cursor'], 'abc');
      expect(q['limit'], 20);
    });
  });
}
