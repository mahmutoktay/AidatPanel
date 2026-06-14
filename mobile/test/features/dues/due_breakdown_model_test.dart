import 'package:aidatpanel/features/dues/data/models/due_breakdown_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DueBreakdownModel parses API breakdown', () {
    final model = DueBreakdownModel.fromJson({
      'baseAmount': '500.00',
      'total': '850.00',
      'expenseLines': [
        {'title': 'Asansör bakımı', 'amount': '150.00', 'kind': 'EXPENSE'},
        {
          'title': 'Önceki aydan devreden — Çatı',
          'amount': '200.00',
          'kind': 'CARRYFORWARD',
        },
      ],
    });

    final entity = model.toEntity();
    expect(entity.baseAmount, 500);
    expect(entity.total, 850);
    expect(entity.expenseLines.length, 2);
    expect(entity.hasExtras, isTrue);
  });
}
