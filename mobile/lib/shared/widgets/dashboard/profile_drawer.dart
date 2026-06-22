import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_brand_colors.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../features/auth/domain/entities/user_entity.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/profile/presentation/providers/profile_notifier.dart';
import '../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../l10n/strings.g.dart';
import '../profile_avatar.dart';
import '../profile_avatar_actions.dart';
import '../settings/settings_ui_widgets.dart';

/// Sol üst person ikonundan açılan profil paneli — fotoğraf ve hesap bilgileri.
class ProfileDrawer extends ConsumerStatefulWidget {
  final UserRole role;

  const ProfileDrawer({super.key, required this.role});

  @override
  ConsumerState<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends ConsumerState<ProfileDrawer> {
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
                  ],
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
    final isDark = AppColors.isDark;
    final email = (user.email != null && user.email!.isNotEmpty)
        ? user.email!
        : t.features.profile.notProvided;
    final phone = (user.phone != null && user.phone!.isNotEmpty)
        ? formatProfilePhone(user.phone!)
        : t.features.profile.notProvided;
    final roleLabel = user.role == UserRole.manager
        ? t.common.manager
        : t.common.resident;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppBrandColors.panelNavy.withValues(alpha: 0.85),
                  const Color(0xFF1A2840),
                  AppBrandColors.aidatOrange.withValues(alpha: 0.35),
                ]
              : [
                  AppBrandColors.panelNavy,
                  const Color(0xFF003D8F),
                  AppBrandColors.aidatOrange.withValues(alpha: 0.9),
                ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.spacingM,
          AppSizes.spacingL,
          AppSizes.spacingM,
          AppSizes.spacingL,
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ProfileAvatar(
                    size: ProfileSettingsUi.avatarSizeLarge,
                    userName: user.name,
                    onTap: onAvatarTap,
                  ),
                ),
                Material(
                  color: AppBrandColors.aidatOrange,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onAvatarTap,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              user.name,
              style: ProfileSettingsUi.name.copyWith(
                fontSize: 22,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(ProfileSettingsUi.radiusPill),
              ),
              child: Text(
                roleLabel,
                style: ProfileSettingsUi.handle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            _HeaderInfoRow(
              icon: Icons.email_outlined,
              text: email,
              italic: user.email == null || user.email!.isEmpty,
            ),
            const SizedBox(height: 6),
            _HeaderInfoRow(
              icon: Icons.phone_outlined,
              text: phone,
              italic: user.phone == null || user.phone!.isEmpty,
            ),
            const SizedBox(height: AppSizes.spacingM),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onProfileTap,
                icon: const Icon(Icons.edit_outlined, size: 20),
                label: Text(t.common.editProfile),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppBrandColors.panelNavy,
                  minimumSize: const Size(
                    double.infinity,
                    AppSizes.buttonHeightSecondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool italic;

  const _HeaderInfoRow({
    required this.icon,
    required this.text,
    this.italic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.85)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: ProfileSettingsUi.handle.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 14,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
