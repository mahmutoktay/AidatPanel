import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/alt_action_button.dart';
import '../../../../shared/widgets/password_field.dart';
import '../../../../shared/widgets/password_criterion.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  static final _upperRegex = RegExp(r'[A-Z]');
  static final _lowerRegex = RegExp(r'[a-z]');
  static final _digitRegex = RegExp(r'\d');
  static final _specialRegex = RegExp(r'[@$!%*?&]');
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  final FocusNode _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleRegister(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (previous, next) {
      if (next.registrationSuccess && !(previous?.registrationSuccess ?? false)) {
        ref
            .read(toastProvider.notifier)
            .show(
              context.t.features.auth.registrationSuccess,
              type: ToastType.success,
            );
        context.go('/login');
      } else if (next.error != null && next.error != previous?.error) {
        ref
            .read(toastProvider.notifier)
            .show(
              next.error ?? context.t.features.auth.errorOccurred,
              type: ToastType.error,
            );
      }
    });

    return PopScope(
      canPop: !authState.isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: SizedBox(
                      height: 160,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.apartment_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: AppSizes.spacingM),
                          Text(
                            context.t.features.auth.appTitle,
                            style: AppTypography.h2.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSizes.spacingXS),
                          Text(
                            context.t.features.auth.appSubtitle,
                            style: AppTypography.body2.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSizes.spacingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.t.features.auth.createAccount,
                            style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: AppSizes.spacingL),
                    TextField(
                      controller: _nameController,
                      enabled: !authState.isLoading,
                      style: AppTypography.body1,
                      decoration: InputDecoration(
                        labelText: context.t.features.auth.name,
                        hintText: context.t.features.auth.nameHint,
                        prefixIcon: Icon(
                          Icons.person_outline,
                          size: AppSizes.iconSize,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.spacingM,
                          vertical: AppSizes.spacingM,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.inputRadius,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    TextField(
                      controller: _emailController,
                      enabled: !authState.isLoading,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTypography.body1,
                      decoration: InputDecoration(
                        labelText: context.t.features.auth.email,
                        hintText: context.t.features.auth.emailHint,
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          size: AppSizes.iconSize,
                        ),
                        errorText: _emailError == null
                            ? null
                            : _emailError == 'email_required'
                            ? context.t.validation.emailRequired
                            : _emailError == 'email_invalid'
                            ? context.t.validation.emailInvalid
                            : context.t.validation.emailTooLong,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.spacingM,
                          vertical: AppSizes.spacingM,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.inputRadius,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _emailError = InputValidators.validateEmail(value);
                        });
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    TextField(
                      controller: _phoneController,
                      enabled: !authState.isLoading,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      style: AppTypography.body1,
                      decoration: InputDecoration(
                        labelText: context.t.features.auth.phoneOptional,
                        hintText: context.t.features.auth.phoneHintOptional,
                        prefixText: '+90 ',
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          size: AppSizes.iconSize,
                        ),
                        counterText: '',
                        errorText: _phoneError == null
                            ? null
                            : _phoneError == 'phone_required'
                            ? context.t.validation.phoneRequired
                            : context.t.validation.phoneInvalid,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.spacingM,
                          vertical: AppSizes.spacingM,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.inputRadius,
                          ),
                        ),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(() {
                          _phoneError = InputValidators.validatePhone(value);
                        });
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    PasswordField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      labelText: context.t.features.auth.password,
                      hintText: context.t.features.auth.passwordHint,
                      onToggleVisibility: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      enabled: !authState.isLoading,
                      onChanged: (value) {
                        setState(() {
                          _hasMinLength = value.length >= 8;
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
                                PasswordCriterion(text: context.t.features.auth.minLength, isMet: _hasMinLength),
                                PasswordCriterion(text: context.t.features.auth.hasUpperCase, isMet: _hasUpperCase),
                                PasswordCriterion(text: context.t.features.auth.hasLowerCase, isMet: _hasLowerCase),
                                PasswordCriterion(text: context.t.features.auth.hasNumber, isMet: _hasNumber),
                                PasswordCriterion(text: context.t.features.auth.hasSpecialChar, isMet: _hasSpecialChar),
                              ],
                            )
                          : null,
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    PasswordField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      labelText: context.t.features.auth.confirmPassword,
                      hintText: context.t.features.auth.passwordHint,
                      onToggleVisibility: () {
                        setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        );
                      },
                      enabled: !authState.isLoading,
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
                    const SizedBox(height: AppSizes.spacingL),
                    ElevatedButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => _handleRegister(context),
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(context.t.features.auth.register),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    AltActionButton(
                      icon: Icons.login_outlined,
                      title: context.t.features.auth.hasAccount,
                      onTap: authState.isLoading
                          ? null
                          : () => context.go('/login'),
                      isEnabled: !authState.isLoading,
                    ),
                    const SizedBox(height: AppSizes.spacingXL),
                    Text(
                      '${context.t.features.auth.copyright} v${AppConstants.appVersion}',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: authState.isLoading ? null : () => context.pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
