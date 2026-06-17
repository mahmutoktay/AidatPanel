import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_sizes.dart';
import '../theme/profile_settings_ui.dart';

/// Profil bilgileri — diğer cihazlardan oturumu kapatma satırı.
class LogoutAllDevicesTile extends ConsumerWidget {
  const LogoutAllDevicesTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final t = context.t;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: authState.isLoading
            ? null
            : () => LogoutAllDevicesConfirmSheet.show(context),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: ProfileSettingsUi.rowHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.phonelink_erase_rounded,
                  size: ProfileSettingsUi.iconSize,
                  color: ProfileSettingsUi.ink,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    t.common.logoutAllDevices,
                    style: ProfileSettingsUi.rowTitle,
                  ),
                ),
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

/// Diğer cihazlardan çıkış onay sheet'i.
class LogoutAllDevicesConfirmSheet extends ConsumerWidget {
  const LogoutAllDevicesConfirmSheet({super.key});

  static Future<void> show(BuildContext context) {
    return PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (_) => const LogoutAllDevicesConfirmSheet(),
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
                  Icons.phonelink_erase_rounded,
                  color: ProfileSettingsUi.danger,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.common.logoutAllDevices,
                      style: ProfileSettingsUi.title,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.common.logoutAllDevicesConfirm,
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
          primaryLabel: t.common.confirm,
          primaryLoading: isLoading,
          onPrimary: isLoading ? null : () => _confirm(context, ref),
          secondaryLabel: t.common.cancelBtn,
          onSecondary: isLoading ? null : () => Navigator.pop(context),
          secondaryEnabled: !isLoading,
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    if (ref.read(authStateProvider).isLoading) return;

    final t = context.t;
    await ref.read(authStateProvider.notifier).logoutAllDevices(ref);

    if (!context.mounted) return;
    Navigator.pop(context);

    final authState = ref.read(authStateProvider);
    final hasError = authState.error != null;
    ref.read(toastProvider.notifier).show(
      hasError ? authState.error! : t.common.logoutAllDevicesSuccess,
      type: hasError ? ToastType.error : ToastType.success,
      duration: const Duration(seconds: 4),
    );
  }
}
