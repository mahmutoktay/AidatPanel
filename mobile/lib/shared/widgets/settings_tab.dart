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
import '../../features/profile/presentation/providers/profile_notifier.dart';
import '../../features/profile/presentation/widgets/change_password_bottom_sheet.dart';
import '../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../l10n/strings.g.dart';
import 'profile_avatar.dart';
import 'profile_avatar_actions.dart';
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
                onAvatarTap: () => handleProfileAvatarTap(context, ref),
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
                  trailing:
                      currentLocale == AppLocale.tr ? 'Türkçe' : 'English',
                  onTap: () => _showLanguageSheet(context),
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
            _SettingsSurfaceCard(
              children: [
                _LogoutTile(),
              ],
            ),
            if (kDebugMode) ...[
              const SizedBox(height: AppSizes.spacingM),
              _TokenTestButton(),
            ],
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
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
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: AppColors.textSecondary,
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
          constraints: const BoxConstraints(minHeight: ProfileSettingsUi.rowHeight),
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
                  Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
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
