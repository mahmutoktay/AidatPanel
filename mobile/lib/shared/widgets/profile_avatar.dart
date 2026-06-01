import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/profile/domain/profile_photo_ref.dart';
import '../../features/profile/presentation/providers/profile_photo_provider.dart';

/// Profil fotoğrafı — backend yokken kullanıcıya özel yerel kayıt.
class ProfileAvatar extends ConsumerWidget {
  final String userName;
  final double size;
  final double borderWidth;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    required this.userName,
    required this.size,
    this.borderWidth = AppSizes.cardBorderWidth,
    this.onTap,
  });

  String get _initials {
    final parts =
        userName.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoState = ref.watch(profilePhotoProvider);
    final fontSize = size * 0.34;

    Widget avatarBody;
    if (photoState.isLoading) {
      avatarBody = Center(
        child: SizedBox(
          width: size * 0.35,
          height: size * 0.35,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else if (photoState.hasPhoto) {
      avatarBody = _buildPhoto(photoState.photoRef!);
    } else {
      avatarBody = Center(
        child: Text(
          _initials,
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final avatar = Container(
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
      child: avatarBody,
    );

    if (onTap == null) return avatar;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatar,
      ),
    );
  }

  Widget _buildPhoto(String photoRef) {
    if (ProfilePhotoRef.isAsset(photoRef)) {
      return Image.asset(
        ProfilePhotoRef.assetPath(photoRef),
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }
    if (ProfilePhotoRef.isFile(photoRef)) {
      final file = File(ProfilePhotoRef.filePath(photoRef));
      if (!file.existsSync()) {
        return Center(
          child: Text(
            _initials,
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
              fontSize: size * 0.34,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }
      return Image.file(
        file,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }
    return const SizedBox.shrink();
  }
}
