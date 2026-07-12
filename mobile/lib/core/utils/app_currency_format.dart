import 'package:intl/intl.dart';

import 'app_intl_locale.dart';

/// Para formatı — şimdilik her zaman ₺; ileride locale-aware genişletilebilir.
abstract final class AppCurrencyFormat {
  /// Gelecekte: (symbol, isoCode) döndürülebilir.
  static const String symbol = '₺';
  static const String isoCode = 'TRY';

  /// API/DB ISO kodunu UI sembolüne çevirir (`TRY` → `₺`).
  static String displaySymbol(String? code) {
    if (code == null || code.trim().isEmpty) return symbol;
    final normalized = code.trim().toUpperCase();
    if (normalized == 'TRY' || normalized == 'TL') return symbol;
    return code.trim();
  }

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

  /// `1250.50 TRY` benzeri ham metinleri `₺` ile birleştirir.
  static String formatWithCode(
    num value,
    String? currencyCode, {
    String? languageCode,
    int decimalDigits = 2,
  }) {
    final formatted = value.toStringAsFixed(decimalDigits);
    return '$formatted ${displaySymbol(currencyCode)}';
  }
}
