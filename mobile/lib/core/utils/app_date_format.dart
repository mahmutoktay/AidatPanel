import 'package:intl/intl.dart';

import 'app_intl_locale.dart';

/// Uygulama genelinde tutarlı tarih formatları.
abstract final class AppDateFormat {
  static String dateTimeMedium(
    DateTime date, {
    String? languageCode,
  }) =>
      DateFormat(
        'd MMMM yyyy, HH:mm',
        AppIntlLocale.resolve(languageCode),
      ).format(date.toLocal());

  static String dateMedium(
    DateTime date, {
    String? languageCode,
  }) =>
      DateFormat(
        'd MMMM yyyy',
        AppIntlLocale.resolve(languageCode),
      ).format(date.toLocal());

  static String dateShort(
    DateTime date, {
    String? languageCode,
  }) =>
      DateFormat(
        'd MMM yyyy, HH:mm',
        AppIntlLocale.resolve(languageCode),
      ).format(date.toLocal());

  static String dateShortNoYear(
    DateTime date, {
    String? languageCode,
  }) =>
      DateFormat(
        'd MMM, HH:mm',
        AppIntlLocale.resolve(languageCode),
      ).format(date.toLocal());

  static String monthYear(
    DateTime date, {
    String? languageCode,
  }) =>
      DateFormat(
        'MMMM yyyy',
        AppIntlLocale.resolve(languageCode),
      ).format(date.toLocal());

  static String monthShort(
    DateTime date, {
    String? languageCode,
  }) =>
      DateFormat(
        'MMM',
        AppIntlLocale.resolve(languageCode),
      ).format(date.toLocal());

  static String yearMonthDay(
    DateTime date, {
    String? languageCode,
  }) =>
      DateFormat.yMMMMd(
        AppIntlLocale.resolve(languageCode),
      ).format(date.toLocal());

  static String timeOnly(
    DateTime date, {
    String? languageCode,
  }) =>
      DateFormat(
        'HH:mm',
        AppIntlLocale.resolve(languageCode),
      ).format(date.toLocal());

  static String weekdayTime(
    DateTime date, {
    String? languageCode,
  }) =>
      DateFormat(
        'EEEE, HH:mm',
        AppIntlLocale.resolve(languageCode),
      ).format(date.toLocal());

  static String relativeListDate(
    DateTime date, {
    required bool sameYear,
    String? languageCode,
  }) {
    final pattern = sameYear ? 'd MMM, HH:mm' : 'd MMM yyyy';
    return DateFormat(
      pattern,
      AppIntlLocale.resolve(languageCode),
    ).format(date.toLocal());
  }
}
