import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../../shared/widgets/password_criterion.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

/// Şifre değiştirme formu — güncel MinimalForm + PremiumSheet dilinde.
class ChangePasswordBottomSheet extends ConsumerStatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (_) => const ChangePasswordBottomSheet(),
    );
  }

  @override
  ConsumerState<ChangePasswordBottomSheet> createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState
    extends ConsumerState<ChangePasswordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPwController = TextEditingController();
  final _newPwController = TextEditingController();
  final _confirmPwController = TextEditingController();
  final _newPwFocusNode = FocusNode();
  bool _submitting = false;

  final RegExp _letterRegex = RegExp(r'[A-Za-zÇĞİÖŞÜçğıöşü]');
  final RegExp _digitRegex = RegExp(r'[0-9]');
  final RegExp _specialRegex = RegExp(r'[^A-Za-zÇĞİÖŞÜçğıöşü0-9]');

  bool _hasMinLength = false;
  bool _hasLetter = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _newPwController.addListener(_onNewPasswordChanged);
    _newPwFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _newPwController.removeListener(_onNewPasswordChanged);
    _newPwFocusNode.removeListener(_onFocusChanged);
    _newPwFocusNode.dispose();
    _currentPwController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _onNewPasswordChanged() {
    final value = _newPwController.text;
    setState(() {
      _hasMinLength = value.length >= 6;
      _hasLetter = _letterRegex.hasMatch(value);
      _hasNumber = _digitRegex.hasMatch(value);
      _hasSpecialChar = _specialRegex.hasMatch(value);
    });
  }

  String? _validateNewPassword(String? value) {
    final t = context.t;
    final key = InputValidators.validatePassword(value);
    if (key == null) {
      if (value != null && value == _currentPwController.text) {
        return t.common.passwordsMustDiffer;
      }
      return null;
    }
    switch (key) {
      case 'password_required':
        return t.validation.passwordRequired;
      case 'password_too_short':
        return t.validation.passwordTooShort;
      case 'password_too_long':
        return t.validation.passwordTooLong;
      case 'password_letter_required':
        return t.validation.passwordLetterRequired;
      case 'password_number_required':
        return t.validation.passwordNumberRequired;
      case 'password_alphanumeric_required':
        return t.validation.passwordAlphanumericRequired;
      default:
        return t.validation.passwordRequired;
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    final repo = ref.read(profileRepositoryProvider);
    final navigator = Navigator.of(context);
    final goRouter = GoRouter.of(context);
    final toast = ref.read(toastProvider.notifier);
    final successMsg = context.t.common.changePasswordSuccess;

    try {
      await repo.changePassword(
        currentPassword: _currentPwController.text,
        newPassword: _newPwController.text,
      );

      if (!mounted) return;
      navigator.pop();

      toast.show(
        successMsg,
        type: ToastType.success,
        duration: const Duration(seconds: 5),
      );

      await ref.read(authStateProvider.notifier).logout(ref, showToast: false);
      goRouter.go('/login');
    } on ApiException catch (e) {
      if (!mounted) return;
      ref.read(toastProvider.notifier).show(
            userFacingError(e),
            type: ToastType.error,
          );
      setState(() => _submitting = false);
    } catch (_) {
      if (!mounted) return;
      ref.read(toastProvider.notifier).show(
            context.t.common.changePasswordFailed,
            type: ToastType.error,
          );
      setState(() => _submitting = false);
    }
  }

  Widget _passwordCriteria() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PasswordCriterion(
          text: context.t.features.auth.minLength,
          isMet: _hasMinLength,
        ),
        PasswordCriterion(
          text: context.t.features.auth.hasLetter,
          isMet: _hasLetter,
        ),
        PasswordCriterion(
          text: context.t.features.auth.hasNumber,
          isMet: _hasNumber,
        ),
        PasswordCriterion(
          text: context.t.features.auth.hasSpecialChar,
          isMet: _hasSpecialChar,
          isOptional: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return PopScope(
      canPop: !_submitting,
      child: Form(
        key: _formKey,
        child: PremiumBottomSheetScaffold(
          title: t.common.changePasswordTitle,
          scrollable: true,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.common.changePasswordSubtitle,
                style: ProfileSettingsUi.handle.copyWith(fontSize: 14),
              ),
              const SizedBox(height: AppSizes.spacingL),
              MinimalPasswordField(
                controller: _currentPwController,
                label: t.common.currentPassword,
                required: true,
                enabled: !_submitting,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.password],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.common.currentPasswordRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spacingM),
              MinimalPasswordField(
                controller: _newPwController,
                focusNode: _newPwFocusNode,
                label: t.common.newPassword,
                hint: t.common.newPasswordHint,
                required: true,
                enabled: !_submitting,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: _validateNewPassword,
                passwordCriteria:
                    _newPwFocusNode.hasFocus ? _passwordCriteria() : null,
              ),
              const SizedBox(height: AppSizes.spacingM),
              MinimalPasswordField(
                controller: _confirmPwController,
                label: t.common.newPasswordConfirm,
                required: true,
                enabled: !_submitting,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onFieldSubmitted: _submit,
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
            ],
          ),
          actions: PremiumSheetActions(
            primaryLabel: t.common.changePasswordTitle,
            onPrimary: _submitting ? null : _submit,
            primaryLoading: _submitting,
            icon: Icons.lock_reset_outlined,
            secondaryLabel: t.common.cancelBtn,
            onSecondary:
                _submitting ? null : () => Navigator.of(context).pop(),
            secondaryEnabled: !_submitting,
          ),
        ),
      ),
    );
  }
}
