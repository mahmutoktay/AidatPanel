import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/secure_storage.dart';
import 'shared/widgets/toast_overlay.dart';
import 'l10n/strings.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocale();
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> initLocale() async {
  final storage = SecureStorage();
  final savedLanguage = await storage.getLanguage();
  if (savedLanguage != null) {
    LocaleSettings.setLocale(
      AppLocaleUtils.parseLocaleParts(languageCode: savedLanguage),
    );
  } else {
    LocaleSettings.setLocale(AppLocale.tr);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return TranslationProvider(
      child: MaterialApp.router(
        title: 'AidatPanel',
        theme: AppTheme.lightTheme(),
        routerConfig: AppRouter.router,
        locale: LocaleSettings.currentLocale.flutterLocale,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocaleUtils.supportedLocales,
        builder: (context, child) {
          return ToastOverlay(child: child ?? const SizedBox.shrink());
        },
      ),
    );
  }
}
