import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/strings.g.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../theme/profile_settings_ui.dart';

/// Profil bilgileri — diğer cihazlardan oturumu yönetme satırı.
class LogoutAllDevicesTile extends ConsumerWidget {
  const LogoutAllDevicesTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final isManager =
              ref.read(authStateProvider).user?.role == UserRole.manager;
          final path = isManager
              ? '/manager-dashboard/profile/sessions'
              : '/resident-dashboard/profile/sessions';
          context.push(path);
        },
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
