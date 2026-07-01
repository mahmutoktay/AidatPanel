import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../features/auth/presentation/widgets/auth_brand_header.dart';
import '../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../theme/dashboard_screen_style.dart';

/// Auth akışı ekranları için ortak scaffold (dashboard arka plan + beyaz kart form).
class AuthScreenShell extends StatelessWidget {
  final Widget child;
  final bool showBrandHeader;
  final AuthBrandHeaderLayout brandHeaderLayout;
  final Widget? leading;
  final Widget? bottomNavigationBar;
  final bool centerBody;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? cardPadding;
  /// false ise form doğrudan gri arka plan üzerinde (login gibi).
  final bool wrapInCard;
  /// false ise içerik kaydırılmaz; [Expanded] ile tam yükseklik kullanılır.
  final bool scrollable;

  const AuthScreenShell({
    super.key,
    required this.child,
    this.showBrandHeader = false,
    this.brandHeaderLayout = AuthBrandHeaderLayout.vertical,
    this.leading,
    this.bottomNavigationBar,
    this.centerBody = false,
    this.padding,
    this.cardPadding,
    this.wrapInCard = true,
    this.scrollable = true,
  });

  /// Alt sabit birincil CTA — [ProfileSettingsUi.primaryButton] stili.
  static Widget primaryBottomBar({
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.dashboardScreenPaddingHorizontal,
          AppSizes.spacingS,
          AppSizes.dashboardScreenPaddingHorizontal,
          AppSizes.spacingM,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ProfileSettingsUi.primaryButton,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scrollPadding = padding ?? AppSizes.screenBodyScrollPadding;
    final formPadding = cardPadding ?? const EdgeInsets.all(AppSizes.spacingM);

    final bodyContent = wrapInCard
        ? Container(
            width: double.infinity,
            decoration: DashboardScreenStyle.whiteCard(),
            padding: formPadding,
            child: child,
          )
        : child;

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: SafeArea(
        bottom: bottomNavigationBar == null,
        child: centerBody
            ? Center(
                child: Padding(
                  padding: scrollPadding,
                  child: bodyContent,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (leading != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: leading,
                    ),
                  if (showBrandHeader)
                    AuthBrandHeader(layout: brandHeaderLayout),
                  Expanded(
                    child: scrollable
                        ? SingleChildScrollView(
                            padding: scrollPadding,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.manual,
                            child: bodyContent,
                          )
                        : Padding(
                            padding: scrollPadding,
                            child: bodyContent,
                          ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
