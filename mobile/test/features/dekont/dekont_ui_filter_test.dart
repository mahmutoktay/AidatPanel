import 'package:flutter_test/flutter_test.dart';

import 'package:aidatpanel/features/dekont/domain/entities/dekont_status.dart';
import 'package:aidatpanel/features/dekont/presentation/utils/dekont_labels.dart';

void main() {
  group('dekontMatchesUiFilter', () {
    test('pending includes MATCHED awaiting manager approval', () {
      expect(
        dekontMatchesUiFilter(DekontStatus.matched, 'pending'),
        isTrue,
      );
    });

    test('pending excludes PAYMENT_APPLIED', () {
      expect(
        dekontMatchesUiFilter(DekontStatus.paymentApplied, 'pending'),
        isFalse,
      );
    });

    test('approved includes PAYMENT_APPLIED', () {
      expect(
        dekontMatchesUiFilter(DekontStatus.paymentApplied, 'approved'),
        isTrue,
      );
    });

    test('rejected includes only REJECTED', () {
      expect(
        dekontMatchesUiFilter(DekontStatus.rejected, 'rejected'),
        isTrue,
      );
      expect(
        dekontMatchesUiFilter(DekontStatus.matched, 'rejected'),
        isFalse,
      );
    });
  });
}
