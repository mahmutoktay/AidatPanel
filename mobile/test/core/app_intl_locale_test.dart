import 'package:aidatpanel/core/utils/app_date_format.dart';
import 'package:aidatpanel/core/utils/app_intl_locale.dart';
import 'package:aidatpanel/l10n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('tr_TR');
    await initializeDateFormatting('en_US');
    LocaleSettings.setLocale(AppLocale.tr);
  });

  group('AppIntlLocale', () {
    test('maps tr to tr_TR', () {
      expect(AppIntlLocale.resolve('tr'), 'tr_TR');
    });

    test('maps en to en_US', () {
      expect(AppIntlLocale.resolve('en'), 'en_US');
    });

    test('passes through full locale tags', () {
      expect(AppIntlLocale.resolve('tr_TR'), 'tr_TR');
    });
  });

  group('AppDateFormat', () {
    test('formats month year in Turkish', () {
      LocaleSettings.setLocale(AppLocale.tr);
      final text = AppDateFormat.monthYear(DateTime(2026, 6, 1));
      expect(text.toLowerCase(), contains('haziran'));
      expect(text, contains('2026'));
    });

    test('formats month year in English', () {
      final text = AppDateFormat.monthYear(
        DateTime(2026, 6, 1),
        languageCode: 'en',
      );
      expect(text.toLowerCase(), contains('june'));
      expect(text, contains('2026'));
    });
  });
}
