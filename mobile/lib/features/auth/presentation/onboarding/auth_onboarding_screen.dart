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
import '../../domain/entities/saved_login_hint.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_button.dart';
import 'auth_onboarding_models.dart';
import 'auth_onboarding_provider.dart';
import 'saved_login_hints_provider.dart';
import 'widgets/auth_progress_indicator.dart';
import 'widgets/auth_step_scaffold.dart';
import 'widgets/onboarding_buildings_illustration.dart';
import 'widgets/onboarding_compact_header.dart';
import 'widgets/onboarding_feature_tile.dart';
import 'widgets/onboarding_info_banner.dart';
import 'widgets/onboarding_role_cards.dart';
import 'widgets/onboarding_segment_tabs.dart';
import 'widgets/otp_input_row.dart';
import '../widgets/auth_brand_header.dart';

/// 6 adımlı auth onboarding — tek giriş noktası `/login`.
class AuthOnboardingScreen extends ConsumerStatefulWidget {
  const AuthOnboardingScreen({
    super.key,
    this.initialRole,
    this.initialFlow,
    this.initialStep,
    this.skipRoleStep = false,
  });

  final UserRole? initialRole;
  final AuthOnboardingFlow? initialFlow;
  final int? initialStep;
  final bool skipRoleStep;

  @override
  ConsumerState<AuthOnboardingScreen> createState() =>
      _AuthOnboardingScreenState();
}

class _AuthOnboardingScreenState extends ConsumerState<AuthOnboardingScreen> {
  final _contactController = TextEditingController();
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
          );
    });
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _contactController.dispose();
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

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].isEmpty) return email;
    final local = parts[0];
    final head = local.length <= 2 ? local[0] : local.substring(0, 2);
    return '$head***@${parts[1]}';
  }

  String? _returningHintSubtitle(SavedLoginHint? hint, String template) {
    if (hint == null || hint.name.trim().isEmpty) return null;
    final contact = hint.phone != null && hint.phone!.isNotEmpty
        ? '+90 ${PhoneUtils.maskDisplay(hint.phone!)}'
        : hint.email != null && hint.email!.isNotEmpty
            ? _maskEmail(hint.email!)
            : '';
    if (contact.isEmpty) return hint.name.trim();
    return template
        .replaceAll('{name}', hint.name.trim())
        .replaceAll('{contact}', contact);
  }

  void _startReturningLogin(UserRole role, SavedLoginHint? hint) {
    final onboarding = ref.read(authOnboardingProvider.notifier);
    onboarding.startReturningLoginForRole(role);
    _contactController.clear();
    if (hint?.phone != null && hint!.phone!.isNotEmpty) {
      onboarding.setContactChannel(AuthContactChannel.phone);
      var digits = hint.phone!.replaceAll(RegExp(r'\D'), '');
      if (digits.startsWith('90') && digits.length >= 12) {
        digits = digits.substring(2);
      } else if (digits.startsWith('0') && digits.length >= 11) {
        digits = digits.substring(1);
      }
      if (digits.length > 10) {
        digits = digits.substring(digits.length - 10);
      }
      _contactController.text = digits;
      return;
    }
    if (hint?.email != null && hint!.email!.isNotEmpty) {
      onboarding.setContactChannel(AuthContactChannel.email);
      _contactController.text = hint.email!;
    }
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
        if (ob.role == null) {
          onboarding.setError(context.t.features.auth.signUpSubtitle);
          return;
        }
        if (ob.role == UserRole.manager) {
          onboarding.startManagerRegister();
        } else {
          onboarding.startResidentJoin();
        }
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

  Future<void> _handleContactStep(
    AuthOnboardingState ob,
    AuthOnboardingNotifier onboarding,
    AuthNotifier auth,
  ) async {
    if (_isResidentJoin(ob)) {
      final name = _nameController.text.trim();
      if (name.length < 2) {
        ref.read(toastProvider.notifier).show(
              context.t.features.auth.onboarding.residentNameRequired,
              type: ToastType.error,
            );
        return;
      }
      onboarding.setInviteFields(name: name);
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
      } catch (_) {
        final err = ref.read(authStateProvider).error;
        ref.read(toastProvider.notifier).show(
              err ?? context.t.features.auth.onboarding.otpSendFailed,
              type: ToastType.error,
            );
      }
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
      } catch (_) {
        final err = ref.read(authStateProvider).error;
        ref.read(toastProvider.notifier).show(
              err ?? context.t.features.auth.onboarding.otpSendFailed,
              type: ToastType.error,
            );
      }
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
      if (ob.flow == AuthOnboardingFlow.join) {
        onboarding.goNextStep();
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

    if (ob.role == UserRole.resident) {
      final invite = _inviteController.text.trim();
      final name = (ob.name ?? _nameController.text.trim()).trim();
      if (invite.isEmpty) {
        ref.read(toastProvider.notifier).show(
              context.t.features.auth.onboarding.inviteInvalid,
              type: ToastType.error,
            );
        return;
      }
      if (name.isEmpty) {
        ref.read(toastProvider.notifier).show(
              context.t.features.auth.onboarding.residentNameRequired,
              type: ToastType.error,
            );
        return;
      }
      onboarding.setInviteFields(inviteCode: invite, name: name);
      try {
        final label = await auth.validateInviteCode(invite);
        onboarding.setInviteLabel(label);
      } catch (_) {
        ref.read(toastProvider.notifier).show(
              context.t.features.auth.onboarding.inviteInvalid,
              type: ToastType.error,
            );
        return;
      }
      final phone = ob.phone;
      final email = ob.email;
      final code = ob.otpCode;
      if ((phone == null && email == null) || code == null) return;
      try {
        await auth.verifyOtpAndAuthenticate(
          phone: phone,
          email: email,
          code: code,
          purpose: 'resident_join',
          inviteCode: invite,
          name: name,
          ref: ref,
        );
        final user = ref.read(authStateProvider).user;
        if (user != null) {
          _goDashboard(user);
        }
      } catch (_) {}
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
    final onboarding = ref.read(authOnboardingProvider.notifier);

    ref.listen(authStateProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ref.read(toastProvider.notifier).show(
              next.error!,
              type: ToastType.error,
            );
      }
    });

    return AuthBackHandler(
      child: AuthScreenShell(
        showBrandHeader: ob.currentStepId == AuthOnboardingStepId.role,
        brandHeaderLayout: AuthBrandHeaderLayout.vertical,
        wrapInCard: false,
        leading: ob.currentStepIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: authState.isLoading
                    ? null
                    : () => onboarding.goBack(),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (ob.currentStepId != AuthOnboardingStepId.role)
              const OnboardingCompactHeader(),
            AuthProgressIndicator(
              currentIndex: ob.currentStepIndex,
              totalSteps: ob.totalSteps,
            ),
            const SizedBox(height: AppSizes.spacingM),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(
                key: ValueKey(ob.currentStepId),
                child: _buildStep(context, ob, authState.isLoading),
              ),
            ),
          ],
        ),
      ),
    );
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
        final savedHints = ref.watch(savedLoginHintsProvider).value;
        final managerHint = savedHints?[UserRole.manager];
        final residentHint = savedHints?[UserRole.resident];
        return AuthStepScaffold(
          title: tOb.step1Title,
          subtitle: tOb.step1Subtitle,
          primaryLabel: tOb.continueButton,
          isLoading: isLoading,
          onPrimary: ob.role == null ? null : _onContinue,
          primaryEnabled: ob.role != null,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OnboardingRoleCards(
                selectedRole: ob.role,
                residentLabel: context.t.common.resident,
                managerLabel: context.t.common.manager,
                onResidentTap: isLoading
                    ? () {}
                    : onboarding.pickResidentRole,
                onManagerTap: isLoading
                    ? () {}
                    : onboarding.pickManagerRole,
                enabled: !isLoading,
              ),
              const OnboardingBuildingsIllustration(),
            ],
          ),
          secondary: Column(
            children: [
              AuthTextButton(
                label: tOb.step1ReturningLoginManager,
                subtitle: _returningHintSubtitle(
                  managerHint,
                  tOb.step1ReturningLoginHint,
                ),
                onTap: isLoading
                    ? null
                    : () => _startReturningLogin(
                          UserRole.manager,
                          managerHint,
                        ),
              ),
              AuthTextButton(
                label: tOb.step1ReturningLoginResident,
                subtitle: _returningHintSubtitle(
                  residentHint,
                  tOb.step1ReturningLoginHint,
                ),
                onTap: isLoading
                    ? null
                    : () => _startReturningLogin(
                          UserRole.resident,
                          residentHint,
                        ),
              ),
              AuthTextButton(
                label: tOb.step1LegacyEmailLogin,
                onTap: isLoading ? null : onboarding.startLegacyEmailLogin,
              ),
            ],
          ),
        );

      case AuthOnboardingStepId.contact:
        if (_isResidentJoin(ob)) {
          return AuthStepScaffold(
            title: tOb.residentLoginTitle,
            subtitle: tOb.residentLoginSubtitle,
            primaryLabel: tOb.residentSendCodeButton,
            isLoading: isLoading,
            onPrimary: _onContinue,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  enabled: !isLoading,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: context.t.features.auth.name,
                    hintText: context.t.features.auth.nameHint,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingM),
                TextField(
                  controller: _contactController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: context.t.features.auth.phone,
                    hintText: context.t.features.auth.phoneHint,
                    prefixIcon: Padding(
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
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 72),
                    counterText: '',
                  ),
                ),
              ],
            ),
            footer: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.spacingXS),
                Flexible(
                  child: Text(
                    tOb.residentPhoneVerifyNote,
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
                            '{seconds}',
                            '${ob.otpResendSeconds}',
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
                            '{seconds}',
                            '${ob.otpResendSeconds}',
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
