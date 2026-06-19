import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/theme_mode_provider.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../l10n/strings.g.dart';
import '../premium_bottom_sheet.dart';
import '../toast_overlay.dart';

String themePreferenceLabel(BuildContext context, AppThemePreference pref) {
  final t = context.t.common;
  return switch (pref) {
    AppThemePreference.light => t.themeLight,
    AppThemePreference.dark => t.themeDark,
    AppThemePreference.system => t.themeSystem,
  };
}

void showThemeSheet(BuildContext context, WidgetRef ref) {
  final t = context.t;
  PremiumBottomSheetScaffold.show<void>(
    context: context,
    builder: (sheetContext) => Consumer(
      builder: (context, ref, _) {
        final currentTheme = ref.watch(themeModeProvider);

        Future<void> selectTheme(AppThemePreference pref) async {
          ref.read(themeModeProvider.notifier).update(pref);
          if (sheetContext.mounted) {
            Navigator.pop(sheetContext);
          }
          try {
            await ref
                .read(secureStorageProvider)
                .saveTheme(themePreferenceToStorage(pref));
          } catch (_) {}
        }

        return PremiumBottomSheetScaffold(
          title: t.common.theme,
          scrollable: false,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.common.themeSheetDescription,
                style: ProfileSettingsUi.handle,
              ),
              const SizedBox(height: AppSizes.spacingL),
              PremiumActionSheetTile(
                icon: Icons.light_mode_rounded,
                label: t.common.themeLight,
                subtitle: 'Light',
                trailing: currentTheme == AppThemePreference.light
                    ? Icon(Icons.check_rounded, color: AppColors.inkDark)
                    : null,
                onTap: () => selectTheme(AppThemePreference.light),
              ),
              PremiumActionSheetTile(
                icon: Icons.dark_mode_rounded,
                label: t.common.themeDark,
                subtitle: 'Dark',
                trailing: currentTheme == AppThemePreference.dark
                    ? Icon(Icons.check_rounded, color: AppColors.inkDark)
                    : null,
                onTap: () => selectTheme(AppThemePreference.dark),
              ),
              PremiumActionSheetTile(
                icon: Icons.brightness_auto_rounded,
                label: t.common.themeSystem,
                subtitle: 'System',
                trailing: currentTheme == AppThemePreference.system
                    ? Icon(Icons.check_rounded, color: AppColors.inkDark)
                    : null,
                onTap: () => selectTheme(AppThemePreference.system),
              ),
            ],
          ),
        );
      },
    ),
  );
}

void showLanguageSheet(BuildContext context, WidgetRef ref) {
  final t = context.t;
  PremiumBottomSheetScaffold.show<void>(
    context: context,
    builder: (sheetContext) => Consumer(
      builder: (context, ref, _) {
        final currentLocale = ref.watch(localeProvider);

        return PremiumBottomSheetScaffold(
          title: t.common.language,
          scrollable: false,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.common.languageSheetDescription,
                style: ProfileSettingsUi.handle,
              ),
              const SizedBox(height: AppSizes.spacingL),
              PremiumActionSheetTile(
                icon: Icons.language_rounded,
                label: 'Türkçe',
                subtitle: 'Turkish',
                trailing: currentLocale == AppLocale.tr
                    ? Icon(Icons.check_rounded, color: AppColors.inkDark)
                    : null,
                onTap: () async {
                  final ok = await changeLocale(ref, AppLocale.tr);
                  if (!sheetContext.mounted) return;
                  Navigator.pop(sheetContext);
                  if (!ok) {
                    ref.read(toastProvider.notifier).show(
                          context.t.features.profile.profileUpdateFailed,
                          type: ToastType.error,
                        );
                  }
                },
              ),
              PremiumActionSheetTile(
                icon: Icons.translate_rounded,
                label: 'English',
                subtitle: 'İngilizce',
                trailing: currentLocale == AppLocale.en
                    ? Icon(Icons.check_rounded, color: AppColors.inkDark)
                    : null,
                onTap: () async {
                  final ok = await changeLocale(ref, AppLocale.en);
                  if (!sheetContext.mounted) return;
                  Navigator.pop(sheetContext);
                  if (!ok) {
                    ref.read(toastProvider.notifier).show(
                          context.t.features.profile.profileUpdateFailed,
                          type: ToastType.error,
                        );
                  }
                },
              ),
            ],
          ),
        );
      },
    ),
  );
}
