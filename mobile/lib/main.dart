import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'core/constants/app_constants.dart';
import 'core/notifications/fcm_scope.dart';
import 'core/notifications/firebase_bootstrap.dart';
import 'core/providers/theme_mode_provider.dart';
import 'core/navigation/invite_deep_link_listener.dart';
import 'core/router/app_router.dart';
import 'core/subscription/revenue_cat_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/init_date_formatting.dart';
import 'core/storage/secure_storage.dart';
import 'features/dekont/presentation/providers/share_intent_provider.dart';
import 'shared/widgets/friendly_error_screen.dart';
import 'shared/widgets/toast_overlay.dart';
import 'l10n/strings.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installGlobalErrorHandlers();
  try {
    await initFirebase();
  } catch (e, st) {
    developer.log('initFirebase başarısız', name: 'main', error: e, stackTrace: st);
  }
  try {
    await initAppInfo();
  } catch (e, st) {
    developer.log('initAppInfo başarısız', name: 'main', error: e, stackTrace: st);
  }
  try {
    await initLocale();
  } catch (e, st) {
    developer.log('initLocale başarısız', name: 'main', error: e, stackTrace: st);
    LocaleSettings.setLocale(AppLocale.tr);
  }
  try {
    await initTheme();
  } catch (e, st) {
    developer.log('initTheme başarısız', name: 'main', error: e, stackTrace: st);
  }
  try {
    await initDateFormatting();
  } catch (e, st) {
    developer.log(
      'initDateFormatting başarısız',
      name: 'main',
      error: e,
      stackTrace: st,
    );
  }
  try {
    await RevenueCatService.configure();
  } catch (e, st) {
    developer.log(
      'RevenueCat configure başarısız',
      name: 'main',
      error: e,
      stackTrace: st,
    );
  }
  runApp(const ProviderScope(child: MyApp()));
}

/// - `ErrorWidget.builder`: build sırasında bir widget exception fırlatırsa
///   Flutter'ın varsayılan kıpkırmızı ekranı yerine kibarca kullanıcıya bildir.
/// - `FlutterError.onError`: framework içinde yakalanan hataları (build, layout
///   vb.) konsola düzgün bas; release'de Crashlytics'e bağlanabilir.
/// - `PlatformDispatcher.instance.onError`: zone dışı async uncaught error'ları
///   yakala (örn. bir Future error'ı kimse await etmediyse). `true` döndürmek
///   "ben hallettim, framework'e crash bildirme" demektir.
void _installGlobalErrorHandlers() {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
    originalOnError?.call(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('[PlatformDispatcher] Uncaught: $error\n$stack');
    }
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return FriendlyErrorScreen(details: details);
  };
}

Future<void> initAppInfo() async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    AppConstants.appVersion = packageInfo.version;
  } catch (_) {
    // Eklenti kaydı başarısızsa uygulama yine açılsın (sürüm gösterimi boş kalabilir).
  }
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

void applySystemChromeOverlay(bool isDark) {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  /// Uygulamayı Cold Start gibi komple yeniden başlatır.
  /// Logout/hesap değişimi sırasında çağrılarak tüm State,
  /// Provider ve cache'lerin bellekten uçması garanti edilir.
  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()?.restartApp();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key _appKey = UniqueKey();

  void restartApp() {
    setState(() {
      _appKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _MyAppContent(key: _appKey);
  }
}

class _MyAppContent extends ConsumerStatefulWidget {
  const _MyAppContent({super.key});

  @override
  ConsumerState<_MyAppContent> createState() => _MyAppContentState();
}

class _MyAppContentState extends ConsumerState<_MyAppContent>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final pref = ref.read(themeModeProvider);
    if (pref == AppThemePreference.system) {
      syncAppColors(
        pref,
        WidgetsBinding.instance.platformDispatcher.platformBrightness,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(shareIntentProvider);

    final themePref = ref.watch(themeModeProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    syncAppColors(themePref, platformBrightness);
    final isDark = isDarkTheme(themePref, platformBrightness);
    applySystemChromeOverlay(isDark);
    final subtreeKey = themeSubtreeKey(themePref, platformBrightness);

    final router = ref.watch(appRouterProvider);
    return TranslationProvider(
      child: MaterialApp.router(
        title: 'AidatPanel',
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: resolveThemeMode(themePref),
        routerConfig: router,
        locale: LocaleSettings.currentLocale.flutterLocale,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocaleUtils.supportedLocales,
        builder: (context, child) {
          return InviteDeepLinkListener(
            child: FcmScope(
              child: ToastOverlay(
                child: KeyedSubtree(
                  key: ValueKey(subtreeKey),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
