import 'package:flutter/widgets.dart';

import '../../l10n/strings.g.dart';

/// Ay numarası → yerelleştirilmiş ay adı (1 = Ocak / January).
String localizedMonthName(BuildContext context, int month) {
  final t = context.t.common;
  switch (month) {
    case 1:
      return t.monthJanuary;
    case 2:
      return t.monthFebruary;
    case 3:
      return t.monthMarch;
    case 4:
      return t.monthApril;
    case 5:
      return t.monthMay;
    case 6:
      return t.monthJune;
    case 7:
      return t.monthJuly;
    case 8:
      return t.monthAugust;
    case 9:
      return t.monthSeptember;
    case 10:
      return t.monthOctober;
    case 11:
      return t.monthNovember;
    case 12:
      return t.monthDecember;
    default:
      return '$month';
  }
}
