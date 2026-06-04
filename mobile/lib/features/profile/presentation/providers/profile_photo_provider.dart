import 'package:flutter_riverpod/legacy.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/profile_photo_ref.dart';

class ProfilePhotoState {
  final String? userId;
  final String? photoRef;
  final bool isLoading;

  const ProfilePhotoState({
    this.userId,
    this.photoRef,
    this.isLoading = true,
  });

  bool get hasPhoto => photoRef != null && photoRef!.isNotEmpty;

  ProfilePhotoState copyWith({
    String? userId,
    String? photoRef,
    bool? isLoading,
    bool clearPhoto = false,
  }) {
    return ProfilePhotoState(
      userId: userId ?? this.userId,
      photoRef: clearPhoto ? null : (photoRef ?? this.photoRef),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProfilePhotoNotifier extends StateNotifier<ProfilePhotoState> {
  ProfilePhotoNotifier(this._storage) : super(const ProfilePhotoState());

  final SecureStorage _storage;

  Future<void> syncForUser(String? userId) async {
    if (userId == null || userId.isEmpty) {
      state = const ProfilePhotoState(isLoading: false);
      return;
    }
    state = state.copyWith(userId: userId, isLoading: true);
    final ref = await _storage.getProfilePhotoRef(userId);
    state = ProfilePhotoState(userId: userId, photoRef: ref, isLoading: false);
  }

  Future<void> saveBundledDefault() async {
    final userId = state.userId;
    if (userId == null) return;
    final ref = ProfilePhotoRef.bundledDefault();
    await _storage.setProfilePhotoRef(userId, ref);
    state = state.copyWith(photoRef: ref, isLoading: false);
  }

  Future<void> clearPhoto() async {
    final userId = state.userId;
    if (userId == null) return;
    await _storage.removeProfilePhotoRef(userId);
    state = state.copyWith(clearPhoto: true, isLoading: false);
  }
}

final profilePhotoProvider =
    StateNotifierProvider<ProfilePhotoNotifier, ProfilePhotoState>((ref) {
  final notifier = ProfilePhotoNotifier(ref.watch(secureStorageProvider));
  ref.listen(authStateProvider, (previous, next) {
    if (previous?.user?.id != next.user?.id) {
      notifier.syncForUser(next.user?.id);
    }
  });
  Future.microtask(() {
    notifier.syncForUser(ref.read(authStateProvider).user?.id);
  });
  return notifier;
});
