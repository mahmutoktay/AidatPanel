import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_back_navigation.dart';
import '../../core/providers/theme_mode_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../theme/dashboard_screen_style.dart';
import 'app_back_button.dart';
import 'notification_icon_button.dart';

/// Dashboard dışı push ekranları için ortak scaffold (flat AppBar + gri arka plan).
class DashboardSecondaryScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool showNotificationAction;
  final VoidCallback? onBack;
  final String? fallbackRoute;
  final VoidCallback? onFallback;
  final PreferredSizeWidget? bottom;
  final bool canPop;
  final bool useMinimalBackButton;
  final Widget? leading;
  final PopInvokedWithResultCallback? onPopInvokedWithResult;

  const DashboardSecondaryScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.showNotificationAction = false,
    this.onBack,
    this.fallbackRoute,
    this.onFallback,
    this.bottom,
    this.canPop = true,
    this.useMinimalBackButton = false,
    this.leading,
    this.onPopInvokedWithResult,
  });

  bool get _handlesSystemBack => fallbackRoute != null || onFallback != null;

  VoidCallback? _resolveBackHandler(BuildContext context) {
    if (onBack != null) return onBack;
    if (!_handlesSystemBack) return null;
    return () {
      if (!AppBackNavigation.handleSecondaryScreenBack(
        context,
        fallbackPath: fallbackRoute,
      )) {
        onFallback?.call();
      }
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tema değişiminde push ekranlarının da anında güncellenmesi için
    ref.watch(themeModeProvider);
    final appBarActions = <Widget>[
      ...?actions,
      if (showNotificationAction) const NotificationIconButton(),
    ];
    final backHandler = _resolveBackHandler(context);

    Widget scaffold = Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading:
            leading ??
            (useMinimalBackButton
                ? Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: AppBackButton(onPressed: backHandler),
                  )
                : AppBackButton(onPressed: backHandler)),
        title: Text(title, style: ProfileSettingsUi.title),
        actions: appBarActions.isEmpty ? null : appBarActions,
        bottom: bottom,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
    );

    final needsPopScope =
        !canPop ||
        (_handlesSystemBack && backHandler != null) ||
        onPopInvokedWithResult != null;
    if (needsPopScope) {
      scaffold = PopScope(
        canPop: canPop,
        onPopInvokedWithResult: onPopInvokedWithResult,
        child: scaffold,
      );
    }

    if (_handlesSystemBack && backHandler != null) {
      scaffold = BackButtonListener(
        onBackButtonPressed: () async {
          backHandler();
          return true;
        },
        child: scaffold,
      );
    }

    return scaffold;
  }
}

/// Liste ekranları için üst filtre alanı + genişletilmiş liste gövdesi.
class DashboardListScreenBody extends StatelessWidget {
  final Widget? header;
  final Widget list;

  const DashboardListScreenBody({super.key, this.header, required this.list});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.dashboardScreenPaddingHorizontal,
              AppSizes.spacingM,
              AppSizes.dashboardScreenPaddingHorizontal,
              0,
            ),
            child: header!,
          ),
        Expanded(child: list),
      ],
    );
  }
}

/// Beyaz kart sarmalayıcı — liste öğeleri ve bölümler için.
class DashboardSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const DashboardSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      decoration: DashboardScreenStyle.whiteCard(),
      padding: padding ?? const EdgeInsets.all(AppSizes.spacingM),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
        child: content,
      ),
    );
  }
}

/// Bölüm başlığı (18sp w800).
class DashboardSectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const DashboardSectionTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.body1.copyWith(
              color: AppColors.inkDark,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSizes.spacingS),
          trailing!,
        ],
      ],
    );
  }
}
