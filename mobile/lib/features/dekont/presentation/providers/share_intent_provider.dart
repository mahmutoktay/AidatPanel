import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/user_entity.dart' show UserRole;

// ---------------------------------------------------------------------------
// STATE
// ---------------------------------------------------------------------------

/// Dinleyici state'i. Kullanılmasa da servisi hayatta tutmak için var.
class ShareIntentState {
  const ShareIntentState();
}

/// Bekleyen dekont dosyasını tutan provider.
/// Cold start'ta ShareIntentNotifier dosyayı buraya yazar,
/// SplashScreen yönlendirmeden hemen önce kontrol eder.
/// Warm resume'da ShareIntentNotifier hem yazar hem navigate eder.
final pendingDekontFileProvider = StateProvider<Map<String, dynamic>?>(
  (ref) => null,
);

// ---------------------------------------------------------------------------
// NOTIFIER
// ---------------------------------------------------------------------------

/// Dışarıdan paylaşılan dosyaları (resim, PDF vb.) dinleyen servis.
///
/// MİMARİ KARAR — Cold Start vs Warm Resume:
///
/// ┌─────────────────────────────────────────────────────────────────────┐
/// │  Cold Start (getInitialMedia):                                      │
/// │  → Dosyayı oku, pendingDekontFileProvider'a yaz, NAVIGATE ETME.     │
/// │  → SplashScreen._navigateBasedOnAuth() pending dosyayı kontrol      │
/// │    eder ve go('/resident-dashboard/payment') ile yönlendirir.       │
/// │                                                                     │
/// │  Warm Resume (getMediaStream):                                      │
/// │  → Dosyayı oku, pendingDekontFileProvider'a yaz, push() ile         │
/// │    navigate et. Uygulama zaten stabil, splash akmıyor.              │
/// └─────────────────────────────────────────────────────────────────────┘
///
/// Bu ayrım, splash'ın context.go() çağrısının push'u ezmesi sorununu
/// kökten ortadan kaldırır.
class ShareIntentNotifier extends StateNotifier<ShareIntentState> {
  final Ref _ref;
  StreamSubscription? _intentDataStreamSubscription;

  ShareIntentNotifier(this._ref) : super(const ShareIntentState()) {
    _init();
  }

  void _init() {
    debugPrint('[share_intent] ShareIntentNotifier init başladı');

    // ── 1. WARM RESUME: Uygulama bellekteyken gelen intent'ler ──
    _intentDataStreamSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen(
          (List<SharedMediaFile> value) {
            debugPrint('[share_intent] Stream event: ${value.length} dosya');
            if (value.isNotEmpty) {
              _handleWarmResumeFiles(value);
            }
          },
          onError: (err) {
            debugPrint('[share_intent] stream error: $err');
          },
        );

    // ── 2. COLD START: Uygulama kapalıyken tetiklenen intent ──
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> value) {
          debugPrint('[share_intent] Initial media: ${value.length} dosya');
          if (value.isNotEmpty) {
            _handleColdStartFiles(value);
            ReceiveSharingIntent.instance.reset();
          }
        })
        .catchError((err) {
          debugPrint('[share_intent] initial error: $err');
        });
  }

  // ── COLD START: Sadece dosyayı state'e yaz, NAVIGATE ETME ──
  // SplashScreen._navigateBasedOnAuth() bu state'i kontrol edip
  // yönlendirmeyi kendi yapacak. Böylece splash'ın go() çağrısı
  // ile çakışma (race condition) ortadan kalkar.
  Future<void> _handleColdStartFiles(List<SharedMediaFile> files) async {
    debugPrint('[share_intent] Cold start: dosya işleniyor...');
    final fileData = await _readFileToMap(files);
    if (fileData == null) return;

    _ref.read(pendingDekontFileProvider.notifier).state = fileData;
    debugPrint(
      '[share_intent] Cold start: dosya pendingDekontFileProvider\'a '
      'yazıldı. Navigation SplashScreen\'e bırakıldı.',
    );
  }

  // ── WARM RESUME: Dosyayı state'e yaz VE navigate et ──
  // Uygulama zaten stabil; splash akmıyor, dashboard mount olmuş.
  Future<void> _handleWarmResumeFiles(List<SharedMediaFile> files) async {
    debugPrint('[share_intent] Warm resume: dosya işleniyor...');
    final fileData = await _readFileToMap(files);
    if (fileData == null) return;

    // 1. Dosyayı state'e yaz
    _ref.read(pendingDekontFileProvider.notifier).state = fileData;
    debugPrint('[share_intent] Warm resume: dosya state\'e yazıldı');

    // 2. Auth ve rol kontrolü
    final authState = _ref.read(authStateProvider);
    if (!authState.isAuthenticated || authState.user == null) {
      debugPrint('[share_intent] Warm resume: kullanıcı giriş yapmamış.');
      _ref.read(pendingDekontFileProvider.notifier).state = null;
      return;
    }

    if (authState.user!.role != UserRole.resident) {
      debugPrint('[share_intent] Warm resume: kullanıcı resident değil.');
      _ref.read(pendingDekontFileProvider.notifier).state = null;
      return;
    }

    // 3. Router hazır mı kontrol et
    final router = _ref.read(appRouterProvider);
    int routerRetries = 0;
    while (router.routerDelegate.navigatorKey.currentContext == null &&
        routerRetries < 30) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      routerRetries++;
    }

    if (router.routerDelegate.navigatorKey.currentContext == null) {
      debugPrint(
        '[share_intent] Warm resume: router context null, '
        'navigate edilemiyor.',
      );
      return;
    }

    // 4. Navigate — warm resume'da push güvenlidir
    router.push('/resident-dashboard/payment');
    debugPrint(
      '[share_intent] ✅ Warm resume: /resident-dashboard/payment '
      'push edildi.',
    );
  }

  // ── Ortak: Dosyayı oku ve Map olarak döndür ──
  Future<Map<String, dynamic>?> _readFileToMap(
    List<SharedMediaFile> files,
  ) async {
    if (files.isEmpty) return null;

    final file = files.first;
    final path = file.path;

    if (path.isEmpty) {
      debugPrint('[share_intent] HATA: Boş dosya path');
      return null;
    }

    try {
      debugPrint('[share_intent] Gelen dosya path: $path');

      // Path temizliği
      String cleanPath = path;
      if (cleanPath.startsWith('file://')) {
        cleanPath = cleanPath.replaceFirst('file://', '');
      }
      try {
        cleanPath = Uri.decodeFull(cleanPath);
      } catch (_) {}

      // Cache kopyası gecikebilir
      final f = File(cleanPath);
      if (!f.existsSync()) {
        debugPrint('[share_intent] Dosya henüz yok, 500ms bekleniyor...');
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Dosyayı oku
      Uint8List bytes;
      try {
        bytes = await f.readAsBytes();
      } catch (e) {
        debugPrint('[share_intent] HATA: Dosya okunamadı ($cleanPath): $e');
        return null;
      }

      if (bytes.isEmpty) {
        debugPrint('[share_intent] HATA: Dosya boş (0 byte)');
        return null;
      }

      final fileName = cleanPath.split(Platform.pathSeparator).last.isNotEmpty
          ? cleanPath.split(Platform.pathSeparator).last
          : cleanPath.split('/').last;

      debugPrint(
        '[share_intent] Dosya okundu: $fileName (${bytes.length} bytes)',
      );

      return {'fileName': fileName, 'fileBytes': bytes, 'filePath': path};
    } catch (e, st) {
      debugPrint('[share_intent] HATA: _readFileToMap exception: $e\n$st');
      return null;
    }
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }
}

/// Global provider. Uygulama açılışında watch edilmeli ki dinleyici başlasın.
final shareIntentProvider =
    StateNotifierProvider<ShareIntentNotifier, ShareIntentState>((ref) {
      return ShareIntentNotifier(ref);
    });
