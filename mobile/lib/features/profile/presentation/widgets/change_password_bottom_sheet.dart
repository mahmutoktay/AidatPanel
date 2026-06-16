import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../../shared/widgets/password_criterion.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

/// PasswordField Reusable Widget
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFieldSubmitted;
  final Widget? passwordCriteria;

  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.validator,
    this.enabled = true,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onFieldSubmitted,
    this.passwordCriteria,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  late FocusNode _focusNode;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9A9686),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          enabled: widget.enabled,
          focusNode: _focusNode,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onFieldSubmitted: (_) {
            if (widget.onFieldSubmitted != null) {
              widget.onFieldSubmitted!();
            }
          },
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF15140F),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF9A9686),
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF9A9686),
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE7E4DA), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE7E4DA), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF15140F), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE15B4D), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE15B4D), width: 1.5),
            ),
            errorStyle: const TextStyle(
              color: Color(0xFFE15B4D),
              fontSize: 12,
            ),
          ),
          validator: widget.validator,
        ),
        if (widget.hintText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.hintText!,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5,
              color: Color(0xFF9A9686),
            ),
          ),
        ],
        if (widget.passwordCriteria != null) ...[
          const SizedBox(height: 8),
          widget.passwordCriteria!,
        ],
      ],
    );
  }
}

/// Redesigned ChangePasswordBottomSheet
class ChangePasswordBottomSheet extends ConsumerStatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.sheetBackground,
      barrierColor: const Color(0x6114120C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
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

  final RegExp _upperRegex = RegExp(r'[A-Z]');
  final RegExp _lowerRegex = RegExp(r'[a-z]');
  final RegExp _digitRegex = RegExp(r'[0-9]');
  final RegExp _specialRegex = RegExp(r'[@$!%*?&.]');

  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
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
      _hasUpperCase = _upperRegex.hasMatch(value);
      _hasLowerCase = _lowerRegex.hasMatch(value);
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
      case 'password_uppercase_required':
        return t.validation.passwordUppercaseRequired;
      case 'password_lowercase_required':
        return t.validation.passwordLowercaseRequired;
      case 'password_number_required':
        return t.validation.passwordNumberRequired;
      case 'password_special_char_required':
        return t.validation.passwordSpecialCharRequired;
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

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    final newPasswordText = _newPwController.text;
    final int strength = newPasswordText.isEmpty ? -1 : InputValidators.getPasswordStrength(newPasswordText);

    final String strengthLabel;
    final Color strengthBg;
    final Color strengthText;
    final Color strengthDot;

    if (strength == -1) {
      strengthLabel = "Belirtilmemiş";
      strengthBg = const Color(0xFFEAE8E0);
      strengthText = const Color(0xFF9A9686);
      strengthDot = const Color(0xFFB0AC9D);
    } else if (strength <= 2) {
      strengthLabel = "Zayıf";
      strengthBg = const Color(0xFFFDEDEC);
      strengthText = const Color(0xFFE15B4D);
      strengthDot = const Color(0xFFE15B4D);
    } else if (strength <= 4) {
      strengthLabel = "Orta";
      strengthBg = const Color(0xFFFEF9E7);
      strengthText = const Color(0xFF92400E);
      strengthDot = const Color(0xFFF2A93D);
    } else {
      strengthLabel = "Güçlü";
      strengthBg = const Color(0xFFF6F8F3);
      strengthText = const Color(0xFF16A34A);
      strengthDot = const Color(0xFF4ADE80);
    }

    return PopScope(
      canPop: !_submitting,
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets),
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            24 + MediaQuery.of(context).padding.bottom,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Drag Handle
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

                  // 2. Header Row
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
                          Icons.lock_outline_rounded,
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
                              t.common.changePasswordTitle,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF15140F),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t.common.changePasswordSubtitle,
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
                  const SizedBox(height: 20),

                  // 3. Strength Pill
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: strengthBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: strengthDot,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Yeni şifre güvenlik seviyesi: $strengthLabel",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: strengthText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Form Fields
                  PasswordField(
                    controller: _currentPwController,
                    label: t.common.currentPassword,
                    enabled: !_submitting,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t.common.currentPasswordRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  PasswordField(
                    controller: _newPwController,
                    focusNode: _newPwFocusNode,
                    label: t.common.newPassword,
                    hintText: "Büyük harf, küçük harf ve rakam içermeli",
                    enabled: !_submitting,
                    textInputAction: TextInputAction.next,
                    validator: _validateNewPassword,
                    passwordCriteria: _newPwFocusNode.hasFocus
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PasswordCriterion(
                                text: context.t.features.auth.minLength,
                                isMet: _hasMinLength,
                              ),
                              PasswordCriterion(
                                text: context.t.features.auth.hasUpperCase,
                                isMet: _hasUpperCase,
                              ),
                              PasswordCriterion(
                                text: context.t.features.auth.hasLowerCase,
                                isMet: _hasLowerCase,
                              ),
                              PasswordCriterion(
                                text: context.t.features.auth.hasNumber,
                                isMet: _hasNumber,
                              ),
                              PasswordCriterion(
                                text: context.t.features.auth.hasSpecialChar,
                                isMet: _hasSpecialChar,
                              ),
                            ],
                          )
                        : null,
                  ),
                  const SizedBox(height: 20),
                  PasswordField(
                    controller: _confirmPwController,
                    label: t.common.newPasswordConfirm,
                    enabled: !_submitting,
                    textInputAction: TextInputAction.done,
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
                  const SizedBox(height: 28),

                  // 5. Actions Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
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
                          onPressed: _submitting ? null : _submit,
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
                          child: _submitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(t.common.changePasswordTitle),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
