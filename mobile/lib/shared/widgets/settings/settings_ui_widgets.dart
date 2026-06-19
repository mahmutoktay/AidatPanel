import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../l10n/strings.g.dart';
import '../premium_bottom_sheet.dart';
import '../toast_overlay.dart';

class SettingsSectionHeader extends StatelessWidget {
  final String title;

  const SettingsSectionHeader({super.key, required this.title});

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

class SettingsSurfaceCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsSurfaceCard({super.key, required this.children});

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

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback onTap;
  final bool showChevron;
  final Color? iconColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
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
          constraints:
              const BoxConstraints(minHeight: ProfileSettingsUi.rowHeight),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: ProfileSettingsUi.rowTitle),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: ProfileSettingsUi.handle.copyWith(
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
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

class LogoutSettingsTile extends ConsumerWidget {
  const LogoutSettingsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return SettingsTile(
      icon: Icons.logout_rounded,
      iconColor: AppColors.error,
      title: context.t.common.logout,
      showChevron: false,
      onTap: authState.isLoading ? () {} : () => LogoutConfirmSheet.show(context),
    );
  }
}

class LogoutConfirmSheet extends ConsumerWidget {
  const LogoutConfirmSheet({super.key});

  static Future<void> show(BuildContext context) {
    return PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (_) => const LogoutConfirmSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final isLoading = ref.watch(authStateProvider).isLoading;

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
                    ref.read(toastProvider.notifier).show(
                          authState.error!,
                          type: ToastType.error,
                        );
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

void showAppAboutDialog(BuildContext context) {
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

class TokenTestSettingsTile extends ConsumerWidget {
  const TokenTestSettingsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsTile(
      icon: Icons.timer_outlined,
      title: context.t.common.tokenExpiryTest,
      showChevron: false,
      onTap: () => _checkTokenExpiry(context, ref),
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
      ref.read(toastProvider.notifier).show(
            '${context.t.common.tokenActive} ${remaining.inSeconds} saniye',
            type: ToastType.success,
          );
    }
  }
}

String formatProfilePhone(String phone) {
  var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length > 10) {
    digits = digits.substring(digits.length - 10);
  }
  if (digits.length != 10) return phone;
  final p = digits;
  return '+90 ${p.substring(0, 3)} ${p.substring(3, 6)} '
      '${p.substring(6, 8)} ${p.substring(8, 10)}';
}
