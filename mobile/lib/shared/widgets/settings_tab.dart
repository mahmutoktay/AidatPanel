import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/profile/presentation/widgets/change_password_bottom_sheet.dart';
import '../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../l10n/strings.g.dart';
import 'profile_avatar.dart';
import 'profile_avatar_actions.dart';
import 'toast_overlay.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final currentLocale = ref.watch(localeProvider);

    return SingleChildScrollView(
      padding: ProfileSettingsUi.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (user != null) ...[
            _ProfileHero(user: user, onAvatarTap: () => handleProfileAvatarTap(context, ref)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final path = user.role == UserRole.manager
                      ? '/manager-dashboard/profile'
                      : '/resident-dashboard/profile';
                  context.push(path);
                },
                style: ProfileSettingsUi.primaryButton,
                child: Text(context.t.features.profile.title),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, color: ProfileSettingsUi.line),
            const SizedBox(height: 8),
          ],

          _SettingsTile(
            icon: Icons.lock_outline,
            title: context.t.common.changePassword,
            onTap: () => ChangePasswordBottomSheet.show(context),
          ),
          if (user?.role == UserRole.manager) ...[
            _SettingsTile(
              icon: Icons.account_balance_wallet_outlined,
              title: context.t.features.buildings.collection.savedIbansTitle,
              onTap: () => context.push('/manager-dashboard/saved-ibans'),
            ),
            _SettingsTile(
              icon: Icons.card_membership_outlined,
              title: context.t.features.subscription.title,
              onTap: () => context.push('/manager-dashboard/subscription'),
            ),
          ],
          _SettingsTile(
            icon: Icons.language_outlined,
            title: context.t.common.language,
            trailing: currentLocale == AppLocale.tr ? 'Türkçe' : 'English',
            onTap: () => _showLanguageSheet(context, ref),
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: context.t.common.notifications,
            onTap: () => context.push('/notifications'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: ProfileSettingsUi.line),
          ),
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: ProfileSettingsUi.line),
          ),
          _LogoutTile(),

          if (kDebugMode) ...[
            const SizedBox(height: 16),
            _TokenTestButton(),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(localeProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: ProfileSettingsUi.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSizes.spacingL,
          AppSizes.spacingS,
          AppSizes.spacingL,
          AppSizes.spacingL + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BottomSheetHandle(),
            const SizedBox(height: AppSizes.spacingM),
            Text(context.t.common.language, style: ProfileSettingsUi.title),
            const SizedBox(height: AppSizes.spacingL),
            _LanguageOption(
              flag: '🇹🇷',
              title: 'Türkçe',
              subtitle: 'Turkish',
              isSelected: currentLocale == AppLocale.tr,
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
            const SizedBox(height: AppSizes.spacingS),
            _LanguageOption(
              flag: '🇬🇧',
              title: 'English',
              subtitle: 'İngilizce',
              isSelected: currentLocale == AppLocale.en,
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
            const SizedBox(height: AppSizes.spacingM),
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

class _ProfileHero extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onAvatarTap;

  const _ProfileHero({
    required this.user,
    required this.onAvatarTap,
  });

  String _handle() {
    if (user.email.isNotEmpty) {
      final at = user.email.indexOf('@');
      final name = at > 0 ? user.email.substring(0, at) : user.email;
      return '@$name';
    }
    if (user.phone != null && user.phone!.isNotEmpty) {
      return user.phone!;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final handle = _handle();
    return Column(
      children: [
        ProfileAvatar(
          size: ProfileSettingsUi.avatarSize,
          userName: user.name,
          onTap: onAvatarTap,
        ),
        const SizedBox(height: 14),
        Text(
          user.name,
          style: ProfileSettingsUi.name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (handle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            handle,
            style: ProfileSettingsUi.handle,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingM,
          vertical: AppSizes.spacingM,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? ProfileSettingsUi.fill
              : ProfileSettingsUi.background,
          borderRadius: BorderRadius.circular(ProfileSettingsUi.radiusMd),
          border: Border.all(
            color: isSelected ? ProfileSettingsUi.ink : ProfileSettingsUi.line,
            width: isSelected ? AppSizes.cardBorderWidth : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ProfileSettingsUi.rowTitle.copyWith(
                      color: isSelected
                          ? ProfileSettingsUi.ink
                          : ProfileSettingsUi.ink,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: ProfileSettingsUi.rowTrailing,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: ProfileSettingsUi.ink,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: ProfileSettingsUi.line,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;
  final bool showChevron;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ProfileSettingsUi.background,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: ProfileSettingsUi.rowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: ProfileSettingsUi.iconSize,
                  color: ProfileSettingsUi.ink,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: ProfileSettingsUi.rowTitle,
                  ),
                ),
                if (trailing != null) ...[
                  Text(trailing!, style: ProfileSettingsUi.rowTrailing),
                  const SizedBox(width: 8),
                ],
                if (showChevron)
                  const Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: ProfileSettingsUi.muted,
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
      title: context.t.common.logout,
      showChevron: false,
      onTap: authState.isLoading
          ? () {}
          : () => _confirmLogout(context, ref),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: ProfileSettingsUi.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          20 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BottomSheetHandle(),
            const SizedBox(height: 20),
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: ProfileSettingsUi.fill,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                size: 26,
                color: ProfileSettingsUi.ink,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              context.t.common.logout,
              style: ProfileSettingsUi.name.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              context.t.common.logoutConfirm,
              style: ProfileSettingsUi.handle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: ProfileSettingsUi.buttonHeight,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ProfileSettingsUi.ink,
                        side: const BorderSide(
                          color: ProfileSettingsUi.line,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ProfileSettingsUi.radiusMd,
                          ),
                        ),
                      ),
                      child: Text(
                        context.t.common.cancelBtn,
                        style: ProfileSettingsUi.rowTitle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: ProfileSettingsUi.buttonHeight,
                    child: ElevatedButton(
                      style: ProfileSettingsUi.primaryButton,
                      onPressed: () async {
                        Navigator.pop(sheetContext);
                        await ref.read(authStateProvider.notifier).logout(ref);
                        if (!context.mounted) return;
                        ref.read(toastProvider.notifier).show(
                              context.t.common.logoutSuccess,
                              type: ToastType.success,
                              duration: const Duration(seconds: 4),
                            );
                        context.go('/');
                      },
                      child: Text(
                        context.t.common.logout,
                        style: ProfileSettingsUi.buttonLabel,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TokenTestButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () => _checkTokenExpiry(context, ref),
      icon: const Icon(Icons.timer_outlined, size: 18),
      label: Text(
        context.t.common.tokenExpiryTest,
        style: ProfileSettingsUi.rowTitle,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: ProfileSettingsUi.ink,
        side: const BorderSide(color: ProfileSettingsUi.line),
        minimumSize: const Size(double.infinity, ProfileSettingsUi.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ProfileSettingsUi.radiusMd),
        ),
      ),
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
