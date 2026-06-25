import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../data/sites_store.dart';
import 'site_list_card.dart';

class ManagerSitesTab extends ConsumerWidget {
  const ManagerSitesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sitesAsync = ref.watch(sitesStoreProvider);
    final sites = sitesAsync.value ?? const [];
    final t = context.t.features.sites;
    final isRefreshing = sitesAsync.isLoading && sites.isNotEmpty;

    return RefreshIndicator(
      onRefresh: () => ref.read(sitesStoreProvider.notifier).loadSites(),
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: AppSizes.screenBodyScrollPadding.copyWith(
              top: AppSizes.spacingS,
              bottom: 0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  t.mySites,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.inkDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                if (isRefreshing) ...[
                  const SizedBox(height: AppSizes.spacingS),
                  LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: AppColors.lineLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.statusBlue,
                    ),
                  ),
                ],
                const SizedBox(height: AppSizes.spacingM),
              ]),
            ),
          ),
          if (sitesAsync.isLoading && sites.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (sitesAsync.hasError && sites.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: AppSizes.screenBodyScrollPadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.t.common.loadFailed,
                        style: AppTypography.h4,
                      ),
                      const SizedBox(height: AppSizes.spacingS),
                      Text(
                        userFacingError(sitesAsync.error!),
                        textAlign: TextAlign.center,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingM),
                      FilledButton(
                        onPressed: () =>
                            ref.read(sitesStoreProvider.notifier).loadSites(),
                        child: Text(context.t.common.tryAgain),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (sites.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  t.emptySites,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: AppSizes.screenBodyScrollPadding.copyWith(top: 0),
              sliver: SliverList.builder(
                itemCount: sites.length,
                itemBuilder: (context, index) {
                  final site = sites[index];
                  return SiteListCard(
                    site: site,
                    onTap: () => context.push(
                      '/manager-dashboard/sites/${site.id}',
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
