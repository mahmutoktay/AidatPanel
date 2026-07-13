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
import '../../../../core/utils/phone_utils.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/auth_screen_shell.dart';
import '../../../../shared/widgets/auth_form_styles.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../domain/entities/forgot_password_result.dart';
import '../onboarding/auth_onboarding_models.dart';
import '../onboarding/widgets/onboarding_segment_tabs.dart';
import '../providers/auth_provider.dart';

/// Tur 5 / §10/6 — Şifremi Unuttum ekranı.
///
/// Backend `POST /auth/forgot-password` her zaman 200 döner (enumeration leak
/// korumalı). UI kullanıcıya "kod gönderildi" mesajı verip reset ekranına
/// geçirir; kullanıcının kayıtlı olup olmadığını leak etmez.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  AuthContactChannel _contact = AuthContactChannel.email;
  bool _submitting = false;

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  String? _validateContact(String? value) {
    final t = context.t;
    if (_contact == AuthContactChannel.email) {
      final key = InputValidators.validateEmail(value);
      if (key == null) return null;
      switch (key) {
        case 'email_required':
          return t.validation.emailRequired;
        case 'email_invalid':
          return t.validation.emailInvalid;
        case 'email_too_long':
          return t.validation.emailTooLong;
        default:
          return t.validation.emailRequired;
      }
    }

    final raw = value?.trim() ?? '';
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return t.validation.phoneRequired;
    }
    if (PhoneUtils.normalizeTrPhone(digits) == null) {
      return t.validation.phoneInvalid;
    }
    return null;
  }

  String _successMessage(ForgotPasswordResult result) {
    final t = context.t;
    switch (result.deliveredVia) {
      case 'email':
        return t.common.forgotPasswordSuccessEmail;
      case 'sms':
        return t.common.forgotPasswordSuccessSms;
      default:
        return t.common.forgotPasswordSuccess;
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    final repo = ref.read(authRepositoryProvider);
    final raw = _contactController.text.trim();

    String? email;
    String? phone;
    if (_contact == AuthContactChannel.email) {
      email = raw.toLowerCase();
    } else {
      phone = PhoneUtils.normalizeTrPhone(raw);
    }

    try {
      final result = await repo.forgotPassword(email: email, phone: phone);
      if (!mounted) return;

      ref.read(toastProvider.notifier).show(
            _successMessage(result),
            type: ToastType.success,
            duration: const Duration(seconds: 6),
          );

      context.push(
        '/reset-password',
        extra: ResetPasswordArgs(
          identifier: raw,
          email: email,
          phone: phone,
          deliveredVia: result.deliveredVia,
          smsFallbackAvailable: result.smsFallbackAvailable,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ref
          .read(toastProvider.notifier)
          .show(userFacingError(e), type: ToastType.error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final isPhone = _contact == AuthContactChannel.phone;

    return AuthScreenShell(
      wrapInCard: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 18, top: 16),
        child: AppBackButton(
          enabled: !_submitting,
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
                  Icons.vpn_key_rounded,
                  color: Color(0xFFE15B4D),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingL),
            Text(
              t.common.forgotPasswordTitle,
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
              t.common.forgotPasswordSubtitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B6757),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingL),
            OnboardingSegmentTabs(
              isSecondSelected: _contact == AuthContactChannel.email,
              firstLabel: t.features.auth.phone,
              secondLabel: t.features.auth.email,
              onFirstTap: () {
                if (_submitting) return;
                setState(() {
                  _contact = AuthContactChannel.phone;
                  _contactController.clear();
                });
              },
              onSecondTap: () {
                if (_submitting) return;
                setState(() {
                  _contact = AuthContactChannel.email;
                  _contactController.clear();
                });
              },
              enabled: !_submitting,
            ),
            const SizedBox(height: AppSizes.spacingM),
            TextFormField(
              controller: _contactController,
              enabled: !_submitting,
              keyboardType:
                  isPhone ? TextInputType.phone : TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: isPhone
                  ? const [AutofillHints.telephoneNumber]
                  : const [AutofillHints.email],
              maxLength: isPhone ? 11 : null,
              inputFormatters: isPhone
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
              onFieldSubmitted: (_) => _submit(),
              style: AppTypography.body1,
              decoration: AuthFormStyles.whiteField(
                labelText: isPhone
                    ? t.features.auth.phone
                    : t.features.auth.email,
                hintText: isPhone
                    ? t.features.auth.onboarding.managerIdentifierHint
                    : t.features.auth.emailHint,
                counterText: '',
                prefixIcon: Icon(
                  isPhone ? Icons.phone_outlined : Icons.email_outlined,
                  size: AppSizes.iconSize,
                ),
              ),
              validator: _validateContact,
            ),
            const SizedBox(height: AppSizes.spacingL),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppSizes.buttonHeightSecondary,
                    child: OutlinedButton(
                      onPressed: _submitting
                          ? null
                          : () {
                              final raw = _contactController.text.trim();
                              String? email;
                              String? phone;
                              if (_contact == AuthContactChannel.email &&
                                  raw.isNotEmpty) {
                                email = raw.toLowerCase();
                              } else if (raw.isNotEmpty) {
                                phone = PhoneUtils.normalizeTrPhone(raw);
                              }
                              context.push(
                                '/reset-password',
                                extra: ResetPasswordArgs(
                                  identifier: raw.isEmpty ? null : raw,
                                  email: email,
                                  phone: phone,
                                ),
                              );
                            },
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
                      child: Text(t.common.iHaveACode),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingS),
                Expanded(
                  child: SizedBox(
                    height: AppSizes.buttonHeightSecondary,
                    child: FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onAction,
                              ),
                            )
                          : Text(t.common.sendResetCode),
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
