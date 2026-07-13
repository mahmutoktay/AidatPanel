import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

/// Hesap kapatma onay sheet'i (KVKK soft delete).
///
/// Tasarım: ChangePasswordBottomSheet ile aynı Minimal + Premium dil.
/// Doğrulama cümlesine dokununca input'a yazılır.
class DeleteAccountSheet extends ConsumerStatefulWidget {
  const DeleteAccountSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return PremiumBottomSheetScaffold.show<bool>(
      context: context,
      builder: (_) => const DeleteAccountSheet(),
    );
  }

  @override
  ConsumerState<DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends ConsumerState<DeleteAccountSheet> {
  final _controller = TextEditingController();
  bool _deleting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _matches(String phrase) =>
      _controller.text.trim().toUpperCase() == phrase.toUpperCase();

  void _fillPhrase(String phrase) {
    _controller.text = phrase;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    setState(() {});
  }

  Future<void> _delete(String phrase) async {
    if (!_matches(phrase) || _deleting) return;
    setState(() => _deleting = true);

    final repo = ref.read(profileRepositoryProvider);
    final navigator = Navigator.of(context);
    final goRouter = GoRouter.of(context);
    final toast = ref.read(toastProvider.notifier);
    final successMsg = context.t.common.deleteAccountSuccess;

    try {
      await repo.deleteAccount();
      if (!mounted) return;
      navigator.pop(true);

      toast.show(
        successMsg,
        type: ToastType.success,
        duration: const Duration(seconds: 5),
      );

      await ref.read(authStateProvider.notifier).logout(ref, showToast: false);
      goRouter.go('/login');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      toast.show(
        userFacingError(e),
        type: ToastType.error,
        duration: const Duration(seconds: 6),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _deleting = false);
      toast.show(
        context.t.common.deleteAccountFailed,
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final phrase = t.common.deleteAccountTypePhrase;
    final canSubmit = _matches(phrase) && !_deleting;

    return PopScope(
      canPop: !_deleting,
      child: PremiumBottomSheetScaffold(
        title: t.common.deleteAccount,
        scrollable: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.common.deleteAccountTitle,
              style: ProfileSettingsUi.handle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              t.common.deleteAccountWarning,
              style: ProfileSettingsUi.handle.copyWith(
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSizes.spacingL),
            Text(
              t.common.deleteAccountTypeHint,
              style: ProfileSettingsUi.fieldLabelUppercase,
            ),
            const SizedBox(height: AppSizes.spacingS),
            _PhrasePreview(
              phrase: phrase,
              onTap: _deleting ? null : () => _fillPhrase(phrase),
            ),
            const SizedBox(height: AppSizes.spacingM),
            MinimalTextField(
              controller: _controller,
              label: t.common.deleteAccountConfirmButton,
              hint: phrase,
              icon: Icons.edit_note_rounded,
              enabled: !_deleting,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
        actions: PremiumSheetActions(
          primaryLabel: t.common.deleteAccountConfirmButton,
          onPrimary: canSubmit ? () => _delete(phrase) : null,
          primaryLoading: _deleting,
          primaryEnabled: canSubmit,
          dangerPrimary: true,
          icon: Icons.person_off_outlined,
          secondaryLabel: t.common.cancelBtn,
          onSecondary:
              _deleting ? null : () => Navigator.of(context).pop(false),
          secondaryEnabled: !_deleting,
        ),
      ),
    );
  }
}

class _PhrasePreview extends StatelessWidget {
  final String phrase;
  final VoidCallback? onTap;

  const _PhrasePreview({required this.phrase, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ProfileSettingsUi.danger.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(ProfileSettingsUi.fieldRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ProfileSettingsUi.fieldRadius),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSizes.minTouchTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    phrase,
                    style: ProfileSettingsUi.fieldValue.copyWith(
                      color: ProfileSettingsUi.danger,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.touch_app_outlined,
                  size: 20,
                  color: ProfileSettingsUi.danger,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
