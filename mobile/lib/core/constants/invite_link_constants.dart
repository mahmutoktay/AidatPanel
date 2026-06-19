/// Davet linki ve mağaza adresleri.
class InviteLinkConstants {
  InviteLinkConstants._();

  static const String webJoinBase = 'https://aidatpanel.com/join';

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.aidatpanel.app';

  /// Ana sayfa ve davet landing ile aynı URL (yayın sonrası gerçek id ile güncellenir).
  static const String appStoreUrl =
      'https://apps.apple.com/tr/app/aidatpanel/id000000000';

  static const String androidPackage = 'com.aidatpanel.app';
  static const String iosBundleId = 'com.aidatpanel.mobile';
  static const String customScheme = 'aidatpanel';

  static String joinPathWithCode(String code) {
    return '$webJoinBase?code=${Uri.encodeComponent(code)}';
  }

  static String customSchemeUri(String code) {
    return '$customScheme://join?code=${Uri.encodeComponent(code)}';
  }
}
