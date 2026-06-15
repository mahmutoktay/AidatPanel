import 'package:aidatpanel/core/utils/compact_number_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CompactNumberFormat.currency', () {
    test('Türkçe binlik kısaltması B kullanır', () {
      final formatted = CompactNumberFormat.currency(
        54000,
        languageCode: 'tr',
      );
      expect(formatted.contains('B'), isTrue);
      expect(formatted.contains('K'), isFalse);
    });

    test('İngilizce binlik kısaltması K kullanır', () {
      final formatted = CompactNumberFormat.currency(
        54000,
        languageCode: 'en',
      );
      expect(formatted.contains('K'), isTrue);
      expect(formatted.contains('B'), isFalse);
    });
  });

  group('CompactNumberFormat.number', () {
    test('Türkçe compact sayı B kullanır', () {
      final formatted = CompactNumberFormat.number(54000, languageCode: 'tr');
      expect(formatted.contains('B'), isTrue);
      expect(formatted.contains('K'), isFalse);
    });

    test('İngilizce compact sayı K kullanır', () {
      final formatted = CompactNumberFormat.number(54000, languageCode: 'en');
      expect(formatted.contains('K'), isTrue);
    });
  });
}
