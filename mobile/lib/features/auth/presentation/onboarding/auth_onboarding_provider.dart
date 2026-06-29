import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_entity.dart';
import 'auth_onboarding_models.dart';

/// Yeni kullanıcı kayıt yolu — referans görseldeki 6 adım.
const _defaultRegistrationSteps = [
  AuthOnboardingStepId.role,
  AuthOnboardingStepId.contact,
  AuthOnboardingStepId.verification,
  AuthOnboardingStepId.invite,
  AuthOnboardingStepId.features,
  AuthOnboardingStepId.complete,
];

class AuthOnboardingState {
  final AuthOnboardingStepId currentStepId;
  final List<AuthOnboardingStepId> visibleSteps;
  final UserRole? role;
  final AuthContactChannel contact;
  final AuthOnboardingFlow flow;
  final bool isFirstTimeSetup;
  final String? phone;
  final String? email;
  final String? name;
  final String? inviteCode;
  final String? otpCode;
  final String? password;
  final String? confirmPassword;
  final ManagerType? managerType;
  final String? inviteLabel;
  final bool otpSent;
  final int otpResendSeconds;
  final String? errorMessage;

  const AuthOnboardingState({
    this.currentStepId = AuthOnboardingStepId.role,
    this.visibleSteps = _defaultRegistrationSteps,
    this.role,
    this.contact = AuthContactChannel.phone,
    this.flow = AuthOnboardingFlow.login,
    this.isFirstTimeSetup = false,
    this.phone,
    this.email,
    this.name,
    this.inviteCode,
    this.otpCode,
    this.password,
    this.confirmPassword,
    this.managerType,
    this.inviteLabel,
    this.otpSent = false,
    this.otpResendSeconds = 0,
    this.errorMessage,
  });

  int get currentStepIndex {
    final idx = visibleSteps.indexOf(currentStepId);
    return idx < 0 ? 0 : idx;
  }

  int get totalSteps => visibleSteps.length;

  AuthOnboardingState copyWith({
    AuthOnboardingStepId? currentStepId,
    List<AuthOnboardingStepId>? visibleSteps,
    UserRole? role,
    AuthContactChannel? contact,
    AuthOnboardingFlow? flow,
    bool? isFirstTimeSetup,
    String? phone,
    String? email,
    String? name,
    String? inviteCode,
    String? otpCode,
    String? password,
    String? confirmPassword,
    ManagerType? managerType,
    String? inviteLabel,
    bool? otpSent,
    int? otpResendSeconds,
    String? errorMessage,
    bool clearError = false,
    bool clearInviteLabel = false,
  }) {
    return AuthOnboardingState(
      currentStepId: currentStepId ?? this.currentStepId,
      visibleSteps: visibleSteps ?? this.visibleSteps,
      role: role ?? this.role,
      contact: contact ?? this.contact,
      flow: flow ?? this.flow,
      isFirstTimeSetup: isFirstTimeSetup ?? this.isFirstTimeSetup,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      inviteCode: inviteCode ?? this.inviteCode,
      otpCode: otpCode ?? this.otpCode,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      managerType: managerType ?? this.managerType,
      inviteLabel: clearInviteLabel ? null : (inviteLabel ?? this.inviteLabel),
      otpSent: otpSent ?? this.otpSent,
      otpResendSeconds: otpResendSeconds ?? this.otpResendSeconds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final authOnboardingProvider =
    NotifierProvider<AuthOnboardingNotifier, AuthOnboardingState>(
  AuthOnboardingNotifier.new,
);

class AuthOnboardingNotifier extends Notifier<AuthOnboardingState> {
  @override
  AuthOnboardingState build() => const AuthOnboardingState();

  void applyInitialQuery({
    UserRole? role,
    AuthOnboardingFlow? flow,
    bool skipRoleStep = false,
  }) {
    var next = state.copyWith(clearError: true);
    if (role != null) next = next.copyWith(role: role);
    if (flow != null) {
      next = next.copyWith(
        flow: flow,
        isFirstTimeSetup: flow == AuthOnboardingFlow.register ||
            flow == AuthOnboardingFlow.join,
        contact: flow == AuthOnboardingFlow.legacyLogin
            ? AuthContactChannel.email
            : next.contact,
      );
    }
    var steps = role != null || flow != null
        ? _computeVisibleSteps(next)
        : List<AuthOnboardingStepId>.from(_defaultRegistrationSteps);
    if (skipRoleStep &&
        steps.isNotEmpty &&
        steps.first == AuthOnboardingStepId.role) {
      steps = steps.sublist(1);
    }
    final startStep = steps.isNotEmpty ? steps.first : AuthOnboardingStepId.role;
    state = next.copyWith(
      visibleSteps: steps,
      currentStepId: startStep,
    );
  }

  List<AuthOnboardingStepId> _computeVisibleSteps(AuthOnboardingState s) {
    if (s.flow == AuthOnboardingFlow.legacyLogin ||
        (s.flow == AuthOnboardingFlow.login && s.contact == AuthContactChannel.email)) {
      return const [
        AuthOnboardingStepId.role,
        AuthOnboardingStepId.contact,
        AuthOnboardingStepId.verification,
      ];
    }
    if (s.flow == AuthOnboardingFlow.login && s.contact == AuthContactChannel.phone) {
      return const [
        AuthOnboardingStepId.role,
        AuthOnboardingStepId.contact,
        AuthOnboardingStepId.verification,
      ];
    }
    if (s.flow == AuthOnboardingFlow.join && s.role == UserRole.resident) {
      return const [
        AuthOnboardingStepId.role,
        AuthOnboardingStepId.contact,
        AuthOnboardingStepId.verification,
        AuthOnboardingStepId.invite,
      ];
    }
    return const [
      AuthOnboardingStepId.role,
      AuthOnboardingStepId.contact,
      AuthOnboardingStepId.verification,
      AuthOnboardingStepId.invite,
      AuthOnboardingStepId.features,
      AuthOnboardingStepId.complete,
    ];
  }

  void selectRole(UserRole role) {
    state = state.copyWith(role: role, clearError: true);
  }

  /// Rol kartına dokunulunca doğrudan ilgili akışa ve Adım 2'ye geç.
  void pickManagerRole() => startManagerRegister();

  void pickResidentRole() => startResidentJoin();

  void startReturningLoginForRole(UserRole role) {
    state = state.copyWith(
      role: role,
      flow: AuthOnboardingFlow.login,
      isFirstTimeSetup: false,
      contact: AuthContactChannel.phone,
      visibleSteps: const [
        AuthOnboardingStepId.role,
        AuthOnboardingStepId.contact,
        AuthOnboardingStepId.verification,
      ],
      clearError: true,
    );
    _goToStep(AuthOnboardingStepId.contact);
  }

  void startLegacyEmailLogin() {
    final next = state.copyWith(
      role: UserRole.resident,
      flow: AuthOnboardingFlow.legacyLogin,
      contact: AuthContactChannel.email,
      isFirstTimeSetup: false,
      visibleSteps: const [
        AuthOnboardingStepId.role,
        AuthOnboardingStepId.contact,
        AuthOnboardingStepId.verification,
      ],
      clearError: true,
    );
    state = next;
    _goToStep(AuthOnboardingStepId.contact);
  }

  void startManagerRegister() {
    final next = state.copyWith(
      role: UserRole.manager,
      flow: AuthOnboardingFlow.register,
      isFirstTimeSetup: true,
      visibleSteps: _computeVisibleSteps(
        state.copyWith(
          role: UserRole.manager,
          flow: AuthOnboardingFlow.register,
          isFirstTimeSetup: true,
        ),
      ),
      clearError: true,
    );
    state = next;
    _goToStep(AuthOnboardingStepId.contact);
  }

  void startResidentJoin() {
    final next = state.copyWith(
      role: UserRole.resident,
      flow: AuthOnboardingFlow.join,
      contact: AuthContactChannel.phone,
      isFirstTimeSetup: true,
      visibleSteps: _computeVisibleSteps(
        state.copyWith(
          role: UserRole.resident,
          flow: AuthOnboardingFlow.join,
          isFirstTimeSetup: true,
        ),
      ),
      clearError: true,
    );
    state = next;
    _goToStep(AuthOnboardingStepId.contact);
  }

  void setContactChannel(AuthContactChannel channel) {
    final next = state.copyWith(contact: channel, clearError: true);
    state = next.copyWith(visibleSteps: _computeVisibleSteps(next));
  }

  void setContactValue(String value) {
    if (state.contact == AuthContactChannel.phone) {
      state = state.copyWith(phone: value, clearError: true);
    } else {
      state = state.copyWith(email: value.trim(), clearError: true);
    }
  }

  void setPasswordFields({String? password, String? confirm}) {
    state = state.copyWith(
      password: password ?? state.password,
      confirmPassword: confirm ?? state.confirmPassword,
      clearError: true,
    );
  }

  void setOtpCode(String code) {
    state = state.copyWith(otpCode: code, clearError: true);
  }

  void setInviteFields({String? inviteCode, String? name}) {
    state = state.copyWith(
      inviteCode: inviteCode ?? state.inviteCode,
      name: name ?? state.name,
      clearError: true,
    );
  }

  void markOtpSent() {
    state = state.copyWith(otpSent: true, otpResendSeconds: 52);
  }

  void tickOtpResend() {
    if (state.otpResendSeconds <= 0) return;
    state = state.copyWith(otpResendSeconds: state.otpResendSeconds - 1);
  }

  void setInviteLabel(String label) {
    state = state.copyWith(inviteLabel: label);
  }

  void setManagerPrimary() {
    state = state.copyWith(
      managerType: ManagerType.primary,
      clearInviteLabel: true,
      clearError: true,
    );
    _goToStep(AuthOnboardingStepId.features);
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  bool goBack() {
    final idx = state.currentStepIndex;
    if (idx <= 0) return false;
    state = state.copyWith(currentStepId: state.visibleSteps[idx - 1]);
    return true;
  }

  void _goToStep(AuthOnboardingStepId stepId) {
    final steps = state.visibleSteps;
    if (!steps.contains(stepId)) return;
    state = state.copyWith(currentStepId: stepId);
  }

  void goNextStep() {
    final idx = state.currentStepIndex;
    if (idx >= state.visibleSteps.length - 1) return;
    state = state.copyWith(currentStepId: state.visibleSteps[idx + 1]);
  }

  void goToFeatures() => _goToStep(AuthOnboardingStepId.features);

  void goToComplete() => _goToStep(AuthOnboardingStepId.complete);

  void refreshVisibleStepsForFlow() {
    state = state.copyWith(visibleSteps: _computeVisibleSteps(state));
  }
}
