import 'package:intl/intl.dart';

import 'app_intl_locale.dart';

/// Uygulama diline göre compact sayı / para formatı.
/// Türkçe: bin → B · İngilizce: bin → K.
class CompactNumberFormat {
  CompactNumberFormat._();

  static bool _isTurkish([String? languageCode]) {
    final code = languageCode ?? AppIntlLocale.resolve().split('_').first;
    return code.startsWith('tr');
  }

  /// ICU compact currency; Türkçe'de K kalırsa B'ye çevirir.
  static String currency(
    num value, {
    String? languageCode,
    String symbol = '₺',
    int decimalDigits = 0,
  }) {
    final formatted = NumberFormat.compactCurrency(
      locale: AppIntlLocale.resolve(languageCode),
      symbol: symbol,
      decimalDigits: decimalDigits,
    ).format(value);
    return _localizeCompactSuffix(formatted, languageCode: languageCode);
  }

  static String number(num value, {String? languageCode}) {
    final formatted = NumberFormat.compact(
      locale: AppIntlLocale.resolve(languageCode),
    ).format(value);
    return _localizeCompactSuffix(formatted, languageCode: languageCode);
  }

  static String _localizeCompactSuffix(
    String formatted, {
    String? languageCode,
  }) {
    if (!_isTurkish(languageCode)) return formatted;
    return formatted.replaceAllMapped(
      RegExp(r'(\d)[Kk](?!\w)'),
      (match) => '${match[1]}B',
    );
  }
}
