import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/auth_screen_shell.dart';
import '../../../../shared/widgets/auth_form_styles.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../domain/entities/forgot_password_result.dart';
import '../providers/auth_provider.dart';

/// Tur 5 / §10/6 — Şifre Sıfırlama ekranı.
///
/// Backend kabul ettiği token alfabesi (Crockford Base32 türevi):
/// `23456789ABCDEFGHJKLMNPQRSTUVWXYZ` (uzunluk 6, trim + büyük harfe çevirir).
class ResetPasswordScreen extends ConsumerStatefulWidget {
  final ResetPasswordArgs? args;

  /// Geriye dönük: yalnızca e-posta string'i ile açılış.
  final String? prefilledEmail;

  const ResetPasswordScreen({
    super.key,
    this.args,
    this.prefilledEmail,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _newPwController = TextEditingController();
  final _confirmPwController = TextEditingController();
  static final _resetCodeAlphabet = RegExp(
    r'^[23456789ABCDEFGHJKLMNPQRSTUVWXYZ]{6}$',
  );
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  bool _smsFallbackLoading = false;
  late bool _smsFallbackAvailable;
  late String? _deliveredVia;

  ResetPasswordArgs get _args =>
      widget.args ??
      ResetPasswordArgs(
        identifier: widget.prefilledEmail,
        email: widget.prefilledEmail,
      );

  @override
  void initState() {
    super.initState();
    _smsFallbackAvailable = _args.smsFallbackAvailable;
    _deliveredVia = _args.deliveredVia;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

  String get _subtitle {
    final t = context.t;
    switch (_deliveredVia) {
      case 'email':
        return t.common.resetPasswordSubtitleEmail;
      case 'sms':
        return t.common.resetPasswordSubtitleSms;
      default:
        return t.common.resetPasswordSubtitle;
    }
  }

  String? get _displayIdentifier {
    final id = _args.identifier ?? widget.prefilledEmail;
    if (id == null || id.isEmpty) return null;
    return id;
  }

  String? _validateNewPassword(String? value) {
    final t = context.t;
    final key = InputValidators.validatePassword(value);
    if (key == null) return null;
    switch (key) {
      case 'password_required':
        return t.validation.passwordRequired;
      case 'password_too_short':
        return t.validation.passwordTooShort;
      case 'password_too_long':
        return t.validation.passwordTooLong;
      case 'password_alphanumeric_required':
        return t.validation.passwordAlphanumericRequired;
      default:
        return t.validation.passwordRequired;
    }
  }

  Future<void> _sendSmsFallback() async {
    if (_smsFallbackLoading || _submitting || !_smsFallbackAvailable) return;

    final email = _args.email;
    final phone = _args.phone;
    if ((email == null || email.isEmpty) && (phone == null || phone.isEmpty)) {
      return;
    }

    setState(() => _smsFallbackLoading = true);
    final repo = ref.read(authRepositoryProvider);

    try {
      final result = await repo.forgotPassword(
        email: email,
        phone: phone,
        channel: 'sms',
      );
      if (!mounted) return;

      setState(() {
        _smsFallbackAvailable = result.smsFallbackAvailable;
        _deliveredVia = result.deliveredVia ?? 'sms';
      });

      ref.read(toastProvider.notifier).show(
            context.t.common.forgotPasswordSmsFallbackSuccess,
            type: ToastType.success,
            duration: const Duration(seconds: 5),
          );
    } on ApiException catch (e) {
      if (!mounted) return;
      ref
          .read(toastProvider.notifier)
          .show(userFacingError(e), type: ToastType.error);
    } finally {
      if (mounted) setState(() => _smsFallbackLoading = false);
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    final repo = ref.read(authRepositoryProvider);

    try {
      await repo.resetPassword(
        _codeController.text.trim().toUpperCase(),
        _newPwController.text,
      );
      if (!mounted) return;

      ref.read(toastProvider.notifier).show(
            context.t.common.resetPasswordSuccess,
            type: ToastType.success,
            duration: const Duration(seconds: 5),
          );
      context.go('/login');
    } on ApiException catch (e) {
      if (!mounted) return;
      ref.read(toastProvider.notifier).show(
            userFacingError(e),
            type: ToastType.error,
            duration: const Duration(seconds: 6),
          );
    } catch (_) {
      if (!mounted) return;
      ref
          .read(toastProvider.notifier)
          .show(context.t.common.resetPasswordFailed, type: ToastType.error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final busy = _submitting || _smsFallbackLoading;
    final identifier = _displayIdentifier;

    return AuthScreenShell(
      wrapInCard: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 18, top: 16),
        child: AppBackButton(
          enabled: !busy,
          onPressed: () => context.pop(),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 52,
                height: 52,
                margin: const EdgeInsets.only(top: AppSizes.spacingS),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDEDEC),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: Color(0xFFE15B4D),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingL),
            Text(
              t.common.resetPasswordTitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF15140F),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingS),
            Text(
              _subtitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B6757),
              ),
              textAlign: TextAlign.center,
            ),
            if (identifier != null) ...[
              const SizedBox(height: AppSizes.spacingS),
              Text(
                identifier,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15140F),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSizes.spacingXL),
            TextFormField(
              controller: _codeController,
              enabled: !busy,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(
                    '[23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjklmnpqrstuvwxyz]',
                  ),
                ),
              ],
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                letterSpacing: 6,
                fontWeight: FontWeight.w700,
                color: Color(0xFF15140F),
              ),
              textAlign: TextAlign.center,
              decoration: AuthFormStyles.whiteField(
                labelText: t.common.resetCode,
                hintText: t.common.resetCodeHint,
                counterText: '',
                prefixIcon: const Icon(
                  Icons.vpn_key_outlined,
                  size: AppSizes.iconSize,
                ),
              ),
              validator: (value) {
                final v = (value ?? '').trim().toUpperCase();
                if (v.isEmpty) return t.common.resetCodeRequired;
                if (!_resetCodeAlphabet.hasMatch(v)) {
                  return t.common.resetCodeInvalid;
                }
                return null;
              },
            ),
            if (_smsFallbackAvailable) ...[
              const SizedBox(height: AppSizes.spacingS),
              TextButton(
                onPressed: busy ? null : _sendSmsFallback,
                child: _smsFallbackLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        t.common.forgotPasswordSmsFallback,
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.action,
                        ),
                      ),
              ),
            ],
            const SizedBox(height: AppSizes.spacingM),
            TextFormField(
              controller: _newPwController,
              enabled: !busy,
              obscureText: _obscureNew,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              style: AppTypography.body1,
              decoration: AuthFormStyles.whiteField(
                labelText: t.common.newPassword,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  size: AppSizes.iconSize,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility,
                    size: AppSizes.iconSize,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              validator: _validateNewPassword,
            ),
            const SizedBox(height: AppSizes.spacingM),
            TextFormField(
              controller: _confirmPwController,
              enabled: !busy,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              style: AppTypography.body1,
              decoration: AuthFormStyles.whiteField(
                labelText: t.common.newPasswordConfirm,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  size: AppSizes.iconSize,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    size: AppSizes.iconSize,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.features.auth.confirmPassword;
                }
                if (value != _newPwController.text) {
                  return t.features.auth.passwordsDoNotMatch;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacingL),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppSizes.buttonHeightSecondary,
                    child: OutlinedButton(
                      onPressed: busy ? null : () => context.go('/login'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.inkDark,
                        backgroundColor: AppColors.surface,
                        side: BorderSide(
                          color: AppColors.lineLight,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.buttonRadius,
                          ),
                        ),
                        textStyle: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(t.common.backToLogin),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingS),
                Expanded(
                  child: SizedBox(
                    height: AppSizes.buttonHeightSecondary,
                    child: FilledButton(
                      onPressed: busy ? null : _submit,
                      child: _submitting
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onAction,
                              ),
                            )
                          : Text(t.common.resetPasswordSubmit),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
