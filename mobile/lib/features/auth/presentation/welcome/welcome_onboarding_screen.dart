import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_back_navigation.dart';
import '../../../../core/navigation/auth_back_handler.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import 'welcome_illustrations.dart';
import 'welcome_onboarding_dots.dart';
import 'welcome_onboarding_page.dart';

class WelcomeOnboardingScreen extends ConsumerStatefulWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  ConsumerState<WelcomeOnboardingScreen> createState() =>
      _WelcomeOnboardingScreenState();
}

class _WelcomeOnboardingScreenState
    extends ConsumerState<WelcomeOnboardingScreen> {
  static const int _pageCount = 5;

  final PageController _pageController = PageController();
  final SecureStorage _storage = SecureStorage();
  int _index = 0;
  bool _completing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLast => _index >= _pageCount - 1;

  Future<void> _completeAndGoLogin() async {
    if (_completing) return;
    setState(() => _completing = true);
    try {
      await _storage.markOnboardingCompleted();
      if (!mounted) return;
      context.go('/login');
    } catch (_) {
      if (!mounted) return;
      setState(() => _completing = false);
      ref.read(toastProvider.notifier).show(
            context.t.features.auth.errorOccurred,
            type: ToastType.error,
          );
    }
  }

  void _onNext() {
    if (_isLast) {
      _completeAndGoLogin();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tw = context.t.features.welcome;
    final pages = <({WelcomeIllustrationKind kind, String title, String body})>[
      (
        kind: WelcomeIllustrationKind.greeting,
        title: tw.page1Title,
        body: tw.page1Body,
      ),
      (
        kind: WelcomeIllustrationKind.multiProperty,
        title: tw.page2Title,
        body: tw.page2Body,
      ),
      (
        kind: WelcomeIllustrationKind.dekont,
        title: tw.page3Title,
        body: tw.page3Body,
      ),
      (
        kind: WelcomeIllustrationKind.notifications,
        title: tw.page4Title,
        body: tw.page4Body,
      ),
      (
        kind: WelcomeIllustrationKind.transparency,
        title: tw.page5Title,
        body: tw.page5Body,
      ),
    ];

    return AuthBackHandler(
      exitHintMessage: context.t.common.pressBackAgainToExit,
      onExitHint: (message) => ref.read(toastProvider.notifier).show(
            message,
            type: ToastType.info,
            duration: AppBackNavigation.exitGracePeriod,
          ),
      child: Scaffold(
        backgroundColor: AppColors.dashboardBackground,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPadding,
                  AppSizes.spacingS,
                  AppSizes.screenPadding,
                  0,
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    if (!_isLast)
                      Semantics(
                        button: true,
                        label: tw.skipSemantics,
                        child: TextButton(
                          onPressed:
                              _completing ? null : _completeAndGoLogin,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(
                              AppSizes.minTouchTarget,
                              AppSizes.minTouchTarget,
                            ),
                            foregroundColor: AppColors.textSecondary,
                            textStyle: AppTypography.body1.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: Text(tw.skip),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pageCount,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final page = pages[i];
                    return WelcomeOnboardingPage(
                      kind: page.kind,
                      title: page.title,
                      description: page.body,
                      semanticsLabel: tw.pageSemantics
                          .replaceAll('{current}', '${i + 1}')
                          .replaceAll('{total}', '$_pageCount'),
                    );
                  },
                ),
              ),
              WelcomeOnboardingDots(
                count: _pageCount,
                index: _index,
                semanticsLabel: tw.dotsSemantics
                    .replaceAll('{current}', '${_index + 1}')
                    .replaceAll('{total}', '$_pageCount'),
              ),
              const SizedBox(height: AppSizes.spacingL),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPadding,
                  0,
                  AppSizes.screenPadding,
                  AppSizes.spacingL,
                ),
                child: Semantics(
                  button: true,
                  label: _isLast ? tw.startSemantics : tw.nextSemantics,
                  child: SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeightPrimary,
                    child: ElevatedButton(
                      onPressed: _completing ? null : _onNext,
                      style: AppButtonStyles.elevatedPrimary(fullWidth: true),
                      child: _completing
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.onAction,
                              ),
                            )
                          : Text(_isLast ? tw.start : tw.next),
                    ),
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
