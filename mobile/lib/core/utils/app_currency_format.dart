import 'package:intl/intl.dart';

import 'app_intl_locale.dart';

/// Para formatı — şimdilik her zaman ₺; ileride locale-aware genişletilebilir.
abstract final class AppCurrencyFormat {
  /// Gelecekte: (symbol, isoCode) döndürülebilir.
  static const String symbol = '₺';
  static const String isoCode = 'TRY';

  static NumberFormat standard({
    String? languageCode,
    int decimalDigits = 2,
  }) =>
      NumberFormat.currency(
        locale: AppIntlLocale.resolve(languageCode),
        symbol: symbol,
        decimalDigits: decimalDigits,
      );

  static String format(
    num value, {
    String? languageCode,
    int decimalDigits = 2,
  }) =>
      standard(
        languageCode: languageCode,
        decimalDigits: decimalDigits,
      ).format(value);
}
