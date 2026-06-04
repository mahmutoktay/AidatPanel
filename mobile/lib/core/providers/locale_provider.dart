import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../../l10n/strings.g.dart';
final localeProvider = StateProvider<AppLocale>((ref) {
  return LocaleSettings.currentLocale;
});

/// Dil değişimi: önce sunucu (`PUT /me/language`), başarılıysa lokal + SecureStorage.
/// Oturum yoksa yalnızca lokal kayıt.
Future<bool> changeLocale(WidgetRef ref, AppLocale locale) async {
  final auth = ref.read(authStateProvider);
  if (auth.isAuthenticated) {
    try {
      final user = await ref
          .read(profileRepositoryProvider)
          .updateLanguage(locale.languageCode);
      await ref.read(authStateProvider.notifier).syncCachedUser(user);
    } catch (_) {
      return false;
    }
  }

  LocaleSettings.setLocale(locale);
  ref.read(localeProvider.notifier).state = locale;
  await ref.read(secureStorageProvider).saveLanguage(locale.languageCode);
  return true;
}
