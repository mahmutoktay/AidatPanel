import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/theme_mode_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../features/auth/domain/entities/user_entity.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/profile/presentation/providers/profile_notifier.dart';
import '../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../core/router/app_router.dart';
import '../../../features/profile/presentation/widgets/change_password_bottom_sheet.dart';
import '../../../l10n/strings.g.dart';
import '../profile_avatar.dart';
import '../profile_avatar_actions.dart';
import '../settings/settings_sheet_actions.dart';
import '../settings/settings_ui_widgets.dart';

/// Sol üst profil avatarından açılan kayan panel (drawer).
class ProfileDrawer extends ConsumerStatefulWidget {
  final UserRole role;

  const ProfileDrawer({super.key, required this.role});

  @override
  ConsumerState<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends ConsumerState<ProfileDrawer> {
  bool _settingsExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileNotifierProvider.notifier).loadProfile();
    });
  }

  void _closeAnd(VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }

  /// Drawer kapandıktan sonra sheet/bottom sheet açar (geçersiz context önlenir).
  void _closeDrawerThen(void Function(BuildContext ctx) open) {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        open(ctx);
      }
    });
  }

  String get _profilePath => widget.role == UserRole.manager
      ? '/manager-dashboard/profile'
      : '/resident-dashboard/profile';

  String get _sessionsPath => widget.role == UserRole.manager
      ? '/manager-dashboard/profile/sessions'
      : '/resident-dashboard/profile/sessions';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final currentLocale = ref.watch(localeProvider);
    final currentTheme = ref.watch(themeModeProvider);
    final t = context.t;

    return Drawer(
      backgroundColor: AppColors.dashboardBackground,
      width: MediaQuery.sizeOf(context).width * 0.86,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (user != null) ...[
              _DrawerProfileHeader(
                user: user,
                onAvatarTap: () => handleProfileAvatarTap(context, ref),
                onProfileTap: () =>
                    _closeAnd(() => context.push(_profilePath)),
              ),
              const Divider(height: 1),
            ],
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.spacingS,
                ),
                children: [
                  if (user != null) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.spacingM,
                        AppSizes.spacingS,
                        AppSizes.spacingM,
                        AppSizes.spacingXS,
                      ),
                      child: Text(
                        t.common.profileDrawerAccount,
                        style: ProfileSettingsUi.handle.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SettingsSurfaceCard(
                      children: [
                        SettingsTile(
                          icon: Icons.person_outline,
                          title: t.common.menuMyProfile,
                          subtitle: t.common.editProfile,
                          onTap: () =>
                              _closeAnd(() => context.push(_profilePath)),
                        ),
                        SettingsTile(
                          icon: Icons.devices_outlined,
                          title: t.common.menuActiveSessions,
                          onTap: () =>
                              _closeAnd(() => context.push(_sessionsPath)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                  ],
                  if (widget.role == UserRole.manager) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.spacingM,
                        AppSizes.spacingS,
                        AppSizes.spacingM,
                        AppSizes.spacingXS,
                      ),
                      child: Text(
                        t.common.profileDrawerQuickLinks,
                        style: ProfileSettingsUi.handle.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SettingsSurfaceCard(
                      children: [
                        SettingsTile(
                          icon: Icons.account_balance_wallet_outlined,
                          title: t.features.buildings.collection.savedIbansTitle,
                          onTap: () => _closeAnd(
                            () => context.push('/manager-dashboard/saved-ibans'),
                          ),
                        ),
                        SettingsTile(
                          icon: Icons.card_membership_outlined,
                          title: t.features.subscription.title,
                          onTap: () => _closeAnd(
                            () => context.push('/manager-dashboard/subscription'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                  ],
                  SettingsSurfaceCard(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(
                            () => _settingsExpanded = !_settingsExpanded,
                          ),
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
                                    Icons.settings_outlined,
                                    size: ProfileSettingsUi.iconSize,
                                    color: ProfileSettingsUi.ink,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      t.common.settings,
                                      style: ProfileSettingsUi.rowTitle,
                                    ),
                                  ),
                                  AnimatedRotation(
                                    turns: _settingsExpanded ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    child: Icon(
                                      Icons.expand_more,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 200),
                        crossFadeState: _settingsExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: const SizedBox.shrink(),
                        secondChild: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Divider(height: 1),
                            SettingsTile(
                              icon: Icons.lock_outline,
                              title: t.common.changePassword,
                              onTap: () => _closeDrawerThen(
                                ChangePasswordBottomSheet.show,
                              ),
                            ),
                            SettingsTile(
                              icon: Icons.language_outlined,
                              title: t.common.language,
                              trailing: currentLocale == AppLocale.tr
                                  ? 'Türkçe'
                                  : 'English',
                              onTap: () => _closeDrawerThen(
                                (ctx) => showLanguageSheet(ctx, ref),
                              ),
                            ),
                            SettingsTile(
                              icon: Icons.dark_mode_outlined,
                              title: t.common.theme,
                              trailing: themePreferenceLabel(
                                context,
                                currentTheme,
                              ),
                              onTap: () => _closeDrawerThen(
                                (ctx) => showThemeSheet(ctx, ref),
                              ),
                            ),
                            SettingsTile(
                              icon: Icons.notifications_outlined,
                              title: t.common.notifications,
                              onTap: () => _closeAnd(
                                () => context.push('/notifications'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacingM),
              child: SettingsSurfaceCard(
                children: const [LogoutSettingsTile()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerProfileHeader extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onAvatarTap;
  final VoidCallback onProfileTap;

  const _DrawerProfileHeader({
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
        ? formatProfilePhone(user.phone!)
        : t.features.profile.notProvided;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacingM,
        AppSizes.spacingM,
        AppSizes.spacingM,
        AppSizes.spacingS,
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
                borderRadius:
                    BorderRadius.circular(ProfileSettingsUi.radiusMd),
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
                      const SizedBox(height: 4),
                      Text(
                        user.role == UserRole.manager
                            ? t.common.manager
                            : t.common.resident,
                        style: ProfileSettingsUi.handle.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: ProfileSettingsUi.handle.copyWith(
                          fontStyle:
                              (user.email == null || user.email!.isEmpty)
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
                          fontStyle:
                              (user.phone == null || user.phone!.isEmpty)
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
                padding: const EdgeInsets.all(8),
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
