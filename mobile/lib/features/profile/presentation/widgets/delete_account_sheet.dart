import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/profile_settings_ui.dart';

/// Hesap kapatma onay sheet'i (KVKK soft delete).
///
/// Backend `DELETE /me` davranışı:
///   - 200: Soft delete + PII maskelendi + refreshTokenVersion++
///   - 409: Yöneticide bina var → "Önce binaları sil/devret"
///
/// Tasarım: sade bottom sheet — ChangePasswordBottomSheet ile aynı dil.
/// Doğrulama cümlesi input'un üzerinde tek satır olarak gösterilir;
/// dokununca input'a yazılır (hızlı onay).
class DeleteAccountSheet extends ConsumerStatefulWidget {
  const DeleteAccountSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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

      await ref.read(authStateProvider.notifier).logout(ref);
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
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final canSubmit = _matches(phrase) && !_deleting;

    return PopScope(
      canPop: !_deleting,
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets),
        child: Container(
          decoration: const BoxDecoration(
            color: ProfileSettingsUi.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            10,
            24,
            20 + MediaQuery.of(context).padding.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ProfileSettingsUi.line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Başlık satırı — küçük kırmızı çember + iki satırlı metin.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.error,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          t.common.deleteAccountTitle,
                          style: ProfileSettingsUi.title.copyWith(
                            fontSize: 17,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text(
                  t.common.deleteAccountWarning,
                  style: AppTypography.body2.copyWith(
                    color: ProfileSettingsUi.muted,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),

                // İpucu — küçük metin.
                Text(
                  t.common.deleteAccountTypeHint,
                  style: ProfileSettingsUi.fieldLabel.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 8),

                // Doğrulama cümlesi — dokununca input'a yazılan tap-to-fill.
                _PhrasePreview(
                  phrase: phrase,
                  onTap: _deleting ? null : () => _fillPhrase(phrase),
                ),
                const SizedBox(height: 12),

                // Inline alt çizgi tabanlı text field.
                TextField(
                  controller: _controller,
                  autofocus: true,
                  enabled: !_deleting,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => setState(() {}),
                  style: ProfileSettingsUi.fieldValue.copyWith(
                    letterSpacing: 1.0,
                  ),
                  cursorColor: ProfileSettingsUi.ink,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: ProfileSettingsUi.line),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ProfileSettingsUi.line),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ProfileSettingsUi.ink,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _deleting
                              ? null
                              : () => Navigator.of(context).pop(false),
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
                            style: ProfileSettingsUi.fieldValue.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: canSubmit ? () => _delete(phrase) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppColors.error.withValues(alpha: 0.30),
                            disabledForegroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ProfileSettingsUi.radiusMd,
                              ),
                            ),
                            textStyle: ProfileSettingsUi.fieldValue.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: _deleting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(t.common.deleteAccountConfirmButton),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Doğrulama cümlesini gösteren — tıklanınca input'a yazan — kompakt kart.
class _PhrasePreview extends StatelessWidget {
  final String phrase;
  final VoidCallback? onTap;

  const _PhrasePreview({required this.phrase, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.error.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(ProfileSettingsUi.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ProfileSettingsUi.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  phrase,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.touch_app_outlined,
                size: 18,
                color: AppColors.error.withValues(alpha: 0.75),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
