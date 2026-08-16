/// Dev preview entry point — sunucu yokken UI'ı test etmek için.
///
/// Çalıştırma (--flavor zorunlu; aksi halde APK bulunamaz):
///   flutter run --flavor dev -t lib/main_dev.dart
///
/// Play Store screenshot (DEV rozeti gizli):
///   flutter run --flavor dev -t lib/main_dev.dart --dart-define=SCREENSHOT_MODE=true
/// veya aşağıda [kScreenshotMode] `defaultValue: true` yap.
///
/// Showcase seed (Vefa, Lale, Bahçeli Evler A/B/C) ile gerçekçi ekran görüntüsü.
/// Production `main.dart` dokunulmaz; ProviderScope.overrides in-memory mock kullanır:
///   - auth / building / apartment / dues / profile / subscription / tickets / dekont
///   - siteRepositoryProvider → MockSiteRepository (Bahçeli Evler)
///   - expense + notification datasources
///
/// Splash → restoreSession manager → `/manager-dashboard`.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/deep_link/invite_deep_link.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/secure_storage.dart';
import 'core/utils/init_date_formatting.dart';
import 'dev/dev_mocks.dart';
import 'dev/mock_faz2_datasources.dart';
import 'dev/mock_dekont_repository.dart';
import 'dev/mock_site_repository.dart';
import 'features/expenses/presentation/providers/expenses_provider.dart';
import 'features/notifications/presentation/providers/notifications_provider.dart';
import 'features/apartments/data/apartments_store.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/data/datasources/mock_firebase_phone_auth_datasource.dart';
import 'features/buildings/data/buildings_store.dart';
import 'features/dues/presentation/providers/dues_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/sites/data/sites_store.dart';
import 'features/subscription/presentation/providers/subscription_provider.dart';
import 'features/tickets/presentation/providers/tickets_provider.dart';
import 'features/dekont/presentation/providers/dekont_provider.dart';
import 'firebase_options.dart';
import 'shared/widgets/friendly_error_screen.dart';
import 'shared/widgets/toast_overlay.dart';
import 'l10n/strings.g.dart';

/// Play Store screenshot: `true` iken sağ üst DEV rozeti gizlenir.
/// `--dart-define=SCREENSHOT_MODE=true` ile de açılır; tek satır için
/// `defaultValue: true` yeterli.
const bool kScreenshotMode = bool.fromEnvironment(
  'SCREENSHOT_MODE',
  defaultValue: false,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installGlobalErrorHandlers();
  // GoRouter FirebaseAnalyticsObserver + bazı provider'lar DEFAULT app ister.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('[DEV] Firebase.initializeApp: $e\n$st');
    }
  }
  await _initAppInfo();
  await _initLocale();
  await initDateFormatting();

  // Apartment repository'yi önce kur — building repository FK kontrolü için
  // ona referans alıyor. (Mock dünya: bina silmek istendiğinde "daire varsa
  // hata" simülasyonu için bağlı)
  final mockApartments = MockApartmentRepository();
  final mockBuildings = MockBuildingRepository(mockApartments);
  final mockSites = MockSiteRepository(buildings: mockBuildings);
  final mockAuth = MockAuthRepository();
  MockAuthRepository.seedManagerSession();
  final mockDues = MockDuesRepository();
  final mockProfile = MockProfileRepository();
  final mockSubscription = MockSubscriptionRepository();
  final mockTickets = MockTicketRepository();
  final mockDekont = MockDekontRepository();
  final mockExpenses = MockExpenseDataSource()..seedPreview();
  final mockNotifications = MockNotificationDataSource()..seedPreview();

  runApp(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuth),
          firebasePhoneAuthDataSourceProvider.overrideWithValue(
            MockFirebasePhoneAuthDataSource(),
          ),
          buildingRepositoryProvider.overrideWithValue(mockBuildings),
          apartmentRepositoryProvider.overrideWithValue(mockApartments),
          siteRepositoryProvider.overrideWithValue(mockSites),
          duesRepositoryProvider.overrideWithValue(mockDues),
          profileRepositoryProvider.overrideWithValue(mockProfile),
          subscriptionRepositoryProvider.overrideWithValue(mockSubscription),
          ticketRepositoryProvider.overrideWithValue(mockTickets),
          dekontRepositoryProvider.overrideWithValue(mockDekont),
          expenseDataSourceProvider.overrideWithValue(mockExpenses),
          notificationRemoteDataSourceProvider.overrideWithValue(
            mockNotifications,
          ),
        ],
        child: const _DevBanner(child: _DevApp()),
      ),
    ),
  );
}

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
      debugPrint('[DEV] Uncaught: $error\n$stack');
    }
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return FriendlyErrorScreen(details: details);
  };
}

Future<void> _initAppInfo() async {
  final packageInfo = await PackageInfo.fromPlatform();
  AppConstants.appVersion = packageInfo.version;
}

Future<void> _initLocale() async {
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

class _DevApp extends ConsumerWidget {
  const _DevApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(inviteDeepLinkProvider);
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: AppConstants.devAppName,
      theme: AppTheme.lightTheme(),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: TranslationProvider.of(context).flutterLocale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocaleUtils.supportedLocales,
      builder: (context, child) {
        return ToastOverlay(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

/// Ekranın sağ üstüne küçük "DEV" rozeti — production build'den ayırt için.
/// [kScreenshotMode] açıkken rozet render edilmez.
class _DevBanner extends StatelessWidget {
  final Widget child;
  const _DevBanner({required this.child});

  @override
  Widget build(BuildContext context) {
    if (kScreenshotMode) return child;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          child,
          const Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(child: _DevTag()),
          ),
        ],
      ),
    );
  }
}

class _DevTag extends StatelessWidget {
  const _DevTag();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 4, right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.deepOrange,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'DEV',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
