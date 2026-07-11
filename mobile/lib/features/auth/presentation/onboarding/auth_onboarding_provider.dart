import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/phone_utils.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_onboarding_models.dart';

/// Yönetici — e-posta/telefon kontrolü (giriş/kayıt henüz bilinmiyor).
const _managerLookupSteps = [
  AuthOnboardingStepId.role,
  AuthOnboardingStepId.identifier,
];

/// Yönetici kayıt — iletişim → isim → şifre.
const _managerPasswordRegisterSteps = [
  AuthOnboardingStepId.role,
  AuthOnboardingStepId.identifier,
  AuthOnboardingStepId.name,
  AuthOnboardingStepId.credentials,
];

/// Yönetici giriş — iletişim → şifre.
const _managerPasswordLoginSteps = [
  AuthOnboardingStepId.role,
  AuthOnboardingStepId.identifier,
  AuthOnboardingStepId.credentials,
];

/// Sakin tekrar giriş — telefon + OTP.
const _residentLoginSteps = [
  AuthOnboardingStepId.role,
  AuthOnboardingStepId.contact,
  AuthOnboardingStepId.verification,
];

/// Sakin katılım — telefon + OTP + isim + davet.
const _residentJoinSteps = [
  AuthOnboardingStepId.role,
  AuthOnboardingStepId.contact,
  AuthOnboardingStepId.verification,
  AuthOnboardingStepId.name,
  AuthOnboardingStepId.invite,
];

/// Davet linkinden gelen sakin — davet adımı atlanır.
const _residentJoinDeepLinkSteps = [
  AuthOnboardingStepId.role,
  AuthOnboardingStepId.contact,
  AuthOnboardingStepId.verification,
  AuthOnboardingStepId.name,
];

/// Yeni kullanıcı kayıt yolu — OTP tabanlı (eski yönetici OTP yolu).
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
  final bool joinOtpVerified;
  final bool stepForward;
  /// Davet linkinden (`?code=` / deep link) gelen kod; invite adımı atlanır.
  final bool inviteFromDeepLink;

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
    this.joinOtpVerified = false,
    this.stepForward = true,
    this.inviteFromDeepLink = false,
  });

  int get currentStepIndex {
    final idx = visibleSteps.indexOf(currentStepId);
    return idx < 0 ? 0 : idx;
  }

  int get totalSteps => visibleSteps.length;

  bool get isManagerPasswordFlow =>
      role == UserRole.manager &&
      visibleSteps.contains(AuthOnboardingStepId.identifier);

  bool get hasPrefetchedInvite =>
      inviteFromDeepLink &&
      inviteCode != null &&
      inviteCode!.trim().isNotEmpty;

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
    bool? joinOtpVerified,
    bool? stepForward,
    bool? inviteFromDeepLink,
    bool clearError = false,
    bool clearInviteLabel = false,
    bool clearPhone = false,
    bool clearEmail = false,
  }) {
    return AuthOnboardingState(
      currentStepId: currentStepId ?? this.currentStepId,
      visibleSteps: visibleSteps ?? this.visibleSteps,
      role: role ?? this.role,
      contact: contact ?? this.contact,
      flow: flow ?? this.flow,
      isFirstTimeSetup: isFirstTimeSetup ?? this.isFirstTimeSetup,
      phone: clearPhone ? null : (phone ?? this.phone),
      email: clearEmail ? null : (email ?? this.email),
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
      joinOtpVerified: joinOtpVerified ?? this.joinOtpVerified,
      stepForward: stepForward ?? this.stepForward,
      inviteFromDeepLink: inviteFromDeepLink ?? this.inviteFromDeepLink,
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
    String? inviteCode,
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

    final rawCode = inviteCode?.trim();
    if (rawCode != null && rawCode.isNotEmpty) {
      next = next.copyWith(
        inviteCode: rawCode.toUpperCase().replaceAll(RegExp(r'\s+'), ''),
        inviteFromDeepLink: true,
        role: UserRole.resident,
        contact: AuthContactChannel.phone,
      );
      // Deep link: telefon-öncelikli; flow henüz login/join bilinmiyor.
      if (flow == null || flow == AuthOnboardingFlow.join) {
        next = next.copyWith(
          flow: AuthOnboardingFlow.login,
          isFirstTimeSetup: false,
        );
      }
    }

    // Eski /join?flow=join → telefon-öncelikli sakin girişi.
    if (next.role == UserRole.resident &&
        (flow == AuthOnboardingFlow.join || next.inviteFromDeepLink)) {
      next = next.copyWith(
        role: UserRole.resident,
        contact: AuthContactChannel.phone,
        flow: AuthOnboardingFlow.login,
        isFirstTimeSetup: false,
        joinOtpVerified: false,
      );
    }

    var steps = role != null || flow != null || next.inviteFromDeepLink
        ? _computeVisibleSteps(next)
        : List<AuthOnboardingStepId>.from(_defaultRegistrationSteps);

    if (next.role == UserRole.resident &&
        (flow == AuthOnboardingFlow.join ||
            next.inviteFromDeepLink ||
            role == UserRole.resident)) {
      steps = List<AuthOnboardingStepId>.from(_residentLoginSteps);
    }

    // Yönetici deep link / query: deneyim adımı yok; identifier ile başla.
    if (next.role == UserRole.manager) {
      steps = List<AuthOnboardingStepId>.from(_managerLookupSteps);
    }

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
    if (s.role == UserRole.manager && s.flow == AuthOnboardingFlow.register) {
      return List<AuthOnboardingStepId>.from(_managerPasswordRegisterSteps);
    }
    if (s.role == UserRole.manager && s.flow == AuthOnboardingFlow.login) {
      return List<AuthOnboardingStepId>.from(_managerPasswordLoginSteps);
    }
    if (s.role == UserRole.manager) {
      return List<AuthOnboardingStepId>.from(_managerLookupSteps);
    }
    if (s.role == UserRole.resident && s.flow == AuthOnboardingFlow.login) {
      return List<AuthOnboardingStepId>.from(_residentLoginSteps);
    }
    if (s.flow == AuthOnboardingFlow.join && s.role == UserRole.resident) {
      return List<AuthOnboardingStepId>.from(
        s.hasPrefetchedInvite
            ? _residentJoinDeepLinkSteps
            : _residentJoinSteps,
      );
    }
    if (s.flow == AuthOnboardingFlow.legacyLogin ||
        (s.flow == AuthOnboardingFlow.login &&
            s.contact == AuthContactChannel.email)) {
      return const [
        AuthOnboardingStepId.role,
        AuthOnboardingStepId.contact,
        AuthOnboardingStepId.verification,
      ];
    }
    if (s.flow == AuthOnboardingFlow.login &&
        s.contact == AuthContactChannel.phone) {
      return const [
        AuthOnboardingStepId.role,
        AuthOnboardingStepId.contact,
        AuthOnboardingStepId.verification,
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

  List<AuthOnboardingStepId> _residentJoinStepsFor(AuthOnboardingState s) {
    return List<AuthOnboardingStepId>.from(
      s.hasPrefetchedInvite ? _residentJoinDeepLinkSteps : _residentJoinSteps,
    );
  }

  void selectRole(UserRole role) {
    state = state.copyWith(role: role, clearError: true);
  }

  /// Yönetici kartı — doğrudan e-posta/telefon girişi.
  void pickManagerRole() {
    state = state.copyWith(
      role: UserRole.manager,
      flow: AuthOnboardingFlow.login,
      isFirstTimeSetup: false,
      visibleSteps: List<AuthOnboardingStepId>.from(_managerLookupSteps),
      clearError: true,
    );
    _goToStep(AuthOnboardingStepId.identifier);
  }

  /// Sakin kartı — doğrudan telefon girişi (deneyim seçimi yok).
  void pickResidentRole() {
    state = state.copyWith(
      role: UserRole.resident,
      flow: AuthOnboardingFlow.login,
      contact: AuthContactChannel.phone,
      isFirstTimeSetup: false,
      joinOtpVerified: false,
      visibleSteps: List<AuthOnboardingStepId>.from(_residentLoginSteps),
      clearError: true,
    );
    _goToStep(AuthOnboardingStepId.contact);
  }

  void startResidentReturning() {
    state = state.copyWith(
      role: UserRole.resident,
      flow: AuthOnboardingFlow.login,
      contact: AuthContactChannel.phone,
      isFirstTimeSetup: false,
      joinOtpVerified: false,
      visibleSteps: List<AuthOnboardingStepId>.from(_residentLoginSteps),
      clearError: true,
    );
    _goToStep(AuthOnboardingStepId.contact);
  }

  void startResidentWithInvite() {
    applyResidentJoinFlow(keepCurrentStep: false);
  }

  /// Telefon kontrolü sonrası: kayıtlı sakin girişi.
  void applyResidentLoginFlow({bool keepCurrentStep = true}) {
    final current = keepCurrentStep ? state.currentStepId : null;
    state = state.copyWith(
      role: UserRole.resident,
      flow: AuthOnboardingFlow.login,
      contact: AuthContactChannel.phone,
      isFirstTimeSetup: false,
      joinOtpVerified: false,
      visibleSteps: List<AuthOnboardingStepId>.from(_residentLoginSteps),
      clearError: true,
    );
    if (current != null && state.visibleSteps.contains(current)) {
      _goToStep(current);
    } else {
      _goToStep(AuthOnboardingStepId.contact);
    }
  }

  /// Telefon kontrolü sonrası: yeni sakin katılımı.
  void applyResidentJoinFlow({bool keepCurrentStep = true}) {
    final current = keepCurrentStep ? state.currentStepId : null;
    final steps = _residentJoinStepsFor(state);
    state = state.copyWith(
      role: UserRole.resident,
      flow: AuthOnboardingFlow.join,
      contact: AuthContactChannel.phone,
      isFirstTimeSetup: true,
      joinOtpVerified: false,
      visibleSteps: steps,
      clearError: true,
    );
    if (current != null && state.visibleSteps.contains(current)) {
      _goToStep(current);
    } else {
      _goToStep(AuthOnboardingStepId.contact);
    }
  }

  /// Identifier kontrolü sonrası: kayıtlı yönetici girişi.
  void applyManagerLoginFlow({bool keepCurrentStep = true}) {
    final current = keepCurrentStep ? state.currentStepId : null;
    state = state.copyWith(
      role: UserRole.manager,
      flow: AuthOnboardingFlow.login,
      isFirstTimeSetup: false,
      visibleSteps: List<AuthOnboardingStepId>.from(_managerPasswordLoginSteps),
      clearError: true,
    );
    if (current != null && state.visibleSteps.contains(current)) {
      _goToStep(current);
    } else {
      _goToStep(AuthOnboardingStepId.identifier);
    }
  }

  /// Identifier kontrolü sonrası: yeni yönetici kaydı.
  void applyManagerRegisterFlow({bool keepCurrentStep = true}) {
    final current = keepCurrentStep ? state.currentStepId : null;
    state = state.copyWith(
      role: UserRole.manager,
      flow: AuthOnboardingFlow.register,
      isFirstTimeSetup: true,
      visibleSteps: List<AuthOnboardingStepId>.from(_managerPasswordRegisterSteps),
      clearError: true,
    );
    if (current != null && state.visibleSteps.contains(current)) {
      _goToStep(current);
    } else {
      _goToStep(AuthOnboardingStepId.identifier);
    }
  }

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
    pickManagerRole();
  }

  void startResidentJoin() => startResidentWithInvite();

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

  void setName(String value) {
    state = state.copyWith(name: value.trim(), clearError: true);
  }

  void setIdentifierFromRaw(String raw) {
    final trimmed = raw.trim();
    if (trimmed.contains('@')) {
      state = state.copyWith(
        email: trimmed.toLowerCase(),
        clearPhone: true,
        contact: AuthContactChannel.email,
        clearError: true,
      );
      return;
    }
    final normalized = PhoneUtils.normalizeTrPhone(trimmed);
    state = state.copyWith(
      phone: normalized,
      clearEmail: true,
      contact: AuthContactChannel.phone,
      clearError: true,
    );
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

  void markJoinOtpVerified() {
    state = state.copyWith(joinOtpVerified: true, clearError: true);
  }

  void setInviteCode(String code) {
    state = state.copyWith(inviteCode: code.trim(), clearError: true);
  }

  void setInviteFromDeepLink(String code) {
    final normalized = code.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
    state = state.copyWith(
      inviteCode: normalized,
      inviteFromDeepLink: true,
      role: UserRole.resident,
      contact: AuthContactChannel.phone,
      clearError: true,
    );
  }

  void setInviteFields({String? inviteCode, String? name}) {
    state = state.copyWith(
      inviteCode: inviteCode ?? state.inviteCode,
      name: name ?? state.name,
      clearError: true,
    );
  }

  void markOtpSent() {
    state = state.copyWith(otpSent: true, otpResendSeconds: 120);
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
    state = state.copyWith(
      currentStepId: state.visibleSteps[idx - 1],
      stepForward: false,
    );
    return true;
  }

  void _goToStep(AuthOnboardingStepId stepId, {bool forward = true}) {
    final steps = state.visibleSteps;
    if (!steps.contains(stepId)) return;
    state = state.copyWith(currentStepId: stepId, stepForward: forward);
  }

  void goNextStep() {
    final idx = state.currentStepIndex;
    if (idx >= state.visibleSteps.length - 1) return;
    state = state.copyWith(
      currentStepId: state.visibleSteps[idx + 1],
      stepForward: true,
    );
  }

  void goToFeatures() => _goToStep(AuthOnboardingStepId.features);

  void goToComplete() => _goToStep(AuthOnboardingStepId.complete);

  void refreshVisibleStepsForFlow() {
    state = state.copyWith(visibleSteps: _computeVisibleSteps(state));
  }
}
