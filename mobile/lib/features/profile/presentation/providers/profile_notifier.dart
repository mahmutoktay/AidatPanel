import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/profile_repository.dart';
import 'profile_provider.dart';

class ProfileState {
  final bool isLoading;
  final bool isSaving;
  final UserEntity? user;
  final String? error;

  const ProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.user,
    this.error,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    UserEntity? user,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this._repository, this._ref) : super(const ProfileState());

  final ProfileRepository _repository;
  final Ref _ref;
  bool _loadInFlight = false;

  Future<void> loadProfile() async {
    if (_loadInFlight) return;

    final cachedUser = _ref.read(authStateProvider).user;
    final hasDisplayUser = state.user != null || cachedUser != null;

    _loadInFlight = true;
    state = state.copyWith(
      isLoading: !hasDisplayUser,
      user: state.user ?? cachedUser,
      clearError: true,
    );
    try {
      final user = await _repository.getProfile();
      await _ref.read(authStateProvider.notifier).syncCachedUser(user);
      state = state.copyWith(isLoading: false, user: user, clearError: true);
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: userFacingError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: userFacingError(e),
      );
    } finally {
      _loadInFlight = false;
    }
  }

  Future<bool> saveProfile({
    required String name,
    String? phone,
  }) async {
    if (state.isSaving) return false;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final user = await _repository.updateProfile(name: name, phone: phone);
      await _ref.read(authStateProvider.notifier).syncCachedUser(user);
      state = state.copyWith(isSaving: false, user: user, clearError: true);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: userFacingError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: userFacingError(e),
      );
      return false;
    }
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(
    ref.watch(profileRepositoryProvider),
    ref,
  );
});
