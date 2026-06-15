import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/profile/presentation/providers/profile_notifier.dart';

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
    final user = ref.watch(authStateProvider).user;
    final profileState = ref.watch(profileNotifierProvider);
    final fontSize = size * 0.34;

    Widget avatarBody;

    if (profileState.isSaving) {
      avatarBody = Center(
        child: SizedBox(
          width: size * 0.35,
          height: size * 0.35,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else if (user != null &&
        user.profilePicture != null &&
        user.profilePicture!.isNotEmpty) {
      avatarBody = Image.network(
        '${ApiConstants.baseUrl}/uploads/avatars/${user.profilePicture}',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Text(
            _initials,
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: size * 0.35,
              height: size * 0.35,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
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
}
