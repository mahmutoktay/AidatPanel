import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/strings.g.dart';

/// Yakalanmamış bir build-time hatasında Flutter'ın varsayılan kıpkırmızı
/// `ErrorWidget`'ı yerine basılır. Hem debug hem release modda çalışır.
///
/// - **Release** modda kullanıcıya teknik mesaj gösterilmez (CLAUDE.md kuralı).
/// - **Debug** modda geliştiricinin görmesi için exception'ın `toString()`'i
///   küçük puntoyla altta gösterilir (kullanıcı için olmadığı etiketi var).
class FriendlyErrorScreen extends StatelessWidget {
  final FlutterErrorDetails details;

  const FriendlyErrorScreen({super.key, required this.details});

  _ErrorCopy _copy(BuildContext context) {
    final ex = details.exception;
    final t = context.t.common.friendlyError;
    if (ex is NetworkException) {
      return _ErrorCopy(
        icon: Icons.wifi_off_rounded,
        title: t.networkTitle,
        message: t.networkMessage,
      );
    }
    if (ex is UnauthorizedException) {
      return _ErrorCopy(
        icon: Icons.lock_outline_rounded,
        title: t.unauthorizedTitle,
        message: t.unauthorizedMessage,
      );
    }
    if (ex is ServerException) {
      return _ErrorCopy(
        icon: Icons.cloud_off_rounded,
        title: t.serverTitle,
        message: t.serverMessage,
      );
    }
    return _ErrorCopy(
      icon: Icons.error_outline,
      title: t.genericTitle,
      message: t.genericMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = _copy(context);
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        child: Padding(
          padding: AppSizes.screenBodyScrollPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.fill,
                  shape: BoxShape.circle,
                ),
                child: Icon(copy.icon, color: AppColors.textPrimary, size: 44),
              ),
              const SizedBox(height: AppSizes.spacingL),
              Text(
                copy.title,
                style: AppTypography.h2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spacingS),
              Text(
                copy.message,
                style: AppTypography.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (kDebugMode) ...[
                const SizedBox(height: AppSizes.spacingL),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.spacingM),
                  decoration: BoxDecoration(
                    color: AppColors.fill,
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    border: AppColors.cardBorder,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t.common.friendlyError.debugOnlyLabel,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        details.exceptionAsString(),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCopy {
  final IconData icon;
  final String title;
  final String message;

  const _ErrorCopy({
    required this.icon,
    required this.title,
    required this.message,
  });
}
