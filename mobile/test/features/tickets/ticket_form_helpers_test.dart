import 'package:aidatpanel/features/tickets/presentation/utils/ticket_form_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('deriveTicketTitle', () {
    test('uses first line trimmed', () {
      expect(
        deriveTicketTitle('Asansör çalışmıyor\nDetay satırı'),
        'Asansör çalışmıyor',
      );
    });

    test('truncates long first line to 120 chars', () {
      final long = 'a' * 130;
      final title = deriveTicketTitle(long);
      expect(title.length, 120);
      expect(title.endsWith('...'), isTrue);
    });

    test('falls back to Talep when empty', () {
      expect(deriveTicketTitle('   '), 'Talep');
    });
  });
}
