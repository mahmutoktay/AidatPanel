import 'package:flutter/foundation.dart';
import '../widgets/action_chevron.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/theme_mode_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/profile/presentation/providers/profile_notifier.dart';
import '../../features/profile/presentation/widgets/change_password_bottom_sheet.dart';
import '../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../l10n/strings.g.dart';
import 'premium_bottom_sheet.dart';
import 'profile_avatar.dart';
import 'toast_overlay.dart';

class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({super.key});

  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<SettingsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileNotifierProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final currentLocale = ref.watch(localeProvider);
    final currentTheme = ref.watch(themeModeProvider);

    return ColoredBox(
      color: AppColors.dashboardBackground,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSizes.screenBodyScrollPadding.copyWith(
          top: AppSizes.spacingS,
          bottom: AppSizes.spacingXL,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (user != null) ...[
              _SettingsProfileHeader(
                user: user,
                onAvatarTap: () {},
                onProfileTap: () {
                  final path = user.role == UserRole.manager
                      ? '/manager-dashboard/profile'
                      : '/resident-dashboard/profile';
                  context.push(path);
                },
              ),
              const SizedBox(height: AppSizes.spacingM),
            ],
            _SettingsSectionHeader(title: context.t.common.account),
            const SizedBox(height: AppSizes.spacingS),
            _SettingsSurfaceCard(
              children: [
                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: context.t.common.changePassword,
                  onTap: () => ChangePasswordBottomSheet.show(context),
                ),
                if (user?.role == UserRole.manager) ...[
                  _SettingsTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title:
                        context.t.features.buildings.collection.savedIbansTitle,
                    onTap: () => context.push('/manager-dashboard/saved-ibans'),
                  ),
                  _SettingsTile(
                    icon: Icons.card_membership_outlined,
                    title: context.t.features.subscription.title,
                    onTap: () =>
                        context.push('/manager-dashboard/subscription'),
                  ),
                ],
                _SettingsTile(
                  icon: Icons.language_outlined,
                  title: context.t.common.language,
                  trailing: currentLocale == AppLocale.tr
                      ? 'Türkçe'
                      : 'English',
                  onTap: () => _showLanguageSheet(context),
                ),
                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: context.t.common.theme,
                  trailing: _themePreferenceLabel(context, currentTheme),
                  onTap: () => _showThemeSheet(context),
                ),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: context.t.common.notifications,
                  onTap: () => context.push('/notifications'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingM),
            _SettingsSectionHeader(title: context.t.common.helpSupport),
            const SizedBox(height: AppSizes.spacingS),
            _SettingsSurfaceCard(
              children: [
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: context.t.common.privacyPolicy,
                  onTap: () => context.push('/legal/privacy'),
                ),
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  title: context.t.common.kvkk,
                  onTap: () => context.push('/legal/kvkk'),
                ),
                _SettingsTile(
                  icon: Icons.help_outline,
                  title: context.t.common.helpSupport,
                  onTap: () => context.push('/legal/help'),
                ),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: context.t.common.about,
                  trailing: 'v${AppConstants.appVersion}',
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingM),
            _SettingsSurfaceCard(children: [_LogoutTile()]),
            if (kDebugMode) ...[
              const SizedBox(height: AppSizes.spacingM),
              _TokenTestButton(),
            ],
          ],
        ),
      ),
    );
  }

  String _themePreferenceLabel(BuildContext context, AppThemePreference pref) {
    final t = context.t.common;
    return switch (pref) {
      AppThemePreference.light => t.themeLight,
      AppThemePreference.dark => t.themeDark,
      AppThemePreference.system => t.themeSystem,
    };
  }

  void _showThemeSheet(BuildContext context) {
    final currentTheme = ref.read(themeModeProvider);
    final t = context.t;
    PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (sheetContext) => PremiumBottomSheetScaffold(
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
              onTap: () async {
                await changeThemeMode(ref, AppThemePreference.light);
                if (!sheetContext.mounted) return;
                Navigator.pop(sheetContext);
              },
            ),
            PremiumActionSheetTile(
              icon: Icons.dark_mode_rounded,
              label: t.common.themeDark,
              subtitle: 'Dark',
              trailing: currentTheme == AppThemePreference.dark
                  ? Icon(Icons.check_rounded, color: AppColors.inkDark)
                  : null,
              onTap: () async {
                await changeThemeMode(ref, AppThemePreference.dark);
                if (!sheetContext.mounted) return;
                Navigator.pop(sheetContext);
              },
            ),
            PremiumActionSheetTile(
              icon: Icons.brightness_auto_rounded,
              label: t.common.themeSystem,
              subtitle: 'System',
              trailing: currentTheme == AppThemePreference.system
                  ? Icon(Icons.check_rounded, color: AppColors.inkDark)
                  : null,
              onTap: () async {
                await changeThemeMode(ref, AppThemePreference.system);
                if (!sheetContext.mounted) return;
                Navigator.pop(sheetContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    final currentLocale = ref.read(localeProvider);
    final t = context.t;
    PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (sheetContext) => PremiumBottomSheetScaffold(
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
                  ref
                      .read(toastProvider.notifier)
                      .show(
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
                  ref
                      .read(toastProvider.notifier)
                      .show(
                        context.t.features.profile.profileUpdateFailed,
                        type: ToastType.error,
                      );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: 'v${AppConstants.appVersion}',
      applicationLegalese: context.t.common.copyright,
      children: [
        const SizedBox(height: AppSizes.spacingM),
        Text(
          context.t.common.aboutDescription,
          style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  final String title;

  const _SettingsSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.h4.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 18,
      ),
    );
  }
}

class _SettingsSurfaceCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsSurfaceCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _SettingsProfileHeader extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onAvatarTap;
  final VoidCallback onProfileTap;

  const _SettingsProfileHeader({
    required this.user,
    required this.onAvatarTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final email = (user.email != null && user.email!.isNotEmpty)
        ? user.email!
        : t.features.profile.notProvided;
    final phone = (user.phone != null && user.phone!.isNotEmpty)
        ? _formatPhone(user.phone!)
        : t.features.profile.notProvided;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.spacingXS,
        right: AppSizes.spacingM,
        top: AppSizes.spacingS,
        bottom: AppSizes.spacingS,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProfileAvatar(
            size: ProfileSettingsUi.avatarSize,
            userName: user.name,
            onTap: onAvatarTap,
          ),
          const SizedBox(width: AppSizes.spacingM),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(ProfileSettingsUi.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: ProfileSettingsUi.name.copyWith(fontSize: 20),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        email,
                        style: ProfileSettingsUi.handle.copyWith(
                          fontStyle: (user.email == null || user.email!.isEmpty)
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: ProfileSettingsUi.handle.copyWith(
                          fontStyle: (user.phone == null || user.phone!.isEmpty)
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onProfileTap,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: const ActionChevron(
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatPhone(String phone) {
  var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length > 10) {
    digits = digits.substring(digits.length - 10);
  }
  if (digits.length != 10) return phone;
  final p = digits;
  return '+90 ${p.substring(0, 3)} ${p.substring(3, 6)} '
      '${p.substring(6, 8)} ${p.substring(8, 10)}';
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;
  final bool showChevron;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.showChevron = true,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: ProfileSettingsUi.rowHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingM,
              vertical: 10,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: ProfileSettingsUi.iconSize,
                  color: iconColor ?? ProfileSettingsUi.ink,
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(title, style: ProfileSettingsUi.rowTitle)),
                if (trailing != null) ...[
                  Text(trailing!, style: ProfileSettingsUi.rowTrailing),
                  const SizedBox(width: 8),
                ],
                if (showChevron)
                  const ActionChevron(
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return _SettingsTile(
      icon: Icons.logout_rounded,
      iconColor: AppColors.error,
      title: context.t.common.logout,
      showChevron: false,
      onTap: authState.isLoading ? () {} : () => _confirmLogout(context),
    );
  }

  void _confirmLogout(BuildContext context) {
    _LogoutConfirmBottomSheet.show(context);
  }
}

class _LogoutConfirmBottomSheet extends ConsumerWidget {
  const _LogoutConfirmBottomSheet();

  static Future<void> show(BuildContext context) {
    return PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (_) => const _LogoutConfirmBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final isLoading = ref.watch(
      authStateProvider.select((state) => state.isLoading),
    );

    return PopScope(
      canPop: !isLoading,
      child: PremiumBottomSheetScaffold(
        scrollable: false,
        header: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spacingL,
            AppSizes.spacingM,
            AppSizes.spacingL,
            AppSizes.spacingS,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: ProfileSettingsUi.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.logout_rounded,
                  color: ProfileSettingsUi.danger,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.common.logout, style: ProfileSettingsUi.title),
                    const SizedBox(height: 4),
                    Text(
                      t.common.logoutConfirm,
                      style: ProfileSettingsUi.handle.copyWith(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: const SizedBox.shrink(),
        actions: PremiumSheetActions(
          primaryLabel: t.common.logout,
          primaryLoading: isLoading,
          onPrimary: isLoading
              ? null
              : () async {
                  final navigator = Navigator.of(context);
                  final goRouter = GoRouter.of(context);
                  await ref.read(authStateProvider.notifier).logout(ref);

                  final authState = ref.read(authStateProvider);
                  if (authState.error != null && authState.error!.isNotEmpty) {
                    ref
                        .read(toastProvider.notifier)
                        .show(authState.error!, type: ToastType.error);
                    return;
                  }

                  if (navigator.canPop()) {
                    navigator.pop();
                  }
                  goRouter.go('/login');
                },
          secondaryLabel: t.common.cancelBtn,
          onSecondary: isLoading ? null : () => Navigator.pop(context),
          secondaryEnabled: !isLoading,
        ),
      ),
    );
  }
}

class _TokenTestButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsSurfaceCard(
      children: [
        _SettingsTile(
          icon: Icons.timer_outlined,
          title: context.t.common.tokenExpiryTest,
          showChevron: false,
          onTap: () => _checkTokenExpiry(context, ref),
        ),
      ],
    );
  }

  Future<void> _checkTokenExpiry(BuildContext context, WidgetRef ref) async {
    final secureStorage = ref.read(secureStorageProvider);
    final isExpired = await secureStorage.isTokenExpired();
    final expiry = await secureStorage.getTokenExpiry();

    if (!context.mounted) return;

    if (isExpired) {
      ref
          .read(toastProvider.notifier)
          .show(context.t.common.tokenExpired, type: ToastType.error);
      await Future.delayed(const Duration(seconds: 2));
      if (context.mounted) {
        context.go('/login');
      }
    } else {
      final remaining = expiry?.difference(DateTime.now()) ?? Duration.zero;
      ref
          .read(toastProvider.notifier)
          .show(
            '${context.t.common.tokenActive} ${remaining.inSeconds} saniye',
            type: ToastType.success,
          );
    }
  }
}
