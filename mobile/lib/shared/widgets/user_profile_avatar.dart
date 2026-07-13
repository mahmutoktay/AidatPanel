import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';

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
  final String? profilePicture;

  const UserProfileAvatar({
    super.key,
    this.userId,
    required this.userName,
    this.size = 48,
    this.borderWidth = AppSizes.cardBorderWidth,
    this.isVacant = false,
    this.profilePicture,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isVacant || userName.trim().isEmpty) {
      return _VacantAvatar(size: size, borderWidth: borderWidth);
    }

    final hasPicture = profilePicture != null && profilePicture!.isNotEmpty;

    Widget body;
    if (hasPicture) {
      body = CachedNetworkImage(
        imageUrl: '${ApiConstants.baseUrl}/uploads/avatars/$profilePicture',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) =>
            _InitialsContent(userName: userName, size: size),
        placeholder: (context, url) => Center(
          child: SizedBox(
            width: size * 0.35,
            height: size * 0.35,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
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
  const _VacantAvatar({required this.size, required this.borderWidth});

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
          color: AppColors.brand,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}
