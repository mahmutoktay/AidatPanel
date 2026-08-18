import 'package:aidatpanel/features/auth/data/models/register_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegisterResponse.fromJson', () {
    test('parses phone-only manager register (email null)', () {
      final parsed = RegisterResponse.fromJson({
        'user': 'uid-1',
        'name': 'Ayşe Yönetici',
        'email': null,
        'phone': '5551234567',
        'role': 'MANAGER',
        'language': 'tr',
        'apartmentId': null,
      });

      expect(parsed.id, 'uid-1');
      expect(parsed.name, 'Ayşe Yönetici');
      expect(parsed.email, isNull);
      expect(parsed.phone, '5551234567');
      expect(parsed.role, 'MANAGER');
    });

    test('parses email-only manager register (phone null)', () {
      final parsed = RegisterResponse.fromJson({
        'user': 'uid-2',
        'name': 'Ali Yönetici',
        'email': 'ali@example.com',
        'phone': null,
        'role': 'MANAGER',
        'language': 'tr',
        'apartmentId': null,
      });

      expect(parsed.email, 'ali@example.com');
      expect(parsed.phone, isNull);
    });
  });
}
