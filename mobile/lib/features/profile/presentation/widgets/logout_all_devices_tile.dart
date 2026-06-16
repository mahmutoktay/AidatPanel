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
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF4F2EC),
      barrierColor: const Color(0x6114120C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => const LogoutAllDevicesConfirmSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final isLoading = ref.watch(authStateProvider).isLoading;

    return PopScope(
      canPop: !isLoading,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E4DA),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDEDEC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.phonelink_erase_rounded,
                    color: Color(0xFFE15B4D),
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
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15140F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.common.logoutAllDevicesConfirm,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B6757),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF15140F),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFE7E4DA), width: 1.5),
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: Text(t.common.cancelBtn),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF15140F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: isLoading ? null : () => _confirm(context, ref),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(t.common.confirm),
                  ),
                ),
              ],
            ),
          ],
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
