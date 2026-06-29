import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/cache_invalidator.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/subscription/revenue_cat_service.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart'
    show AuthRepository, AuthRepositoryImpl;
import '../../domain/entities/user_entity.dart';
import '../../../profile/presentation/providers/profile_notifier.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../l10n/strings.g.dart';

export '../../../../core/providers/app_providers.dart'
    show dioClientProvider, secureStorageProvider, onSessionExpiredProvider;

final authRemoteDataSourceProvider = Provider((ref) {
  return AuthRemoteDataSourceImpl(dioClient: ref.watch(dioClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

enum LogoutReason { manual, otherDevices }

class AuthState {
  final LogoutReason? logoutReason;
  final bool isLoading;
  final UserEntity? user;
  final String? error;
  final bool isAuthenticated;
  final bool registrationSuccess;
  final bool isManualLogout;
  final bool showLogoutToast;

  const AuthState({
    this.logoutReason,
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
    this.registrationSuccess = false,
    this.isManualLogout = false,
    this.showLogoutToast = true,
  });

  AuthState copyWith({
    LogoutReason? logoutReason,
    bool? isLoading,
    UserEntity? user,
    String? error,
    bool? isAuthenticated,
    bool? registrationSuccess,
    bool? isManualLogout,
    bool? showLogoutToast,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      logoutReason: logoutReason ?? this.logoutReason,
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      registrationSuccess: registrationSuccess ?? this.registrationSuccess,
      isManualLogout: isManualLogout ?? this.isManualLogout,
      showLogoutToast: showLogoutToast ?? this.showLogoutToast,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> submitLogin(
    String rawIdentifier,
    String password,
    WidgetRef ref,
  ) async {
    if (state.isLoading) return;
    if (password.isEmpty) {
      state = state.copyWith(error: t.features.auth.passwordRequired);
      return;
    }
    final isPhone = !rawIdentifier.contains('@');
    if (!isPhone &&
        !InputValidators.emailRegex.hasMatch(rawIdentifier.trim())) {
      state = state.copyWith(error: t.validation.emailInvalid);
      return;
    }
    if (isPhone && PhoneUtils.normalizeTrPhone(rawIdentifier) == null) {
      state = state.copyWith(error: t.features.auth.onboarding.phoneInvalid);
      return;
    }
    final identifier = PhoneUtils.normalizeLoginIdentifier(rawIdentifier);
    await login(identifier, password, ref);
  }

  Future<void> login(String identifier, String password, WidgetRef ref) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authRepository.login(identifier, password);
      resetManagerTabIndex(ref);
      resetResidentTabIndex(ref);
      await _onAuthenticated(ref, user);
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: userFacingError(e));
    }
  }

  Future<void> register(
    String? email,
    String password,
    String name,
    String? phone,
  ) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final normalizedPhone = PhoneUtils.normalizeTrPhone(phone);
      await _authRepository.register(
        email?.trim().isEmpty == true ? null : email?.trim(),
        password,
        name,
        normalizedPhone,
      );
      state = state.copyWith(
        isLoading: false,
        registrationSuccess: true,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: userFacingError(e));
    }
  }

  Future<void> join(
    String inviteCode,
    String email,
    String password,
    String name,
    String? phone,
    WidgetRef ref,
  ) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final formattedPhone = PhoneUtils.normalizeTrPhone(phone);
      final user = await _authRepository.join(
        inviteCode,
        email,
        password,
        name,
        formattedPhone,
      );
      resetManagerTabIndex(ref);
      resetResidentTabIndex(ref);
      await _onAuthenticated(ref, user);
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: userFacingError(e));
    }
  }

  Future<void> sendOtp({
    String? phone,
    String? email,
    required String purpose,
  }) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepository.sendOtp(
        phone: phone,
        email: email,
        purpose: purpose,
      );
      state = state.copyWith(isLoading: false, clearError: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: userFacingError(e));
      rethrow;
    }
  }

  Future<UserEntity> verifyOtpAndAuthenticate({
    String? phone,
    String? email,
    required String code,
    required String purpose,
    Map<String, dynamic>? payload,
    String? name,
    String? password,
    String? inviteCode,
    required WidgetRef ref,
  }) async {
    if (state.isLoading) return Future.error('loading');
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authRepository.verifyOtp(
        phone: phone,
        email: email,
        code: code,
        purpose: purpose,
        payload: payload,
        name: name,
        password: password,
        inviteCode: inviteCode,
      );
      resetManagerTabIndex(ref);
      resetResidentTabIndex(ref);
      await _onAuthenticated(ref, user);
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        clearError: true,
      );
      return user;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: userFacingError(e));
      rethrow;
    }
  }

  Future<String> validateInviteCode(String code) async {
    return _authRepository.validateInvite(code);
  }

  Future<void> _onAuthenticated(WidgetRef ref, UserEntity user) async {
    final previousId = state.user?.id;
    ref.read(dioClientProvider).clearResponseCache();
    if (previousId != null && previousId != user.id) {
      await clearDekontPreviewsOnUserSwitch(ref);
    }
    invalidateAllCachedProviders(ref);
    if (user.role == UserRole.manager) {
      await RevenueCatService.logIn(user.id);
    }
    ref.read(profileNotifierProvider.notifier).loadProfile();
  }

  Future<void> syncCachedUser(UserEntity user) async {
    await _authRepository.persistUser(user);
    if (state.isAuthenticated) {
      state = state.copyWith(user: user, clearError: true);
    }
  }

  Future<void> restoreSession() async {
    if (state.isAuthenticated) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authRepository.restoreSession();
      if (user != null) {
        if (user.role == UserRole.manager) {
          await RevenueCatService.logIn(user.id);
        }
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
          clearError: true,
        );
        ref.read(profileNotifierProvider.notifier).loadProfile();
      } else {
        state = AuthState();
      }
    } catch (_) {
      state = AuthState();
    }
  }

  Future<void> logout(WidgetRef ref, {bool showToast = true}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      resetManagerTabIndex(ref);
      resetResidentTabIndex(ref);
      ref.read(dioClientProvider).clearResponseCache();
      await invalidateCachesOnLogout(ref);
      await RevenueCatService.logOut();
      await _authRepository.logout();
      await Future.delayed(const Duration(milliseconds: 500));
      state = AuthState(
        isManualLogout: true,
        logoutReason: LogoutReason.manual,
        showLogoutToast: showToast,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: userFacingError(e));
    }
  }

  Future<void> logoutLocal(WidgetRef ref, {bool showToast = true}) async {
    resetManagerTabIndex(ref);
    resetResidentTabIndex(ref);
    ref.read(dioClientProvider).clearResponseCache();
    await invalidateCachesOnLogout(ref);
    await RevenueCatService.logOut();
    await _authRepository.logout();
    await Future.delayed(const Duration(milliseconds: 300));
    state = AuthState(
      isManualLogout: true,
      logoutReason: LogoutReason.manual,
      showLogoutToast: showToast,
    );
  }

  Future<void> logoutRemoteSession(WidgetRef ref) async {
    resetManagerTabIndex(ref);
    resetResidentTabIndex(ref);
    ref.read(dioClientProvider).clearResponseCache();
    await invalidateCachesOnLogout(ref);
    await RevenueCatService.logOut();
    try {
      await _authRepository.logout();
    } catch (_) {
      // Oturum zaten sunucuda kapatılmış olabilir; yerel temizlik yeterli.
    }
    await Future.delayed(const Duration(milliseconds: 300));
    state = const AuthState(
      logoutReason: LogoutReason.otherDevices,
      isManualLogout: false,
      showLogoutToast: true,
    );
  }

  Future<void> logoutAllDevices(WidgetRef ref) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepository.logoutAllDevices();
      ref.read(dioClientProvider).clearResponseCache();
      state = state.copyWith(isLoading: false, clearError: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: userFacingError(e));
    }
  }
}
