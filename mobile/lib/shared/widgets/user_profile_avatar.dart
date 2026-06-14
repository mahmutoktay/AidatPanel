import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/profile/domain/profile_photo_ref.dart';
import '../../features/profile/presentation/providers/profile_photo_provider.dart';

String _initialsFromName(String name) {
  final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
}

/// Kullanıcıya özel profil fotoğrafı veya baş harfler — sakin listesi vb.
class UserProfileAvatar extends ConsumerWidget {
  final String? userId;
  final String userName;
  final double size;
  final double borderWidth;
  final bool isVacant;

  const UserProfileAvatar({
    super.key,
    this.userId,
    required this.userName,
    this.size = 48,
    this.borderWidth = AppSizes.cardBorderWidth,
    this.isVacant = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isVacant || userId == null || userId!.isEmpty) {
      return _VacantAvatar(size: size, borderWidth: borderWidth);
    }

    final photoAsync = ref.watch(userProfilePhotoRefProvider(userId!));
    final photoRef = photoAsync.value;

    Widget body;
    if (photoRef != null && photoRef.isNotEmpty) {
      body = _PhotoContent(photoRef: photoRef, userName: userName, size: size);
    } else {
      body = _InitialsContent(userName: userName, size: size);
    }

    return _AvatarFrame(size: size, borderWidth: borderWidth, child: body);
  }
}

class _AvatarFrame extends StatelessWidget {
  const _AvatarFrame({
    required this.size,
    required this.borderWidth,
    required this.child,
  });

  final double size;
  final double borderWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.fill,
        border: Border.fromBorderSide(
          AppColors.cardBorderSide.copyWith(width: borderWidth),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _VacantAvatar extends StatelessWidget {
  const _VacantAvatar({
    required this.size,
    required this.borderWidth,
  });

  final double size;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return _AvatarFrame(
      size: size,
      borderWidth: borderWidth,
      child: Center(
        child: Icon(
          Icons.meeting_room_outlined,
          size: size * 0.55,
          color: AppColors.textSecondary.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

class _InitialsContent extends StatelessWidget {
  const _InitialsContent({required this.userName, required this.size});

  final String userName;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _initialsFromName(userName),
        style: AppTypography.body1.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}

class _PhotoContent extends StatelessWidget {
  const _PhotoContent({
    required this.photoRef,
    required this.userName,
    required this.size,
  });

  final String photoRef;
  final String userName;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (ProfilePhotoRef.isAsset(photoRef)) {
      return Image.asset(
        ProfilePhotoRef.assetPath(photoRef),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            _InitialsContent(userName: userName, size: size),
      );
    }
    if (ProfilePhotoRef.isFile(photoRef)) {
      final file = File(ProfilePhotoRef.filePath(photoRef));
      if (!file.existsSync()) {
        return _InitialsContent(userName: userName, size: size);
      }
      return Image.file(
        file,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            _InitialsContent(userName: userName, size: size),
      );
    }
    return _InitialsContent(userName: userName, size: size);
  }
}
