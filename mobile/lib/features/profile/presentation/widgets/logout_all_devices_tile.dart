import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const LogoutAllDevicesConfirmSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final isLoading = ref.watch(authStateProvider).isLoading;

    return Container(
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
          const _SheetHandle(),
          const SizedBox(height: 20),
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: ProfileSettingsUi.fill,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phonelink_erase_rounded,
              size: 26,
              color: ProfileSettingsUi.ink,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            t.common.logoutAllDevices,
            style: ProfileSettingsUi.name.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            t.common.logoutAllDevicesConfirm,
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
                    onPressed: isLoading ? null : () => Navigator.pop(context),
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
                      t.common.cancelBtn,
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
                    onPressed: isLoading ? null : () => _confirm(context, ref),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            t.common.confirm,
                            style: ProfileSettingsUi.buttonLabel,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
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

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

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
