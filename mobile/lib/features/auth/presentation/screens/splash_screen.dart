import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/app_back_navigation.dart';
import '../../../../core/navigation/auth_back_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/widgets/auth_screen_shell.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../dekont/presentation/providers/share_intent_provider.dart';
import '../../presentation/widgets/auth_brand_mark.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../domain/entities/user_entity.dart' show UserRole;

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Branding için minimum görünme süresi.
  // Oturum kurtarma daha hızlı bitse bile splash bu süreden önce kaybolmaz.
  static const Duration _minSplashDuration = Duration(milliseconds: 800);

  // Refresh token endpoint'i veya keychain çağrısı çok uzun sürerse (uçak
  // modu, sunucu down, yavaş ağ) bu süre sonunda kullanıcıya "Tekrar dene"
  // butonu gösterilir. Dio default timeout'larından biraz daha uzun.
  static const Duration _bootstrapTimeout = Duration(seconds: 12);

  // Bootstrap başarısız olduğunda gösterilecek hata bayrağı; null ise
  // normal splash görünür, doluysa retry UI'ı çıkar.
  bool _hasBootError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    // Splash yalnızca yeni process (cold start) veya çıkış sonrası go('/') ile
    // girilir. Sekme / alt navigasyon sadece process yaşarken bellekte tutulur;
    // arka plandan tamamen kapatılınca veya RAM öldürünce temiz başlangıç.
    _resetNavigationForFreshEntry();
    if (mounted) {
      setState(() => _hasBootError = false);
    }

    final restoreFuture = ref.read(authStateProvider.notifier).restoreSession();
    final minDelayFuture = Future<void>.delayed(_minSplashDuration);

    // restoreSession bitince yönlendir; pre-warm'ı dashboard mount olduktan
    // sonra ConsumerStatefulWidget'in initState'i kendisi tetikler. Splash
    // sırasında pre-warm denemesi UI thread'i bloklayıp ANR'a yol açıyordu.
    try {
      await Future.wait<void>([
        restoreFuture,
        minDelayFuture,
      ]).timeout(_bootstrapTimeout);
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _hasBootError = true);
      return;
    } catch (_) {
      // restoreSession kendi içinde hata yutuyor; buraya beklenmedik bir
      // şey düşerse de retry UI göster.
      if (!mounted) return;
      setState(() => _hasBootError = true);
      return;
    }

    if (!mounted) return;
    _navigateBasedOnAuth();
  }

  void _resetNavigationForFreshEntry() {
    ref.read(managerTabIndexProvider.notifier).reset();
    ref.read(residentTabIndexProvider.notifier).reset();
  }

  /// Bootstrap timeout veya beklenmedik bir hata olduğunda gösterilen
  /// alt bölüm. Kullanıcı yine splash'ta kalır; tekrar deneyene kadar
  /// uygulamanın derinine yönlendirilmez.
  Widget _buildRetrySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.dashboardScreenPaddingHorizontal,
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_outlined, color: AppColors.error, size: 32),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            context.t.features.auth.splashConnectionError,
            textAlign: TextAlign.center,
            style: AppTypography.body1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.spacingXS),
          Text(
            context.t.features.auth.splashConnectionHint,
            textAlign: TextAlign.center,
            style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.spacingL),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: AppSizes.buttonHeightSecondary,
                  child: OutlinedButton(
                    onPressed: () {
                      if (!mounted) return;
                      context.go('/login');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.brand,
                      side: BorderSide(color: AppColors.brand, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.buttonRadius),
                      ),
                    ),
                    child: Text(
                      context.t.features.auth.skipToLogin,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.brand,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: SizedBox(
                  height: AppSizes.buttonHeightSecondary,
                  child: FilledButton.icon(
                    onPressed: _bootstrap,
                    icon: const Icon(Icons.refresh, size: 20),
                    label: Text(
                      context.t.features.buildings.tekrarDene,
                      style: AppTypography.body1.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateBasedOnAuth() {
    final authState = ref.read(authStateProvider);
    if (authState.isAuthenticated && authState.user != null) {
      // ── Share Intent: Cold start'ta bekleyen dosya var mı? ──
      // ShareIntentNotifier cold start'ta dosyayı sadece state'e yazar,
      // navigate ETMEZ. Yönlendirme sorumluluğu burada — tek noktada.
      // Bu sayede go() çağrısı push()'u ezmez (race condition yok).
      final pendingFile = ref.read(pendingDekontFileProvider);
      final isResident = authState.user!.role == UserRole.resident;

      if (pendingFile != null && isResident) {
        debugPrint('[splash] Bekleyen share intent dosyası var. '
            'Doğrudan dekont sayfasına yönlendiriliyor...');
        context.go('/resident-dashboard/payment');
      } else if (authState.user!.role == UserRole.manager) {
        context.go('/manager-dashboard');
      } else {
        context.go('/resident-dashboard');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackHandler(
      exitHintMessage: context.t.common.pressBackAgainToExit,
      onExitHint: (message) => ref
          .read(toastProvider.notifier)
          .show(
            message,
            type: ToastType.info,
            duration: AppBackNavigation.exitGracePeriod,
          ),
      child: AuthScreenShell(
        centerBody: true,
        wrapInCard: false,
        cardPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingXL,
          vertical: AppSizes.spacingXL,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthBrandMark(
                size: AuthBrandMarkSize.hero,
                showSubtitle: true,
                subtitle: context.t.features.auth.appSubtitle,
              ),
              const SizedBox(height: AppSizes.spacingXL),
              if (_hasBootError)
                _buildRetrySection(context)
              else
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.inkDark,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
