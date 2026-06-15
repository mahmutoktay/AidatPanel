import 'package:flutter/widgets.dart';

import '../../l10n/strings.g.dart';

/// Uygulama dili → intl locale eşlemesi (tek kaynak).
abstract final class AppIntlLocale {
  static String resolve([String? languageCode]) {
    final code = languageCode ?? LocaleSettings.currentLocale.languageCode;
    return switch (code) {
      'tr' => 'tr_TR',
      'en' => 'en_US',
      _ => code.contains('_') ? code : '${code}_${code.toUpperCase()}',
    };
  }

  static String fromContext(BuildContext context) =>
      resolve(Localizations.localeOf(context).languageCode);
}
