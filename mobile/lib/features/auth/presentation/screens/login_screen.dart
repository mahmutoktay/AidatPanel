import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/navigation/auth_back_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/auth_screen_shell.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _identifierController;
  late TextEditingController _passwordController;
  late FocusNode _identifierFocusNode;
  // Identifier "next" tuşundan sonra şifreye odaklanmak için.
  late FocusNode _passwordFocusNode;
  final ValueNotifier<bool> _obscurePasswordNotifier = ValueNotifier(true);
  bool _usePhoneLogin = false;

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController();
    _passwordController = TextEditingController();
    _identifierFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _identifierFocusNode.dispose();
    _passwordFocusNode.dispose();
    _obscurePasswordNotifier.dispose();
    super.dispose();
  }

  void _toggleLoginMode() {
    _identifierFocusNode.unfocus();
    setState(() {
      _usePhoneLogin = !_usePhoneLogin;
      _identifierController.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      _identifierFocusNode.requestFocus();
    });
  }

  void _handleLogin(BuildContext context) {
    if (ref.read(authStateProvider).isLoading) return;
    ref.read(authStateProvider.notifier).submitLogin(
          _identifierController.text,
          _passwordController.text,
          _usePhoneLogin,
          ref,
        );
  }

  InputDecoration _whiteFieldDecoration({
    required String labelText,
    required String hintText,
    Widget? prefixIcon,
    String? prefixText,
    Widget? suffixIcon,
    String? counterText,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputRadius),
      borderSide: BorderSide.none,
    );
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixText: prefixText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      counterText: counterText,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: AppSizes.spacingM,
      ),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: AppColors.lineLight, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (previous, next) {
      if (next.isAuthenticated &&
          next.user != null &&
          !(previous?.isAuthenticated ?? false)) {
        ref
            .read(toastProvider.notifier)
            .show(
              context.t.features.auth.loginSuccess,
              type: ToastType.success,
              duration: const Duration(seconds: 4),
            );
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

    return AuthBackHandler(
      child: AuthScreenShell(
        showBrandHeader: true,
        wrapInCard: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.t.features.auth.login,
              style: AppTypography.h2.copyWith(
                color: AppColors.inkDark,
              ),
            ),
            const SizedBox(height: AppSizes.spacingL),
            TextField(
              key: ValueKey(_usePhoneLogin ? 'phone' : 'email'),
              controller: _identifierController,
              focusNode: _identifierFocusNode,
              enabled: !authState.isLoading,
              keyboardType: _usePhoneLogin
                  ? TextInputType.phone
                  : TextInputType.emailAddress,
              maxLength: _usePhoneLogin ? 10 : null,
              inputFormatters: _usePhoneLogin
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _passwordFocusNode.requestFocus(),
              autofillHints: _usePhoneLogin
                  ? const [AutofillHints.telephoneNumberNational]
                  : const [
                      AutofillHints.username,
                      AutofillHints.email,
                    ],
              style: AppTypography.body1,
              decoration: _whiteFieldDecoration(
                labelText: _usePhoneLogin
                    ? context.t.features.auth.phone
                    : context.t.features.auth.email,
                hintText: _usePhoneLogin
                    ? context.t.features.auth.phoneHint
                    : context.t.features.auth.emailHint,
                prefixText: _usePhoneLogin ? '+90 ' : null,
                prefixIcon: Icon(
                  _usePhoneLogin
                      ? Icons.phone_outlined
                      : Icons.email_outlined,
                  size: AppSizes.iconSize,
                ),
                counterText: _usePhoneLogin ? '' : null,
              ),
            ),
            const SizedBox(height: AppSizes.spacingFieldSpacing),
            ValueListenableBuilder<bool>(
              valueListenable: _obscurePasswordNotifier,
              builder: (context, isObscure, child) {
                return TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  enabled: !authState.isLoading,
                  obscureText: isObscure,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleLogin(context),
                  autofillHints: const [AutofillHints.password],
                  style: AppTypography.body1,
                  decoration: _whiteFieldDecoration(
                    labelText: context.t.features.auth.password,
                    hintText: context.t.features.auth.passwordHint,
                    prefixIcon: Icon(
                      Icons.lock_outlined,
                      size: AppSizes.iconSize,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isObscure
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: AppSizes.iconSize,
                      ),
                      onPressed: () {
                        _obscurePasswordNotifier.value = !isObscure;
                      },
                      iconSize: AppSizes.iconTouchTarget,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingFieldSpacing),
            ElevatedButton(
              onPressed: authState.isLoading
                  ? null
                  : () => _handleLogin(context),
              style: ProfileSettingsUi.primaryButton,
              child: authState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(context.t.features.auth.login),
            ),
            const SizedBox(height: AppSizes.spacingXS),
            OutlinedButton.icon(
              onPressed: authState.isLoading ? null : _toggleLoginMode,
              icon: Icon(
                _usePhoneLogin
                    ? Icons.email_outlined
                    : Icons.phone_iphone_outlined,
                size: 20,
              ),
              label: Text(
                _usePhoneLogin
                    ? context.t.features.auth.emailLogin
                    : context.t.features.auth.phoneLogin,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.inkDark,
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: AppColors.lineLight,
                  width: 1,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.cardRadius,
                  ),
                ),
                textStyle: AppTypography.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingXS),
            AuthTextButton(
              label: context.t.common.forgotPassword,
              onTap: authState.isLoading
                  ? null
                  : () => context.push('/forgot-password'),
            ),
            const SizedBox(height: AppSizes.spacingXS),
            AuthTextButton(
              label: context.t.features.auth.signUp,
              onTap: authState.isLoading
                  ? null
                  : () => context.push('/sign-up'),
            ),
            const SizedBox(height: AppSizes.spacingL),
            Text(
              '${context.t.features.auth.copyright} v${AppConstants.appVersion}',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
