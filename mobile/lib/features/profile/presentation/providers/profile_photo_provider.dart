import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class ProfilePhotoNotifier extends Notifier<ProfilePhotoState> {
  SecureStorage get _storage => ref.read(secureStorageProvider);

  @override
  ProfilePhotoState build() {
    ref.listen(authStateProvider, (previous, next) {
      if (previous?.user?.id != next.user?.id) {
        unawaited(syncForUser(next.user?.id));
      }
    });
    Future.microtask(() => syncForUser(ref.read(authStateProvider).user?.id));
    return const ProfilePhotoState();
  }

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
    NotifierProvider<ProfilePhotoNotifier, ProfilePhotoState>(
  ProfilePhotoNotifier.new,
);

/// Herhangi bir kullanıcının yerel profil fotoğrafı referansı (sakin listesi vb.).
final userProfilePhotoRefProvider =
    FutureProvider.family<String?, String>((ref, userId) async {
  if (userId.isEmpty) return null;
  return ref.read(secureStorageProvider).getProfilePhotoRef(userId);
});
