import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/navigation/auth_back_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/auth_screen_shell.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../../shared/widgets/password_field.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_button.dart';
import 'auth_onboarding_models.dart';
import 'auth_onboarding_provider.dart';
import 'widgets/auth_step_scaffold.dart';
import '../widgets/auth_brand_mark.dart';
import 'widgets/onboarding_buildings_backdrop.dart';
import 'widgets/onboarding_compact_header.dart';
import 'widgets/onboarding_feature_tile.dart';
import 'widgets/onboarding_identifier_field.dart';
import 'widgets/onboarding_info_banner.dart';
import 'widgets/onboarding_role_cards.dart';
import 'widgets/onboarding_role_step.dart';
import 'widgets/onboarding_segment_tabs.dart';
import 'widgets/onboarding_fixed_choice_layout.dart';
import 'widgets/onboarding_step_transition.dart';
import 'widgets/onboarding_step_actions.dart';
import 'widgets/onboarding_step_scaffold.dart';
import 'widgets/otp_input_row.dart';
import 'widgets/invite_code_input_row.dart';
import 'widgets/phone_input_row.dart';

/// 6 adımlı auth onboarding — tek giriş noktası `/login`.
class AuthOnboardingScreen extends ConsumerStatefulWidget {
  const AuthOnboardingScreen({
    super.key,
    this.initialRole,
    this.initialFlow,
    this.initialStep,
    this.skipRoleStep = false,
    this.initialInviteCode,
  });

  final UserRole? initialRole;
  final AuthOnboardingFlow? initialFlow;
  final int? initialStep;
  final bool skipRoleStep;
  final String? initialInviteCode;

  @override
  ConsumerState<AuthOnboardingScreen> createState() =>
      _AuthOnboardingScreenState();
}

class _AuthOnboardingScreenState extends ConsumerState<AuthOnboardingScreen> {
  final _contactController = TextEditingController();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _inviteController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Timer? _otpTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authOnboardingProvider.notifier).applyInitialQuery(
            role: widget.initialRole,
            flow: widget.initialFlow,
            skipRoleStep: widget.skipRoleStep,
            inviteCode: widget.initialInviteCode,
          );
    });
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _contactController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _inviteController.dispose();
    _nameController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(authOnboardingProvider.notifier).tickOtpResend();
    });
  }

  String _otpPurpose(AuthOnboardingState ob) {
    if (ob.flow == AuthOnboardingFlow.join) return 'resident_join';
    if (ob.flow == AuthOnboardingFlow.register) return 'manager_register';
    if (ob.role == UserRole.manager) return 'manager_login';
    return 'resident_login';
  }

  bool _usesOtpChannel(AuthOnboardingState ob) {
    if (ob.contact == AuthContactChannel.phone) return true;
    return ob.contact == AuthContactChannel.email &&
        ob.flow != AuthOnboardingFlow.legacyLogin;
  }

  bool _isResidentJoin(AuthOnboardingState ob) =>
      ob.flow == AuthOnboardingFlow.join && ob.role == UserRole.resident;

  bool _isResidentLogin(AuthOnboardingState ob) =>
      ob.role == UserRole.resident && ob.flow == AuthOnboardingFlow.login;

  bool _isResidentOtpFlow(AuthOnboardingState ob) =>
      ob.role == UserRole.resident;

  String? _validateResidentPhoneInput(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 11 || !digits.startsWith('0')) {
      return 'phone_invalid_eleven_digits';
    }
    if (PhoneUtils.normalizeTrPhone(digits) == null) {
      return 'phone_invalid';
    }
    return null;
  }

  String _formatOtpResendTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _validationMessage(BuildContext context, String key) {
    final t = context.t;
    switch (key) {
      case 'identifier_required':
        return t.features.auth.onboarding.identifierRequired;
      case 'phone_invalid_eleven_digits':
        return t.features.auth.onboarding.phoneInvalidElevenDigits;
      case 'email_invalid':
        return t.validation.emailInvalid;
      case 'phone_invalid':
        return t.features.auth.onboarding.phoneInvalid;
      case 'password_required':
        return t.validation.passwordRequired;
      case 'password_too_short':
        return t.validation.passwordTooShort;
      case 'password_too_long':
        return t.validation.passwordTooLong;
      case 'password_alphanumeric_required':
        return t.validation.passwordAlphanumericRequired;
      case 'name_required':
      case 'name_too_short':
      case 'name_invalid':
        return t.features.auth.onboarding.residentNameRequired;
      default:
        return t.features.auth.errorOccurred;
    }
  }

  String _identifierForState(AuthOnboardingState ob) {
    if (ob.email != null && ob.email!.isNotEmpty) return ob.email!;
    if (ob.phone != null && ob.phone!.isNotEmpty) return '0${ob.phone}';
    return _identifierController.text.trim();
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].isEmpty) return email;
    final local = parts[0];
    final head = local.length <= 2 ? local[0] : local.substring(0, 2);
    return '$head***@${parts[1]}';
  }

  void _goDashboard(UserEntity user) {
    final path = user.role == UserRole.manager
        ? '/manager-dashboard'
        : '/resident-dashboard';
    context.go(path);
  }

  Future<void> _onContinue() async {
    final ob = ref.read(authOnboardingProvider);
    final onboarding = ref.read(authOnboardingProvider.notifier);
    final auth = ref.read(authStateProvider.notifier);

    switch (ob.currentStepId) {
      case AuthOnboardingStepId.role:
        return;

      case AuthOnboardingStepId.managerExperience:
      case AuthOnboardingStepId.residentExperience:
        return;

      case AuthOnboardingStepId.name:
        if (_isResidentJoin(ob) && ob.joinOtpVerified) {
          await _handleResidentJoinNameStep(ob, onboarding, auth);
        } else {
          _handleManagerNameStep(ob, onboarding);
        }
        return;

      case AuthOnboardingStepId.identifier:
        await _handleIdentifierStep(ob, onboarding, auth);
        return;

      case AuthOnboardingStepId.credentials:
        await _handleCredentialsStep(ob, onboarding, auth);
        return;

      case AuthOnboardingStepId.contact:
        await _handleContactStep(ob, onboarding, auth);
        return;

      case AuthOnboardingStepId.verification:
        await _handleVerificationStep(ob, onboarding, auth);
        return;

      case AuthOnboardingStepId.invite:
        await _handleInviteStep(ob, onboarding, auth);
        return;

      case AuthOnboardingStepId.features:
        onboarding.goToComplete();
        return;

      case AuthOnboardingStepId.complete:
        final user = ref.read(authStateProvider).user;
        if (user != null) {
          _goDashboard(user);
        } else if (ob.role == UserRole.manager &&
            ob.managerType == ManagerType.primary) {
          context.go('/manager-dashboard/add-building');
        } else {
          onboarding.goNextStep();
        }
        return;
    }
  }

  void _handleManagerNameStep(
    AuthOnboardingState ob,
    AuthOnboardingNotifier onboarding,
  ) {
    final name = _nameController.text.trim();
    final nameError = InputValidators.validateName(name);
    if (nameError != null) {
      ref.read(toastProvider.notifier).show(
            _validationMessage(context, nameError),
            type: ToastType.error,
          );
      return;
    }
    onboarding.setName(name);
    _identifierController.clear();
    onboarding.goNextStep();
  }

  Future<void> _handleResidentJoinNameStep(
    AuthOnboardingState ob,
    AuthOnboardingNotifier onboarding,
    AuthNotifier auth,
  ) async {
    final name = _nameController.text.trim();
    final nameError = InputValidators.validateName(name);
    if (nameError != null) {
      ref.read(toastProvider.notifier).show(
            _validationMessage(context, nameError),
            type: ToastType.error,
          );
      return;
    }
    final phone = ob.phone;
    if (phone == null) return;
    onboarding.setName(name);

    if (ob.hasPrefetchedInvite) {
      try {
        final user = await auth.completeResidentJoinAndAuthenticate(
          phone: phone,
          name: name,
          inviteCode: ob.inviteCode!,
          ref: ref,
        );
        _goDashboard(user);
      } catch (_) {}
      return;
    }

    onboarding.goNextStep();
  }

  Future<void> _handleIdentifierStep(
    AuthOnboardingState ob,
    AuthOnboardingNotifier onboarding,
    AuthNotifier auth,
  ) async {
    final raw = _identifierController.text.trim();
    final identifierError = InputValidators.validateLoginIdentifier(raw);
    if (identifierError != null) {
      ref.read(toastProvider.notifier).show(
            _validationMessage(context, identifierError),
            type: ToastType.error,
          );
      return;
    }
    onboarding.setIdentifierFromRaw(raw);
    try {
      await auth.checkManagerIdentifier(
        rawIdentifier: raw,
        isRegister: ob.flow == AuthOnboardingFlow.register,
      );
      _passwordController.clear();
      _confirmPasswordController.clear();
      onboarding.goNextStep();
    } catch (_) {
      // Hata ref.listen(authStateProvider) ile tek toast olarak gösterilir.
    }
  }

  Future<void> _handleCredentialsStep(
    AuthOnboardingState ob,
    AuthOnboardingNotifier onboarding,
    AuthNotifier auth,
  ) async {
    final password = _passwordController.text;
    final identifier = _identifierForState(ob);

    if (ob.flow == AuthOnboardingFlow.register) {
      final passwordError = InputValidators.validatePassword(password);
      if (passwordError != null) {
        ref.read(toastProvider.notifier).show(
              _validationMessage(context, passwordError),
              type: ToastType.error,
            );
        return;
      }
      final confirm = _confirmPasswordController.text;
      if (password != confirm) {
        ref.read(toastProvider.notifier).show(
              context.t.features.auth.passwordsDoNotMatch,
              type: ToastType.error,
            );
        return;
      }
      final name = ob.name ?? _nameController.text.trim();
      await auth.registerAndLogin(
        name: name,
        rawIdentifier: identifier,
        password: password,
        ref: ref,
      );
      final user = ref.read(authStateProvider).user;
      if (user != null) _goDashboard(user);
      return;
    }

    if (password.isEmpty) {
      ref.read(toastProvider.notifier).show(
            context.t.features.auth.passwordRequired,
            type: ToastType.error,
          );
      return;
    }

    await auth.submitLogin(identifier, password, ref);
    final user = ref.read(authStateProvider).user;
    if (user != null) _goDashboard(user);
  }

  Future<void> _handleContactStep(
    AuthOnboardingState ob,
    AuthOnboardingNotifier onboarding,
    AuthNotifier auth,
  ) async {
    if (_isResidentOtpFlow(ob)) {
      final raw = _contactController.text.trim();
      final phoneError = _validateResidentPhoneInput(raw);
      if (phoneError != null) {
        ref.read(toastProvider.notifier).show(
              _validationMessage(context, phoneError),
              type: ToastType.error,
            );
        return;
      }
      final phone = PhoneUtils.normalizeTrPhone(raw)!;
      onboarding.setContactValue(phone);
      try {
        final exists = await auth.checkResidentPhoneExists(phone);
        if (exists) {
          onboarding.applyResidentLoginFlow();
          await auth.sendOtp(phone: phone, purpose: 'resident_login');
        } else {
          onboarding.applyResidentJoinFlow();
          final invite = ref.read(authOnboardingProvider).inviteCode;
          await auth.sendOtp(
            phone: phone,
            purpose: 'resident_join',
            payload: invite != null && invite.isNotEmpty
                ? {'inviteCode': invite}
                : null,
          );
        }
        onboarding.markOtpSent();
        _startOtpTimer();
        onboarding.goNextStep();
      } catch (_) {}
      return;
    }

    final raw = _contactController.text.trim();
    if (ob.contact == AuthContactChannel.phone) {
      final phone = PhoneUtils.normalizeTrPhone(raw);
      if (phone == null) {
        ref.read(toastProvider.notifier).show(
              context.t.features.auth.onboarding.phoneInvalid,
              type: ToastType.error,
            );
        return;
      }
      onboarding.setContactValue(phone);
      onboarding.refreshVisibleStepsForFlow();
      if (ob.flow == AuthOnboardingFlow.login ||
          ob.flow == AuthOnboardingFlow.legacyLogin) {
        onboarding.refreshVisibleStepsForFlow();
      }
      try {
        await auth.sendOtp(phone: phone, purpose: _otpPurpose(ob));
        onboarding.markOtpSent();
        _startOtpTimer();
        onboarding.goNextStep();
      } catch (_) {}
    } else {
      if (!InputValidators.emailRegex.hasMatch(raw)) {
        ref.read(toastProvider.notifier).show(
              context.t.validation.emailInvalid,
              type: ToastType.error,
            );
        return;
      }
      onboarding.setContactValue(raw);
      onboarding.refreshVisibleStepsForFlow();
      if (ob.flow == AuthOnboardingFlow.legacyLogin) {
        onboarding.goNextStep();
        return;
      }
      try {
        await auth.sendOtp(email: raw, purpose: _otpPurpose(ob));
        onboarding.markOtpSent();
        _startOtpTimer();
        onboarding.goNextStep();
      } catch (_) {}
    }
  }

  Future<void> _handleVerificationStep(
    AuthOnboardingState ob,
    AuthOnboardingNotifier onboarding,
    AuthNotifier auth,
  ) async {
    if (_usesOtpChannel(ob)) {
      final phone = ob.phone;
      final email = ob.email;
      final code = ob.otpCode;
      if ((phone == null && email == null) || code == null || code.length != 6) {
        ref.read(toastProvider.notifier).show(
              context.t.features.auth.onboarding.otpInvalid,
              type: ToastType.error,
            );
        return;
      }
      if (_isResidentJoin(ob)) {
        try {
          final requireName = await auth.verifyResidentJoinOtp(
            phone: phone!,
            code: code,
            inviteCode: ob.inviteCode,
          );
          if (requireName) {
            onboarding.markJoinOtpVerified();
            onboarding.goNextStep();
          }
        } catch (_) {}
        return;
      }
      if (_isResidentLogin(ob)) {
        try {
          final user = await auth.verifyOtpAndAuthenticate(
            phone: phone,
            email: email,
            code: code,
            purpose: 'resident_login',
            ref: ref,
          );
          _goDashboard(user);
        } catch (_) {}
        return;
      }
      if (ob.flow == AuthOnboardingFlow.register &&
          ob.role == UserRole.manager) {
        final password = _passwordController.text;
        if (password.isEmpty) {
          ref.read(toastProvider.notifier).show(
                context.t.features.auth.passwordRequired,
                type: ToastType.error,
              );
          return;
        }
        try {
          await auth.verifyOtpAndAuthenticate(
            phone: phone,
            email: email,
            code: code,
            purpose: 'manager_register',
            password: password,
            name: _nameController.text.trim().isNotEmpty
                ? _nameController.text.trim()
                : null,
            ref: ref,
          );
          onboarding.goNextStep();
          return;
        } catch (_) {
          return;
        }
      }
      try {
        final user = await auth.verifyOtpAndAuthenticate(
          phone: phone,
          email: email,
          code: code,
          purpose: _otpPurpose(ob),
          ref: ref,
        );
        if (ob.isFirstTimeSetup) {
          onboarding.goNextStep();
        } else {
          _goDashboard(user);
        }
      } catch (_) {}
      return;
    }

    final password = _passwordController.text;
    if (ob.flow == AuthOnboardingFlow.register) {
      final confirm = _confirmPasswordController.text;
      if (password != confirm) {
        ref.read(toastProvider.notifier).show(
              context.t.features.auth.passwordsDoNotMatch,
              type: ToastType.error,
            );
        return;
      }
      final email = ob.email;
      if (email == null || email.isEmpty) {
        return;
      }
      try {
        final name = _nameController.text.trim();
        await auth.register(
          email,
          password,
          name.isNotEmpty ? name : email.split('@').first,
          ob.phone,
        );
        await auth.login(email, password, ref);
        if (ob.isFirstTimeSetup) {
          onboarding.goNextStep();
        } else {
          final user = ref.read(authStateProvider).user;
          if (user != null) _goDashboard(user);
        }
      } catch (_) {}
      return;
    }

    final identifier = ob.email ?? '';
    await auth.submitLogin(identifier, password, ref);
    final user = ref.read(authStateProvider).user;
    if (user != null && !ob.isFirstTimeSetup) {
      _goDashboard(user);
    }
  }

  Future<void> _handleInviteStep(
    AuthOnboardingState ob,
    AuthOnboardingNotifier onboarding,
    AuthNotifier auth,
  ) async {
    if (ob.role == UserRole.manager && ob.managerType == ManagerType.primary) {
      onboarding.goToFeatures();
      return;
    }

    if (ob.role == UserRole.resident && ob.flow == AuthOnboardingFlow.join) {
      final invite = _inviteController.text.trim();
      if (invite.isEmpty) {
        ref.read(toastProvider.notifier).show(
              context.t.features.auth.onboarding.inviteInvalid,
              type: ToastType.error,
            );
        return;
      }
      final phone = ob.phone;
      final name = ob.name ?? _nameController.text.trim();
      if (phone == null || name.isEmpty) return;
      try {
        final label = await auth.validateInviteCode(invite);
        onboarding.setInviteCode(invite);
        onboarding.setInviteLabel(label);
        final user = await auth.completeResidentJoinAndAuthenticate(
          phone: phone,
          name: name,
          inviteCode: invite,
          ref: ref,
        );
        if (!mounted) return;
        _goDashboard(user);
      } catch (_) {
        if (!mounted) return;
        ref.read(toastProvider.notifier).show(
              context.t.features.auth.onboarding.inviteInvalid,
              type: ToastType.error,
            );
      }
      return;
    }

    final invite = _inviteController.text.trim();
    if (invite.isEmpty) {
      ref.read(toastProvider.notifier).show(
            context.t.features.auth.onboarding.inviteInvalid,
            type: ToastType.error,
          );
      return;
    }
    onboarding.setInviteFields(inviteCode: invite);
    onboarding.goToFeatures();
  }

  @override
  Widget build(BuildContext context) {
    final ob = ref.watch(authOnboardingProvider);
    final authState = ref.watch(authStateProvider);

    ref.listen(authOnboardingProvider.select((s) => s.currentStepId), (
      prev,
      next,
    ) {
      if (prev != null && prev != next) {
        ref.read(authStateProvider.notifier).dismissError();
      }
    });

    ref.listen(authStateProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ref.read(toastProvider.notifier).show(
              next.error!,
              type: ToastType.error,
            );
      }
    });

    final stepPadding = ob.currentStepId == AuthOnboardingStepId.role
        ? const EdgeInsets.fromLTRB(
            AppSizes.dashboardScreenPaddingHorizontal,
            AppSizes.spacingL,
            AppSizes.dashboardScreenPaddingHorizontal,
            0,
          )
        : AppSizes.screenBodyScrollPadding;

    return AuthBackHandler(
      child: AuthScreenShell(
        showBrandHeader: false,
        wrapInCard: false,
        scrollable: false,
        padding: EdgeInsets.zero,
        leading: null,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          fit: StackFit.expand,
          children: [
            const Align(
              alignment: Alignment.bottomCenter,
              child: OnboardingBuildingsBackdrop(),
            ),
            Padding(
              padding: stepPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OnboardingCompactHeader(
                    size: ob.currentStepId == AuthOnboardingStepId.role
                        ? AuthBrandMarkSize.hero
                        : AuthBrandMarkSize.standard,
                    showSubtitle:
                        ob.currentStepId == AuthOnboardingStepId.role,
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: onboardingStepTransitionDuration,
                            switchInCurve: Curves.easeInOutCubic,
                            switchOutCurve: Curves.easeInOutCubic,
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                fit: StackFit.expand,
                                alignment: Alignment.topCenter,
                                children: [
                                  ...previousChildren,
                                  ?currentChild,
                                ],
                              );
                            },
                            transitionBuilder: (child, animation) {
                              return onboardingStepTransition(child, animation);
                            },
                            child: KeyedSubtree(
                              key: ValueKey(ob.currentStepId),
                              child: SizedBox.expand(
                                child: _buildStep(
                                  context,
                                  ob,
                                  authState.isLoading,
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildStepActions(context, ob, authState.isLoading),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepActions(
    BuildContext context,
    AuthOnboardingState ob,
    bool isLoading,
  ) {
    final tOb = context.t.features.auth.onboarding;
    final tAuth = context.t.features.auth;
    final onboarding = ref.read(authOnboardingProvider.notifier);

    switch (ob.currentStepId) {
      case AuthOnboardingStepId.role:
        return const SizedBox.shrink();

      case AuthOnboardingStepId.managerExperience:
      case AuthOnboardingStepId.residentExperience:
        return OnboardingStepActions(
          onBack: isLoading ? null : onboarding.goBack,
          backLabel: tOb.backButton,
          isLoading: isLoading,
        );

      case AuthOnboardingStepId.name:
        final isResidentWelcome = _isResidentJoin(ob) && ob.joinOtpVerified;
        final primaryLabel = isResidentWelcome
            ? (ob.hasPrefetchedInvite
                ? tOb.residentCompleteJoinButton
                : tOb.continueButton)
            : tOb.continueButton;
        return OnboardingStepActions(
          primaryLabel: primaryLabel,
          onPrimary: _onContinue,
          onBack: isLoading ? null : onboarding.goBack,
          backLabel: tOb.backButton,
          isLoading: isLoading,
        );

      case AuthOnboardingStepId.identifier:
        return OnboardingStepActions(
          primaryLabel: tOb.continueButton,
          onPrimary: _onContinue,
          onBack: isLoading ? null : onboarding.goBack,
          backLabel: tOb.backButton,
          isLoading: isLoading,
        );

      case AuthOnboardingStepId.credentials:
        final isRegister = ob.flow == AuthOnboardingFlow.register;
        return OnboardingStepActions(
          primaryLabel: isRegister
              ? tOb.managerCreateAccountButton
              : tOb.managerLoginButton,
          onPrimary: _onContinue,
          onBack: isLoading ? null : onboarding.goBack,
          backLabel: tOb.backButton,
          isLoading: isLoading,
        );

      case AuthOnboardingStepId.contact:
        if (_isResidentOtpFlow(ob)) {
          return OnboardingStepActions(
            primaryLabel: tOb.residentSendCodeButton,
            onPrimary: _onContinue,
            onBack: isLoading ? null : onboarding.goBack,
            backLabel: tOb.backButton,
            isLoading: isLoading,
          );
        }
        return OnboardingStepActions(
          primaryLabel: tOb.continueButton,
          onPrimary: _onContinue,
          isLoading: isLoading,
        );

      case AuthOnboardingStepId.verification:
        if (_usesOtpChannel(ob) && _isResidentOtpFlow(ob)) {
          return OnboardingStepActions(
            primaryLabel: tOb.continueButton,
            onPrimary: _onContinue,
            onBack: isLoading ? null : onboarding.goBack,
            backLabel: tOb.backButton,
            isLoading: isLoading,
          );
        }
        if (_usesOtpChannel(ob)) {
          return OnboardingStepActions(
            primaryLabel: tOb.continueButton,
            onPrimary: _onContinue,
            isLoading: isLoading,
          );
        }
        final isRegisterFlow = ob.flow == AuthOnboardingFlow.register;
        return OnboardingStepActions(
          primaryLabel:
              isRegisterFlow ? tOb.continueButton : tAuth.login,
          onPrimary: _onContinue,
          isLoading: isLoading,
        );

      case AuthOnboardingStepId.invite:
        if (_isResidentJoin(ob)) {
          return OnboardingStepActions(
            primaryLabel: tOb.residentJoinButton,
            onPrimary: _onContinue,
            onBack: isLoading ? null : onboarding.goBack,
            backLabel: tOb.backButton,
            isLoading: isLoading,
          );
        }
        return OnboardingStepActions(
          primaryLabel: tOb.continueButton,
          onPrimary: _onContinue,
          isLoading: isLoading,
        );

      case AuthOnboardingStepId.features:
        return OnboardingStepActions(
          primaryLabel: tOb.continueButton,
          onPrimary: _onContinue,
          isLoading: isLoading,
        );

      case AuthOnboardingStepId.complete:
        return OnboardingStepActions(
          primaryLabel: tOb.goToPanel,
          onPrimary: _onContinue,
          isLoading: isLoading,
          primaryTrailing: const Icon(Icons.arrow_forward, size: 20),
        );
    }
  }

  Widget _buildStep(
    BuildContext context,
    AuthOnboardingState ob,
    bool isLoading,
  ) {
    final tOb = context.t.features.auth.onboarding;
    final onboarding = ref.read(authOnboardingProvider.notifier);

    switch (ob.currentStepId) {
      case AuthOnboardingStepId.role:
        return OnboardingRoleStep(
          title: tOb.step1Title,
          managerLabel: tOb.step1ManagerOption,
          residentLabel: tOb.step1ResidentOption,
          selectedRole: ob.role,
          enabled: !isLoading,
          onManagerTap: isLoading ? () {} : onboarding.pickManagerRole,
          onResidentTap: isLoading ? () {} : onboarding.pickResidentRole,
        );

      case AuthOnboardingStepId.managerExperience:
        return OnboardingFixedChoiceLayout(
          title: tOb.managerExperienceTitle,
          subtitle: tOb.managerExperienceSubtitle,
          choices: OnboardingRoleCards(
            selectedRole: null,
            managerLabel: tOb.managerReturningOption,
            residentLabel: tOb.managerFirstTimeOption,
            enabled: !isLoading,
            onManagerTap: isLoading ? () {} : onboarding.startManagerReturning,
            onResidentTap: isLoading ? () {} : onboarding.startManagerFirstTime,
          ),
        );

      case AuthOnboardingStepId.residentExperience:
        return OnboardingFixedChoiceLayout(
          title: tOb.residentExperienceTitle,
          subtitle: tOb.residentExperienceSubtitle,
          choices: OnboardingRoleCards(
            selectedRole: null,
            managerLabel: tOb.residentReturningOption,
            residentLabel: tOb.residentInviteOption,
            enabled: !isLoading,
            onManagerTap: isLoading ? () {} : onboarding.startResidentReturning,
            onResidentTap: isLoading ? () {} : onboarding.startResidentWithInvite,
          ),
        );

      case AuthOnboardingStepId.name:
        if (_isResidentJoin(ob) && ob.joinOtpVerified) {
          return OnboardingStepScaffold(
            title: tOb.residentWelcomeTitle,
            subtitle: tOb.residentWelcomeSubtitle,
            body: TextField(
              controller: _nameController,
              enabled: !isLoading,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _onContinue(),
              decoration: InputDecoration(
                labelText: context.t.features.auth.name,
                hintText: context.t.features.auth.nameHint,
              ),
            ),
          );
        }
        if (_nameController.text.isEmpty && (ob.name?.isNotEmpty ?? false)) {
          _nameController.text = ob.name!;
        }
        return OnboardingStepScaffold(
          title: tOb.managerNameTitle,
          subtitle: tOb.managerNameSubtitle,
          body: TextField(
            controller: _nameController,
            enabled: !isLoading,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _onContinue(),
            decoration: InputDecoration(
              labelText: context.t.features.auth.name,
              hintText: context.t.features.auth.nameHint,
            ),
          ),
        );

      case AuthOnboardingStepId.identifier:
        return OnboardingStepScaffold(
          title: tOb.managerIdentifierTitle,
          subtitle: tOb.managerIdentifierSubtitle,
          body: OnboardingIdentifierField(
            controller: _identifierController,
            enabled: !isLoading,
            labelText: tOb.managerIdentifierLabel,
            hintText: tOb.managerIdentifierHint,
            phoneNote: tOb.managerIdentifierPhoneNote,
            onSubmitted: _onContinue,
          ),
        );

      case AuthOnboardingStepId.credentials:
        final isRegister = ob.flow == AuthOnboardingFlow.register;
        return OnboardingStepScaffold(
          title: isRegister
              ? tOb.managerRegisterPasswordTitle
              : tOb.managerLoginPasswordTitle,
          subtitle: isRegister ? tOb.managerRegisterPasswordSubtitle : null,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PasswordField(
                controller: _passwordController,
                labelText: context.t.features.auth.password,
                hintText: context.t.features.auth.passwordHint,
                enabled: !isLoading,
                obscureText: _obscurePassword,
                onToggleVisibility: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              if (isRegister) ...[
                const SizedBox(height: AppSizes.spacingM),
                PasswordField(
                  controller: _confirmPasswordController,
                  labelText: context.t.features.auth.confirmPassword,
                  hintText: context.t.features.auth.passwordHint,
                  enabled: !isLoading,
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                ),
              ],
            ],
          ),
        );

      case AuthOnboardingStepId.contact:
        if (_isResidentOtpFlow(ob)) {
          return OnboardingStepScaffold(
            title: tOb.residentPhoneTitle,
            subtitle: tOb.residentPhoneSubtitle,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PhoneInputRow(
                  enabled: !isLoading,
                  initialPhone: _contactController.text.isNotEmpty
                      ? _contactController.text
                      : (ob.phone != null && ob.phone!.length == 10
                          ? '0${ob.phone}'
                          : ob.phone),
                  onChanged: (digits) {
                    _contactController.text = digits;
                  },
                ),
                const SizedBox(height: AppSizes.spacingS),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSizes.spacingXS),
                    Expanded(
                      child: Text(
                        tOb.residentPhoneNote,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return AuthStepScaffold(
          title: tOb.step2Title,
          subtitle: tOb.step2Subtitle,
          primaryLabel: tOb.continueButton,
          isLoading: isLoading,
          onPrimary: _onContinue,
          body: Column(
            children: [
              OnboardingSegmentTabs(
                isSecondSelected: ob.contact == AuthContactChannel.email,
                firstLabel: context.t.features.auth.phone,
                secondLabel: context.t.features.auth.email,
                onFirstTap: () =>
                    onboarding.setContactChannel(AuthContactChannel.phone),
                onSecondTap: () =>
                    onboarding.setContactChannel(AuthContactChannel.email),
                enabled: !isLoading,
              ),
              const SizedBox(height: AppSizes.spacingM),
              TextField(
                controller: _contactController,
                keyboardType: ob.contact == AuthContactChannel.phone
                    ? TextInputType.phone
                    : TextInputType.emailAddress,
                maxLength: ob.contact == AuthContactChannel.phone ? 10 : null,
                inputFormatters: ob.contact == AuthContactChannel.phone
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : null,
                decoration: InputDecoration(
                  hintText: ob.contact == AuthContactChannel.phone
                      ? context.t.features.auth.phoneHint
                      : context.t.features.auth.emailHint,
                  prefixIcon: ob.contact == AuthContactChannel.phone
                      ? Padding(
                          padding: const EdgeInsets.only(
                            left: AppSizes.spacingM,
                            right: AppSizes.spacingS,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '+90',
                                style: AppTypography.body1.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 24,
                                margin: const EdgeInsets.only(
                                  left: AppSizes.spacingS,
                                ),
                                color: AppColors.border,
                              ),
                            ],
                          ),
                        )
                      : const Icon(Icons.email_outlined),
                  prefixIconConstraints: ob.contact == AuthContactChannel.phone
                      ? const BoxConstraints(minWidth: 72)
                      : null,
                  counterText:
                      ob.contact == AuthContactChannel.phone ? '' : null,
                ),
              ),
            ],
          ),
          footer: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSizes.spacingXS),
              Flexible(
                child: Text(
                  tOb.secureNote,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );

      case AuthOnboardingStepId.verification:
        if (_usesOtpChannel(ob)) {
          if (_isResidentOtpFlow(ob)) {
            final otpSubtitle = ob.phone != null
                ? tOb.step3OtpSubtitlePhone.replaceAll(
                    '{phone}',
                    PhoneUtils.maskDisplay(ob.phone!),
                  )
                : tOb.residentOtpSubtitle;
            return OnboardingStepScaffold(
              title: tOb.step3OtpTitle,
              subtitle: otpSubtitle,
              body: Column(
                children: [
                  OtpInputRow(
                    enabled: !isLoading,
                    onChanged: onboarding.setOtpCode,
                    onCompleted: (_) => _onContinue(),
                  ),
                  if (ApiConstants.isLocalBackend) ...[
                    const SizedBox(height: AppSizes.spacingS),
                    Text(
                      tOb.step3DevOtpHint,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppSizes.spacingM),
                  _ResidentOtpResendRow(
                    prompt: tOb.residentResendPrompt,
                    linkLabel: ob.otpResendSeconds > 0
                        ? tOb.step3ResendOtp.replaceAll(
                            '{time}',
                            _formatOtpResendTime(ob.otpResendSeconds),
                          )
                        : tOb.residentResendLink,
                    enabled: ob.otpResendSeconds <= 0 && !isLoading,
                    onResend: () => _resendOtp(ob, onboarding),
                  ),
                ],
              ),
            );
          }
          final showManagerRegPassword = ob.flow == AuthOnboardingFlow.register &&
              ob.role == UserRole.manager;
          final isResidentJoin = _isResidentJoin(ob);
          final otpSubtitle = isResidentJoin
              ? tOb.residentOtpSubtitle
              : ob.phone != null
                  ? tOb.step3OtpSubtitlePhone.replaceAll(
                      '{phone}',
                      '+90 ${PhoneUtils.maskDisplay(ob.phone!)}',
                    )
                  : ob.email != null
                      ? tOb.step3OtpSubtitleEmail.replaceAll(
                          '{email}',
                          _maskEmail(ob.email!),
                        )
                      : tOb.step3OtpSubtitle;
          return AuthStepScaffold(
            title: tOb.step3OtpTitle,
            subtitle: otpSubtitle,
            primaryLabel: tOb.continueButton,
            isLoading: isLoading,
            onPrimary: _onContinue,
            body: Column(
              children: [
                OtpInputRow(
                  enabled: !isLoading,
                  onChanged: onboarding.setOtpCode,
                  onCompleted: (_) => _onContinue(),
                ),
                if (ApiConstants.isLocalBackend) ...[
                  const SizedBox(height: AppSizes.spacingS),
                  Text(
                    tOb.step3DevOtpHint,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (showManagerRegPassword) ...[
                  const SizedBox(height: AppSizes.spacingM),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: context.t.features.auth.name,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: context.t.features.auth.password,
                    ),
                  ),
                ],
                if (!isResidentJoin) ...[
                  const SizedBox(height: AppSizes.spacingM),
                  AuthTextButton(
                    label: ob.otpResendSeconds > 0
                        ? tOb.step3ResendOtp.replaceAll(
                            '{time}',
                            _formatOtpResendTime(ob.otpResendSeconds),
                          )
                        : tOb.step3ResendOtpReady,
                    onTap: ob.otpResendSeconds > 0 || isLoading
                        ? null
                        : () => _resendOtp(ob, onboarding),
                  ),
                ],
              ],
            ),
            footer: isResidentJoin
                ? _ResidentOtpResendRow(
                    prompt: tOb.residentResendPrompt,
                    linkLabel: ob.otpResendSeconds > 0
                        ? tOb.step3ResendOtp.replaceAll(
                            '{time}',
                            _formatOtpResendTime(ob.otpResendSeconds),
                          )
                        : tOb.residentResendLink,
                    enabled: ob.otpResendSeconds <= 0 && !isLoading,
                    onResend: () => _resendOtp(ob, onboarding),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSizes.spacingXS),
                      Flexible(
                        child: Text(
                          tOb.step3SecureVerify,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
          );
        }
        return AuthStepScaffold(
          title: ob.flow == AuthOnboardingFlow.register
              ? tOb.step3RegisterPasswordTitle
              : tOb.step3PasswordTitle,
          primaryLabel: ob.flow == AuthOnboardingFlow.register
              ? tOb.continueButton
              : context.t.features.auth.login,
          isLoading: isLoading,
          onPrimary: _onContinue,
          body: Column(
            children: [
              if (ob.flow == AuthOnboardingFlow.register) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: context.t.features.auth.name,
                    hintText: context.t.features.auth.nameHint,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingM),
              ],
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: _obscurePassword,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: context.t.features.auth.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                  ),
                ),
              ),
              if (ob.flow == AuthOnboardingFlow.register) ...[
                const SizedBox(height: AppSizes.spacingM),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: context.t.features.auth.confirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );

      case AuthOnboardingStepId.invite:
        final isManager = ob.role == UserRole.manager;
        final isResidentJoin = _isResidentJoin(ob);
        if (isResidentJoin) {
          return OnboardingStepScaffold(
            title: tOb.step4InviteTitle,
            subtitle: tOb.residentInviteSubtitle,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InviteCodeInputRow(
                  enabled: !isLoading,
                  initialCode: ob.inviteCode,
                  onChanged: (code) {
                    _inviteController.text = code;
                    onboarding.setInviteCode(code);
                  },
                ),
                if (ob.inviteLabel != null) ...[
                  const SizedBox(height: AppSizes.spacingS),
                  Text(
                    tOb.step4InviteValidated.replaceAll(
                      '{label}',
                      ob.inviteLabel!,
                    ),
                    style: AppTypography.body2.copyWith(color: AppColors.success),
                  ),
                ],
              ],
            ),
          );
        }
        return AuthStepScaffold(
          title: isManager ? tOb.step4ManagerInviteTitle : tOb.step4InviteTitle,
          subtitle: isManager
              ? tOb.step4ManagerInviteSubtitle
              : isResidentJoin
                  ? tOb.residentInviteSubtitle
                  : tOb.step4InviteSubtitle,
          primaryLabel: isResidentJoin
              ? tOb.residentJoinButton
              : tOb.continueButton,
          isLoading: isLoading,
          onPrimary: _onContinue,
          body: Column(
            children: [
              if (!isManager && !isResidentJoin) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: context.t.features.auth.name,
                    hintText: context.t.features.auth.nameHint,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingM),
              ],
              TextField(
                controller: _inviteController,
                enabled: !isLoading,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: isResidentJoin
                      ? tOb.residentInviteCodeLabel
                      : null,
                  hintText: isResidentJoin
                      ? tOb.residentInviteCodeHint
                      : context.t.features.auth.inviteCodeHint,
                  prefixIcon: const Icon(Icons.card_giftcard_outlined),
                ),
              ),
              if (!isResidentJoin) ...[
                const SizedBox(height: AppSizes.spacingM),
                OnboardingInfoBanner(
                  message: isManager
                      ? tOb.step4ManagerInviteInfo
                      : tOb.step4InviteHint,
                ),
              ],
              if (ob.inviteLabel != null) ...[
                const SizedBox(height: AppSizes.spacingS),
                Text(
                  tOb.step4InviteValidated.replaceAll(
                    '{label}',
                    ob.inviteLabel!,
                  ),
                  style: AppTypography.body2.copyWith(color: AppColors.success),
                ),
              ],
            ],
          ),
          secondary: isManager
              ? Column(
                  children: [
                    Text(
                      tOb.step4ManagerPrimaryHint,
                      style: AppTypography.caption,
                      textAlign: TextAlign.center,
                    ),
                    AuthTextButton(
                      label: tOb.step4ManagerPrimaryLink,
                      onTap: isLoading ? null : onboarding.setManagerPrimary,
                    ),
                  ],
                )
              : null,
        );

      case AuthOnboardingStepId.features:
        final isManager = ob.role == UserRole.manager;
        return AuthStepScaffold(
          title: isManager ? tOb.step5Title : tOb.step5ResidentTitle,
          subtitle: isManager
              ? tOb.step5ManagerSubtitle
              : tOb.step5ResidentSubtitle,
          primaryLabel: tOb.continueButton,
          isLoading: isLoading,
          onPrimary: _onContinue,
          body: Column(
            children: _featureRows(context, isManager),
          ),
        );

      case AuthOnboardingStepId.complete:
        final isManager = ob.role == UserRole.manager;
        return AuthStepScaffold(
          title: isManager ? tOb.step6ManagerTitle : tOb.step6ResidentTitle,
          subtitle: isManager
              ? tOb.step6ManagerSubtitle
              : tOb.step6ResidentSubtitle,
          primaryLabel: tOb.goToPanel,
          isLoading: isLoading,
          onPrimary: _onContinue,
          centerBody: true,
          primaryTrailing: const Icon(Icons.arrow_forward, size: 20),
          body: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: AppColors.success,
              size: 56,
            ),
          ),
        );
    }
  }

  List<Widget> _featureRows(BuildContext context, bool isManager) {
    final tOb = context.t.features.auth.onboarding;
    final items = isManager
        ? [
            (
              Icons.campaign_outlined,
              tOb.step5ManagerAnnounceTitle,
              tOb.step5ManagerAnnounceBody,
            ),
            (
              Icons.account_balance_wallet_outlined,
              tOb.step5ManagerDuesTitle,
              tOb.step5ManagerDuesBody,
            ),
            (
              Icons.people_outline,
              tOb.step5ManagerResidentsTitle,
              tOb.step5ManagerResidentsBody,
            ),
            (
              Icons.bar_chart_outlined,
              tOb.step5ManagerReportsTitle,
              tOb.step5ManagerReportsBody,
            ),
          ]
        : [
            (
              Icons.payments_outlined,
              tOb.step5ResidentDuesTitle,
              tOb.step5ResidentDuesBody,
            ),
            (
              Icons.receipt_long_outlined,
              tOb.step5ResidentDekontTitle,
              tOb.step5ResidentDekontBody,
            ),
            (
              Icons.build_outlined,
              tOb.step5ResidentTicketsTitle,
              tOb.step5ResidentTicketsBody,
            ),
            (
              Icons.notifications_outlined,
              tOb.step5ResidentNotifyTitle,
              tOb.step5ResidentNotifyBody,
            ),
          ];
    return items
        .map(
          (e) => OnboardingFeatureTile(
            icon: e.$1,
            title: e.$2,
            description: e.$3,
          ),
        )
        .toList();
  }

  Future<void> _resendOtp(
    AuthOnboardingState ob,
    AuthOnboardingNotifier onboarding,
  ) async {
    final phone = ob.phone;
    final email = ob.email;
    if (phone == null && email == null) return;
    try {
      await ref.read(authStateProvider.notifier).sendOtp(
            phone: phone,
            email: email,
            purpose: _otpPurpose(ob),
            payload: _isResidentJoin(ob) &&
                    ob.inviteCode != null &&
                    ob.inviteCode!.isNotEmpty
                ? {'inviteCode': ob.inviteCode}
                : null,
          );
      onboarding.markOtpSent();
      _startOtpTimer();
    } catch (_) {}
  }
}

class _ResidentOtpResendRow extends StatelessWidget {
  const _ResidentOtpResendRow({
    required this.prompt,
    required this.linkLabel,
    required this.enabled,
    required this.onResend,
  });

  final String prompt;
  final String linkLabel;
  final bool enabled;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.refresh,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSizes.spacingXS),
        Flexible(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '$prompt ',
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: enabled ? onResend : null,
                child: Text(
                  linkLabel,
                  style: AppTypography.body2.copyWith(
                    color: enabled
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Query parametrelerinden onboarding başlangıç durumu.
AuthOnboardingFlow? parseAuthFlow(String? raw) {
  switch (raw) {
    case 'join':
      return AuthOnboardingFlow.join;
    case 'register':
      return AuthOnboardingFlow.register;
    case 'legacyLogin':
      return AuthOnboardingFlow.legacyLogin;
    case 'login':
      return AuthOnboardingFlow.login;
    default:
      return null;
  }
}

UserRole? parseAuthRole(String? raw) {
  switch (raw) {
    case 'manager':
      return UserRole.manager;
    case 'resident':
      return UserRole.resident;
    default:
      return null;
  }
}
