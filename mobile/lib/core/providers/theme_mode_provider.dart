import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_storage.dart';
import '../theme/app_color_palette.dart';
import '../theme/app_colors.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

enum AppThemePreference { light, dark, system }

AppThemePreference? _bootThemePreference;

AppThemePreference _parseThemePreference(String? raw) {
  switch (raw) {
    case 'light':
      return AppThemePreference.light;
    case 'dark':
      return AppThemePreference.dark;
    case 'system':
      return AppThemePreference.system;
    default:
      return AppThemePreference.system;
  }
}

String themePreferenceToStorage(AppThemePreference pref) {
  switch (pref) {
    case AppThemePreference.light:
      return 'light';
    case AppThemePreference.dark:
      return 'dark';
    case AppThemePreference.system:
      return 'system';
  }
}

bool isDarkTheme(AppThemePreference pref, Brightness platformBrightness) {
  return switch (pref) {
    AppThemePreference.light => false,
    AppThemePreference.dark => true,
    AppThemePreference.system => platformBrightness == Brightness.dark,
  };
}

ThemeMode resolveThemeMode(AppThemePreference pref) {
  return switch (pref) {
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
    AppThemePreference.system => ThemeMode.system,
  };
}

void syncAppColors(AppThemePreference pref, Brightness platformBrightness) {
  AppColors.applyPalette(
    isDarkTheme(pref, platformBrightness)
        ? AppColorPalette.dark
        : AppColorPalette.light,
  );
}

class ThemeModeNotifier extends Notifier<AppThemePreference> {
  @override
  AppThemePreference build() =>
      _bootThemePreference ?? AppThemePreference.system;

  void update(AppThemePreference pref) {
    // Önce AppColors static field'larını güncelle, SONRA state'i değiştir.
    // Bu sıralama, Riverpod'un watcher'ları tetiklemesi anında
    // AppColors'in zaten doğru palete sahip olmasını garanti eder.
    // Aksi halde widget rebuild'i sırasında eski renkler okunur
    // ve alt navigasyon/tab bar anlık beyaz kalır.
    syncAppColors(
      pref,
      WidgetsBinding.instance.platformDispatcher.platformBrightness,
    );
    state = pref;
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, AppThemePreference>(
      ThemeModeNotifier.new,
    );

Future<void> initTheme() async {
  final storage = SecureStorage();
  final saved = await storage.getTheme();
  final pref = saved != null
      ? _parseThemePreference(saved)
      : AppThemePreference.system;
  _bootThemePreference = pref;
  syncAppColors(
    pref,
    WidgetsBinding.instance.platformDispatcher.platformBrightness,
  );
}

Future<void> changeThemeMode(WidgetRef ref, AppThemePreference pref) async {
  ref.read(themeModeProvider.notifier).update(pref);
  await ref
      .read(secureStorageProvider)
      .saveTheme(themePreferenceToStorage(pref));
}
