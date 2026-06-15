import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/utils/auth_validators.dart';
import '../../../../shared/widgets/auth_form_styles.dart';
import '../../../../shared/widgets/auth_screen_shell.dart';
import '../widgets/auth_brand_header.dart';
import '../../../../shared/widgets/password_criterion.dart';
import '../../../../shared/widgets/password_field.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../providers/auth_provider.dart';
import '../widgets/sign_up_role_toggle.dart';

/// Birleşik üyelik ekranı: varsayılan sakin (davet kodu), üstten yönetici geçişi.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key, this.initialIsManager = false});

  /// `true` → yönetici kayıt formu; `false` → sakin (davet kodu) formu.
  final bool initialIsManager;

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  static final _upperRegex = RegExp(r'[A-Z]');
  static final _lowerRegex = RegExp(r'[a-z]');
  static final _digitRegex = RegExp(r'\d');
  static final _specialRegex = RegExp(r'[@$!%*?&.]');

  late bool _isManager;
  late TextEditingController _inviteCodeController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  final FocusNode _inviteCodeFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _inviteCodeError;
  String? _emailError;
  String? _phoneError;
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    _isManager = widget.initialIsManager;
    _inviteCodeController = TextEditingController();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _inviteCodeFocusNode.dispose();
    _emailFocusNode.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _switchToResident() {
    if (!_isManager) return;
    setState(() => _isManager = false);
  }

  void _switchToManager() {
    if (_isManager) return;
    setState(() => _isManager = true);
  }

  void _handleRegister() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final nameError = InputValidators.validateName(name);
    if (nameError != null) {
      ref.read(toastProvider.notifier).show(nameError, type: ToastType.error);
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      ref
          .read(toastProvider.notifier)
          .show(
            context.t.features.auth.emailAndPasswordRequired,
            type: ToastType.error,
          );
      return;
    }

    final emailError = InputValidators.validateEmail(email);
    if (emailError != null) {
      final errorMessage = emailError == 'email_required'
          ? context.t.validation.emailRequired
          : emailError == 'email_invalid'
          ? context.t.validation.emailInvalid
          : context.t.validation.emailTooLong;
      ref
          .read(toastProvider.notifier)
          .show(errorMessage, type: ToastType.error);
      return;
    }

    if (phone.isNotEmpty) {
      final phoneError = InputValidators.validatePhone(phone);
      if (phoneError != null) {
        final errorMessage = phoneError == 'phone_required'
            ? context.t.validation.phoneRequired
            : context.t.validation.phoneInvalid;
        ref
            .read(toastProvider.notifier)
            .show(errorMessage, type: ToastType.error);
        return;
      }
    }

    if (password != confirmPassword) {
      ref
          .read(toastProvider.notifier)
          .show(
            context.t.features.auth.passwordsDoNotMatch,
            type: ToastType.error,
          );
      return;
    }

    final passwordError = InputValidators.validatePassword(password);
    if (passwordError != null) {
      ref
          .read(toastProvider.notifier)
          .show(passwordError, type: ToastType.error);
      return;
    }

    ref
        .read(authStateProvider.notifier)
        .register(email, password, name, phone.isEmpty ? null : phone);
  }

  void _handleJoin() {
    final inviteCode = AuthValidators.normalizeInviteCode(
      _inviteCodeController.text,
    );
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (inviteCode.isEmpty ||
        email.isEmpty ||
        name.isEmpty ||
        password.isEmpty) {
      ref
          .read(toastProvider.notifier)
          .show(
            context.t.features.auth.inviteCodeAndPasswordRequired,
            type: ToastType.error,
          );
      return;
    }

    if (!AuthValidators.isValidInviteCode(inviteCode)) {
      ref
          .read(toastProvider.notifier)
          .show(
            context.t.features.auth.invalidInviteCodeFormat,
            type: ToastType.error,
          );
      return;
    }

    final emailError = InputValidators.validateEmail(email);
    if (emailError != null) {
      final errorMessage = emailError == 'email_required'
          ? context.t.validation.emailRequired
          : emailError == 'email_invalid'
          ? context.t.validation.emailInvalid
          : context.t.validation.emailTooLong;
      ref
          .read(toastProvider.notifier)
          .show(errorMessage, type: ToastType.error);
      return;
    }

    if (phone.isNotEmpty) {
      final phoneError = InputValidators.validatePhone(phone);
      if (phoneError != null) {
        ref
            .read(toastProvider.notifier)
            .show(
              context.t.validation.phoneInvalid,
              type: ToastType.error,
            );
        return;
      }
    }

    if (password != confirmPassword) {
      ref
          .read(toastProvider.notifier)
          .show(
            context.t.features.auth.passwordsDoNotMatch,
            type: ToastType.error,
          );
      return;
    }

    final passwordError = InputValidators.validatePassword(password);
    if (passwordError != null) {
      final errorMessage = passwordError == 'password_required'
          ? context.t.validation.passwordRequired
          : passwordError == 'password_too_short'
          ? context.t.validation.passwordTooShort
          : passwordError == 'password_too_long'
          ? context.t.validation.passwordTooLong
          : passwordError == 'password_uppercase_required'
          ? context.t.validation.passwordUppercaseRequired
          : passwordError == 'password_lowercase_required'
          ? context.t.validation.passwordLowercaseRequired
          : passwordError == 'password_number_required'
          ? context.t.validation.passwordNumberRequired
          : context.t.validation.passwordSpecialCharRequired;
      ref
          .read(toastProvider.notifier)
          .show(errorMessage, type: ToastType.error);
      return;
    }

    ref
        .read(authStateProvider.notifier)
        .join(
          inviteCode,
          email,
          password,
          name,
          phone.isEmpty ? null : phone,
          ref,
        );
  }

  void _onSubmit() {
    if (_isManager) {
      _handleRegister();
    } else {
      _handleJoin();
    }
  }

  Widget _buildInviteCodeField(bool isLoading) {
    return TextField(
      controller: _inviteCodeController,
      focusNode: _inviteCodeFocusNode,
      enabled: !isLoading,
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => _emailFocusNode.requestFocus(),
      style: AppTypography.body1,
      decoration: AuthFormStyles.whiteField(
        labelText: context.t.features.auth.inviteCode,
        hintText: context.t.features.auth.inviteCodeHint,
        prefixIcon: Icon(Icons.vpn_key_outlined, size: AppSizes.iconSize),
        errorText: _inviteCodeError,
      ),
      onChanged: (value) {
        final normalized = AuthValidators.normalizeInviteCode(value);
        setState(() {
          if (normalized.isNotEmpty &&
              !AuthValidators.isValidInviteCode(normalized)) {
            _inviteCodeError = context.t.features.auth.invalidInviteCodeFormat;
          } else {
            _inviteCodeError = null;
          }
        });
      },
    );
  }

  Widget _buildNameField(bool isLoading) {
    return TextField(
      controller: _nameController,
      focusNode: _nameFocusNode,
      enabled: !isLoading,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => _isManager
          ? _emailFocusNode.requestFocus()
          : _phoneFocusNode.requestFocus(),
      autofillHints: const [AutofillHints.name],
      textCapitalization: TextCapitalization.words,
      style: AppTypography.body1,
      decoration: AuthFormStyles.whiteField(
        labelText: context.t.features.auth.name,
        hintText: context.t.features.auth.nameHint,
        prefixIcon: Icon(Icons.person_outline, size: AppSizes.iconSize),
      ),
    );
  }

  Widget _buildEmailField(bool isLoading) {
    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      enabled: !isLoading,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => _isManager
          ? _phoneFocusNode.requestFocus()
          : _nameFocusNode.requestFocus(),
      autofillHints: const [AutofillHints.newUsername, AutofillHints.email],
      style: AppTypography.body1,
      decoration: AuthFormStyles.whiteField(
        labelText: context.t.features.auth.email,
        hintText: context.t.features.auth.emailHint,
        prefixIcon: Icon(Icons.email_outlined, size: AppSizes.iconSize),
        errorText: _emailError == null
            ? null
            : _emailError == 'email_required'
            ? context.t.validation.emailRequired
            : _emailError == 'email_invalid'
            ? context.t.validation.emailInvalid
            : context.t.validation.emailTooLong,
      ),
      onChanged: (value) {
        setState(() {
          _emailError = InputValidators.validateEmail(value);
        });
      },
    );
  }

  Widget _buildPhoneField(bool isLoading) {
    return TextField(
      controller: _phoneController,
      focusNode: _phoneFocusNode,
      enabled: !isLoading,
      keyboardType: TextInputType.number,
      maxLength: 10,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => _passwordFocusNode.requestFocus(),
      autofillHints: const [AutofillHints.telephoneNumberNational],
      style: AppTypography.body1,
      decoration: AuthFormStyles.whiteField(
        labelText: context.t.features.auth.phoneOptional,
        hintText: context.t.features.auth.phoneHintOptional,
        prefixText: '+90 ',
        prefixIcon: Icon(Icons.phone_outlined, size: AppSizes.iconSize),
        counterText: '',
        errorText: _phoneError == null
            ? null
            : context.t.validation.phoneInvalid,
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) {
        setState(() {
          _phoneError = value.trim().isEmpty
              ? null
              : InputValidators.validatePhone(value);
        });
      },
    );
  }

  Widget _buildPasswordFields(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PasswordField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          whiteBackground: true,
          labelText: context.t.features.auth.password,
          hintText: context.t.features.auth.passwordHint,
          onToggleVisibility: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          enabled: !isLoading,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
          autofillHints: const [AutofillHints.newPassword],
          onChanged: (value) {
            setState(() {
              _hasMinLength = value.length >= 6;
              _hasUpperCase = _upperRegex.hasMatch(value);
              _hasLowerCase = _lowerRegex.hasMatch(value);
              _hasNumber = _digitRegex.hasMatch(value);
              _hasSpecialChar = _specialRegex.hasMatch(value);
            });
          },
          focusNode: _passwordFocusNode,
          passwordCriteria: _passwordFocusNode.hasFocus
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
        const SizedBox(height: AppSizes.spacingFieldSpacing),
        PasswordField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          whiteBackground: true,
          labelText: context.t.features.auth.confirmPassword,
          hintText: context.t.features.auth.passwordHint,
          onToggleVisibility: () {
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
          },
          enabled: !isLoading,
          focusNode: _confirmPasswordFocusNode,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _onSubmit(),
          autofillHints: const [AutofillHints.newPassword],
          onChanged: (value) {
            setState(() {
              _passwordsMatch = value == _passwordController.text;
            });
          },
          helperText: _confirmPasswordController.text.isEmpty
              ? null
              : _passwordsMatch
              ? null
              : context.t.features.auth.passwordsDoNotMatch,
        ),
      ],
    );
  }

  Widget _buildResidentForm(bool isLoading) {
    return Column(
      key: const ValueKey('resident_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInviteCodeField(isLoading),
        const SizedBox(height: AppSizes.spacingFieldSpacing),
        _buildEmailField(isLoading),
        const SizedBox(height: AppSizes.spacingFieldSpacing),
        _buildNameField(isLoading),
        const SizedBox(height: AppSizes.spacingFieldSpacing),
        _buildPhoneField(isLoading),
        const SizedBox(height: AppSizes.spacingFieldSpacing),
        _buildPasswordFields(isLoading),
      ],
    );
  }

  Widget _buildManagerForm(bool isLoading) {
    return Column(
      key: const ValueKey('manager_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildNameField(isLoading),
        const SizedBox(height: AppSizes.spacingFieldSpacing),
        _buildEmailField(isLoading),
        const SizedBox(height: AppSizes.spacingFieldSpacing),
        _buildPhoneField(isLoading),
        const SizedBox(height: AppSizes.spacingFieldSpacing),
        _buildPasswordFields(isLoading),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    ref.listen(authStateProvider, (previous, next) {
      if (next.registrationSuccess &&
          !(previous?.registrationSuccess ?? false)) {
        ref
            .read(toastProvider.notifier)
            .show(
              context.t.features.auth.registrationSuccess,
              type: ToastType.success,
              duration: const Duration(seconds: 6),
            );
        context.go('/login');
      }
      if (next.error != null && next.error != previous?.error) {
        ref
            .read(toastProvider.notifier)
            .show(
              next.error ?? context.t.features.auth.errorOccurred,
              type: ToastType.error,
            );
      }
    });

    final formTitle = _isManager
        ? context.t.features.auth.createAccount
        : context.t.features.auth.joinApartment;

    return AuthScreenShell(
      showBrandHeader: true,
      brandHeaderLayout: AuthBrandHeaderLayout.horizontal,
      wrapInCard: false,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: ProfileSettingsUi.ink,
        ),
        onPressed: isLoading ? null : () => context.pop(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SignUpRoleToggle(
            isManager: _isManager,
            residentLabel: context.t.common.resident,
            managerLabel: context.t.common.manager,
            onResidentTap: _switchToResident,
            onManagerTap: _switchToManager,
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSizes.spacingL),
          Text(
            formTitle,
            style: AppTypography.h2.copyWith(
              color: AppColors.inkDark,
            ),
          ),
          const SizedBox(height: AppSizes.spacingL),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: _isManager
                ? _buildManagerForm(isLoading)
                : _buildResidentForm(isLoading),
          ),
          const SizedBox(height: AppSizes.spacingFieldSpacing),
          ElevatedButton(
            onPressed: isLoading ? null : _onSubmit,
            style: ProfileSettingsUi.primaryButton,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _isManager
                        ? context.t.features.auth.register
                        : context.t.features.auth.join,
                  ),
          ),
        ],
      ),
    );
  }
}
