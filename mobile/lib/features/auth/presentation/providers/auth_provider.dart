import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/providers/cache_invalidator.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart'
    show AuthRepository, AuthRepositoryImpl;
import '../../domain/entities/user_entity.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../core/utils/input_validators.dart';

/// Oturum sonlandığında callback almak için global değişken.
/// DioClient > TokenRefreshService token yenileyemezse bu callback tetiklenir.
/// AuthNotifier kurulumda bu callback'i kendine bağlar.
typedef SessionExpiredCallback = void Function();
SessionExpiredCallback? onSessionExpired;

final secureStorageProvider = Provider((ref) => SecureStorage());

final dioClientProvider = Provider((ref) {
  return DioClient(
    secureStorage: ref.watch(secureStorageProvider),
    // Getter olarak iletilir: çağrı anında güncel değer alınır.
    onSessionExpiredGetter: () => onSessionExpired,
  );
});

final authRemoteDataSourceProvider = Provider((ref) {
  return AuthRemoteDataSourceImpl(dioClient: ref.watch(dioClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

enum LogoutReason { manual, otherDevices }

class AuthState {
  final LogoutReason? logoutReason;
  final bool isLoading;
  final UserEntity? user;
  final String? error;
  final bool isAuthenticated;
  final bool registrationSuccess;
  final bool isManualLogout;

  const AuthState({
    this.logoutReason,
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
    this.registrationSuccess = false,
    this.isManualLogout = false,
  });

  AuthState copyWith({
    LogoutReason? logoutReason,
    bool? isLoading,
    UserEntity? user,
    String? error,
    bool? isAuthenticated,
    bool? registrationSuccess,
    bool? isManualLogout,
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
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState()) {
    // Oturum sonlanınca (başka cihazdan çıkış, refresh başarısız vb.)
    // state'i sıfırla ve hata mesajı koy (UI bildirim gösterecek).
    // Not: Dil bağımsız mesaj l10n dosyasında; burada yedek olarak İngilizce
    // kullanılır, app_router.dart l10n sürümünü gösterir.
    onSessionExpired = () {
      state = const AuthState(
        logoutReason: LogoutReason.otherDevices,
        isAuthenticated: false,
        isManualLogout: false,
      );
    };
  }

  Future<void> submitLogin(
    String rawIdentifier,
    String password,
    bool isPhone,
    WidgetRef ref,
  ) async {
    if (state.isLoading) return;

    final t = LocaleSettings.instance.currentTranslations;
    String? identifierError;
    String? passwordError;

    if (isPhone) {
      final phoneError = InputValidators.validatePhone(rawIdentifier);
      identifierError = phoneError == null
          ? null
          : phoneError == 'phone_required'
              ? t.validation.phoneRequired
              : t.validation.phoneInvalid;
    } else {
      final emailError = InputValidators.validateEmail(rawIdentifier);
      identifierError = emailError == null
          ? null
          : emailError == 'email_required'
              ? t.validation.emailRequired
              : emailError == 'email_invalid'
                  ? t.validation.emailInvalid
                  : t.validation.emailTooLong;
    }

    passwordError = password.isEmpty ? t.features.auth.passwordRequired : null;

    if (identifierError != null || passwordError != null) {
      String errorMessage = '';
      if (identifierError != null) errorMessage += identifierError;
      if (passwordError != null) {
        if (errorMessage.isNotEmpty) errorMessage += '\n';
        errorMessage += passwordError;
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return;
    }

    final identifier = isPhone ? '+90${rawIdentifier.trim()}' : rawIdentifier.trim();
    await login(identifier, password, ref);
  }

  /// `identifier` email **veya** telefon (Belge §3).
  Future<void> login(String identifier, String password, WidgetRef ref) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authRepository.login(identifier, password);
      // Reset tab index on successful login
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
    String email,
    String password,
    String name,
    String? phone,
  ) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepository.register(email, password, name, phone);
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
      final user = await _authRepository.join(
        inviteCode,
        email,
        password,
        name,
        phone,
      );
      // Reset tab index on successful join
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

  Future<void> _onAuthenticated(WidgetRef ref, UserEntity user) async {
    final previousId = state.user?.id;
    ref.read(dioClientProvider).clearResponseCache();
    if (previousId != null && previousId != user.id) {
      await clearDekontPreviewsOnUserSwitch(ref);
    }
    invalidateAllCachedProviders(ref);
  }

  /// Uygulama açılışında SecureStorage'daki oturumu geri yükler.
  /// Splash bu future'ı bekleyip ardından yönlendirme yapar.
  /// Profil / dil güncellemesi sonrası oturum kullanıcısını ve önbelleği senkronlar.
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
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
          clearError: true,
        );
      } else {
        state = AuthState();
      }
    } catch (_) {
      state = AuthState();
    }
  }

  Future<void> logout(WidgetRef ref) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Reset tab index on logout
      resetManagerTabIndex(ref);
      resetResidentTabIndex(ref);
      ref.read(dioClientProvider).clearResponseCache();
      await invalidateCachesOnLogout(ref);
      await _authRepository.logout();
      await Future.delayed(const Duration(milliseconds: 500));
      state = AuthState(isManualLogout: true, logoutReason: LogoutReason.manual);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: userFacingError(e));
    }
  }

  Future<void> logoutLocal(WidgetRef ref) async {
    resetManagerTabIndex(ref);
    resetResidentTabIndex(ref);
    ref.read(dioClientProvider).clearResponseCache();
    await invalidateCachesOnLogout(ref);
    await _authRepository.logout();
    await Future.delayed(const Duration(milliseconds: 300));
    state = const AuthState(isManualLogout: true, logoutReason: LogoutReason.manual);
  }

  /// Tüm cihazların oturumunu kapatır ve bu cihazı da Login ekranına düşürür.
  Future<void> logoutAllDevices(WidgetRef ref) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepository.logoutAllDevices();
      await logoutLocal(ref);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: userFacingError(e));
    }
  }
}
