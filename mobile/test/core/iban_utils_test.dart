import 'package:aidatpanel/core/utils/iban_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IbanUtils', () {
    test('normalize strips spaces and uppercases', () {
      expect(
        IbanUtils.normalize('tr33 0006 1005 1978 6457 8413 26'),
        'TR330006100519786457841326',
      );
    });

    test('isValidTrIban accepts standard TR IBAN', () {
      expect(
        IbanUtils.isValidTrIban('TR330006100519786457841326'),
        isTrue,
      );
    });

    test('isValidTrIban rejects short or non-TR', () {
      expect(IbanUtils.isValidTrIban('TR123'), isFalse);
      expect(IbanUtils.isValidTrIban('DE89370400440532013000'), isFalse);
      expect(IbanUtils.isValidTrIban(null), isFalse);
    });

    test('formatDisplay groups by four', () {
      expect(
        IbanUtils.formatDisplay('TR330006100519786457841326'),
        'TR33 0006 1005 1978 6457 8413 26',
      );
    });
  });
}
