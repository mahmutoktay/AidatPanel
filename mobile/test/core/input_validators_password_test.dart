import 'package:aidatpanel/core/utils/input_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InputValidators.validatePassword', () {
    test('accepts letter + digit without special character', () {
      expect(InputValidators.validatePassword('Abc123'), isNull);
    });

    test('accepts optional special characters', () {
      expect(InputValidators.validatePassword('Abc123!'), isNull);
      expect(InputValidators.validatePassword('Aidat#2026'), isNull);
    });

    test('rejects letters only or digits only', () {
      expect(
        InputValidators.validatePassword('abcdef'),
        'password_number_required',
      );
      expect(
        InputValidators.validatePassword('123456'),
        'password_letter_required',
      );
    });

    test('rejects too short', () {
      expect(InputValidators.validatePassword('Ab1'), 'password_too_short');
    });
  });
}
