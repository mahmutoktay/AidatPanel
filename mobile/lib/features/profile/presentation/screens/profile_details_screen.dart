import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/profile_avatar.dart';
import '../../../../shared/widgets/profile_avatar_actions.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../theme/profile_settings_ui.dart';
import '../widgets/delete_account_dialog.dart';

/// Ayarlar → Profil bilgileri. FAZ 4'te düzenleme açılacak.
class ProfileDetailsScreen extends ConsumerWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final t = context.t;

    if (user == null) {
      return Scaffold(
        backgroundColor: ProfileSettingsUi.background,
        appBar: _buildAppBar(context, t.features.profile.title),
        body: Center(
          child: Text(
            t.common.unexpectedError,
            style: ProfileSettingsUi.handle,
          ),
        ),
      );
    }

    final roleLabel = user.role == UserRole.manager
        ? t.common.manager
        : t.common.resident;
    final languageLabel =
        user.language == 'en' ? 'English' : t.common.turkish;
    final notProvided = t.features.profile.notProvided;
    final hasEmail = user.email.isNotEmpty;
    final hasPhone = user.phone != null && user.phone!.isNotEmpty;

    return Scaffold(
      backgroundColor: ProfileSettingsUi.background,
      appBar: _buildAppBar(context, t.features.profile.title),
      body: ListView(
        padding: ProfileSettingsUi.screenPadding,
        children: [
          _ProfileHero(
            user: user,
            roleLabel: roleLabel,
            onAvatarTap: () => handleProfileAvatarTap(context, ref),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () => ref
                  .read(toastProvider.notifier)
                  .show(t.features.profile.editHint, type: ToastType.info),
              style: ProfileSettingsUi.primaryButton,
              child: Text(t.common.editProfile),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: ProfileSettingsUi.line),
          const SizedBox(height: 20),
          _FieldBox(
            label: t.features.profile.fullName,
            value: user.name,
          ),
          const SizedBox(height: 12),
          _FieldBox(
            label: t.features.profile.email,
            value: hasEmail ? user.email : notProvided,
            isEmpty: !hasEmail,
          ),
          const SizedBox(height: 12),
          _FieldBox(
            label: t.features.profile.phone,
            value: hasPhone ? user.phone! : notProvided,
            isEmpty: !hasPhone,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FieldBox(
                  label: t.features.profile.role,
                  value: roleLabel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FieldBox(
                  label: t.features.profile.languagePref,
                  value: languageLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => DeleteAccountDialog.show(context),
              style: ProfileSettingsUi.dangerOutlinedButton,
              child: Text(t.common.deleteAccount),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: ProfileSettingsUi.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: ProfileSettingsUi.ink),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(title, style: ProfileSettingsUi.title),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final UserEntity user;
  final String roleLabel;
  final VoidCallback onAvatarTap;

  const _ProfileHero({
    required this.user,
    required this.roleLabel,
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
    return roleLabel;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileAvatar(
          size: ProfileSettingsUi.avatarSizeLarge,
          userName: user.name,
          onTap: onAvatarTap,
        ),
        const SizedBox(height: 14),
        Text(
          user.name,
          style: ProfileSettingsUi.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          _handle(),
          style: ProfileSettingsUi.handle,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _FieldBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isEmpty;

  const _FieldBox({
    required this.label,
    required this.value,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ProfileSettingsUi.background,
        borderRadius: BorderRadius.circular(ProfileSettingsUi.radiusLg),
        border: ProfileSettingsUi.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ProfileSettingsUi.fieldLabel),
          const SizedBox(height: 6),
          Text(
            value,
            style: ProfileSettingsUi.fieldValue.copyWith(
              color: isEmpty ? ProfileSettingsUi.muted : ProfileSettingsUi.ink,
              fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
              fontWeight: isEmpty ? FontWeight.w500 : FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
