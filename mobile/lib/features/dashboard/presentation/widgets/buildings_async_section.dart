import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../buildings/domain/entities/building_entity.dart';

class BuildingsAsyncSection extends StatelessWidget {
  final AsyncValue<List<BuildingEntity>> buildingsAsync;
  final VoidCallback onRetry;
  final List<Widget> Function(List<BuildingEntity>) buildList;

  const BuildingsAsyncSection({
    super.key,
    required this.buildingsAsync,
    required this.onRetry,
    required this.buildList,
  });

  @override
  Widget build(BuildContext context) {
    return buildingsAsync.when(
      data: (list) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buildList(list),
      ),
      loading: () {
        final cached = buildingsAsync.value;
        if (cached != null && cached.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: buildList(cached),
          );
        }
        return const _BuildingsLoadingPlaceholder();
      },
      error: (err, _) => _BuildingsErrorPlaceholder(
        message: userFacingError(err),
        onRetry: onRetry,
      ),
    );
  }
}

class _BuildingsLoadingPlaceholder extends StatelessWidget {
  const _BuildingsLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTypography.body2.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w500,
    );
    final placeholderHeight = MediaQuery.of(context).size.height * 0.32;
    return SizedBox(
      width: double.infinity,
      height: placeholderHeight,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spacingS),
            Text(context.t.common.loadingBuildings, style: textStyle),
          ],
        ),
      ),
    );
  }
}

class _BuildingsErrorPlaceholder extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _BuildingsErrorPlaceholder({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacingM,
        AppSizes.spacingL,
        AppSizes.spacingM,
        AppSizes.spacingL,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: AppColors.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 28),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: Text(
                  context.t.common.loadFailed,
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            message,
            style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.spacingM),
          SizedBox(
            height: AppSizes.buttonHeightSecondary,
            child: ElevatedButton.icon(
               onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 20),
              label: Text(context.t.common.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.actionButton,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
