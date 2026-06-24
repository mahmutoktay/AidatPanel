import 'package:aidatpanel/core/utils/turkish_string_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('turkish_string_utils', () {
    test('sortTurkishList orders ç after c and İstanbul before Zonguldak', () {
      final sorted = sortTurkishList([
        'Zonguldak',
        'Çanakkale',
        'Adana',
        'İstanbul',
        'Afyonkarahisar',
      ]);
      expect(sorted.indexOf('Çanakkale'), lessThan(sorted.indexOf('Zonguldak')));
      expect(sorted.indexOf('İstanbul'), lessThan(sorted.indexOf('Zonguldak')));
      expect(sorted.indexOf('Adana'), lessThan(sorted.indexOf('Çanakkale')));
    });

    test('filterTurkishSearch prioritizes prefix matches for is -> İstanbul', () {
      final results = filterTurkishSearch(
        ['Afyonkarahisar', 'İstanbul', 'Isparta', 'Bartın'],
        'is',
        weight: (name) => switch (name) {
          'İstanbul' => 15000000,
          'Isparta' => 500000,
          _ => 1000,
        },
      );
      expect(results.first, 'İstanbul');
      expect(results, contains('Isparta'));
      expect(results.indexOf('İstanbul'), lessThan(results.indexOf('Afyonkarahisar')));
    });

    test('normalizeTurkishForSearch folds İ and I for matching', () {
      expect(normalizeTurkishForSearch('İstanbul'), 'istanbul');
      expect(normalizeTurkishForSearch('Isparta'), 'isparta');
    });
  });
}
