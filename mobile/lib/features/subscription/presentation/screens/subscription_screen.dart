import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/subscription/revenue_cat_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/subscription_entity.dart';
import '../providers/subscription_provider.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  final VoidCallback onBuyMonthly;
  final VoidCallback onBuyYearly;

  const SubscriptionScreen({
    super.key,
    required this.onBuyMonthly,
    required this.onBuyYearly,
  });

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionNotifierProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final authUser = ref.watch(authStateProvider.select((state) => state.user));
    final t = context.t.features.subscription;

    ref.listen<SubscriptionState>(subscriptionNotifierProvider, (
      previous,
      next,
    ) {
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        final msg = _resolveMessage(context, next.successMessage!);
        ref.read(toastProvider.notifier).show(msg, type: ToastType.success);
      }
      if (next.purchaseError != null &&
          next.purchaseError != previous?.purchaseError) {
        final msg = _resolveMessage(context, next.purchaseError!);
        ref.read(toastProvider.notifier).show(msg, type: ToastType.error);
      }
      if (next.error != null && next.error != previous?.error) {
        final msg = _resolveMessage(context, next.error!);
        ref.read(toastProvider.notifier).show(msg, type: ToastType.error);
      }
    });

    if (subscriptionState.isLoading && subscriptionState.subscription == null) {
      return DashboardSecondaryScaffold(
        title: t.title,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: AppSizes.spacingM),
              Text(
                t.loadingPlans,
                style: AppTypography.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final subscription = subscriptionState.subscription;
    final prices = subscriptionState.storePrices;
    final purchasesEnabled = subscriptionState.purchasesEnabled;

    int? daysLeft;
    if (subscription != null && subscription.currentPeriodEnd != null) {
      final diff = subscription.currentPeriodEnd!
          .difference(DateTime.now())
          .inDays;
      daysLeft = diff > 0 ? diff : 0;
    }

    final savingsAmount = prices.savingsAmount;
    final savingsLabel = savingsAmount != null
        ? t.savingBadge.replaceAll(
            '{amount}',
            _formatMoney(context, savingsAmount, prices),
          )
        : null;
    final originalPrice = prices.annualEquivalentAmount != null
        ? _formatMoney(context, prices.annualEquivalentAmount!, prices)
        : null;

    final monthlyPrice = prices.monthlyPriceString ?? t.priceUnavailable;
    final annualPrice = prices.annualPriceString ?? t.priceUnavailable;

    final features = [
      (true, t.featureUnlimitedUnits),
      (true, t.featureDuesTracking),
      (false, t.featureAdvancedReports),
      (false, t.featurePrioritySupport),
    ];
    final annualFeatures = [
      (true, t.featureUnlimitedUnits),
      (true, t.featureDuesTracking),
      (true, t.featureAdvancedReports),
      (true, t.featurePrioritySupport),
    ];

    return DashboardSecondaryScaffold(
      title: t.title,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () =>
                    ref.read(subscriptionNotifierProvider.notifier).load(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileRow(
                        user: authUser,
                        daysLeft: daysLeft,
                        status: subscription?.status,
                      ),
                      _StatusStrip(subscription: subscription),
                      if (subscription?.usage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            subscription!.limits?.buildings != null
                                ? t.buildingUsageWithLimit
                                    .replaceAll(
                                      '{used}',
                                      '${subscription.usage!.buildings}',
                                    )
                                    .replaceAll(
                                      '{limit}',
                                      '${subscription.limits!.buildings}',
                                    )
                                : t.buildingUsageSummary.replaceAll(
                                    '{used}',
                                    '${subscription.usage!.buildings}',
                                  ),
                            style: AppTypography.body1.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      if (!purchasesEnabled && !subscriptionState.isPurchasing)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            t.purchasesDisabledHint,
                            style: AppTypography.body1.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      _SectionLabel(label: t.sectionSelectPlan),
                      _PlanCard(
                        isYearly: false,
                        planName: t.planMonthly,
                        cycle: t.cycleMonthly,
                        priceDisplay: monthlyPrice,
                        vatNote: t.priceExclVatMonth,
                        features: features,
                        isPurchasing: subscriptionState.isPurchasing,
                        purchasesEnabled: purchasesEnabled,
                        ctaLabel: t.purchaseMonthlyCta,
                        onBuy: widget.onBuyMonthly,
                      ),
                      const SizedBox(height: 10),
                      _PlanCard(
                        isYearly: true,
                        planName: t.planAnnual,
                        cycle: t.cycleAnnual,
                        priceDisplay: annualPrice,
                        vatNote: t.priceExclVatYear,
                        savingLabel: savingsLabel,
                        originalPrice: originalPrice,
                        badgeLabel: t.bestValueBadge,
                        features: annualFeatures,
                        isPurchasing: subscriptionState.isPurchasing,
                        purchasesEnabled: purchasesEnabled,
                        ctaLabel: t.purchaseAnnualCta,
                        onBuy: widget.onBuyYearly,
                      ),
                      _KdvNote(text: t.kdvNote),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ],
        ),
      ),
    );
  }
}

String _formatMoney(
  BuildContext context,
  double amount,
  SubscriptionStorePrices prices,
) {
  final locale = Localizations.localeOf(context).toString();
  final symbol =
      prices.monthlyPriceString?.contains('₺') == true ||
          prices.annualPriceString?.contains('₺') == true ||
          prices.currencyCode == 'TRY'
      ? '₺'
      : '';
  return NumberFormat.currency(
    locale: locale,
    symbol: symbol,
    decimalDigits: 0,
  ).format(amount);
}

class _ProfileRow extends StatelessWidget {
  final UserEntity? user;
  final int? daysLeft;
  final SubscriptionStatus? status;

  const _ProfileRow({
    required this.user,
    required this.daysLeft,
    required this.status,
  });

  String _getInitials(String userName) {
    final parts = userName
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  Widget _buildInitialsText(String userName) {
    return Text(
      _getInitials(userName),
      style: AppTypography.body1.copyWith(
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.subscription;
    final displayName = user?.name ?? t.guestUser;
    final String? imageUrl =
        user?.profilePicture != null && user!.profilePicture!.isNotEmpty
        ? '${ApiConstants.baseUrl}/uploads/avatars/${user!.profilePicture}'
        : null;

    final String userStatus;
    switch (status) {
      case SubscriptionStatus.trial:
        userStatus = t.trialActive;
      case SubscriptionStatus.active:
        userStatus = t.subscriptionActive;
      case SubscriptionStatus.cancelled:
        userStatus = t.subscriptionCancelled;
      case SubscriptionStatus.expired:
        userStatus = t.subscriptionExpired;
      default:
        userStatus = t.noActiveSubscription;
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              shape: BoxShape.circle,
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    )
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: imageUrl != null ? null : _buildInitialsText(displayName),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userStatus,
                  style: AppTypography.small.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (daysLeft != null &&
              daysLeft! > 0 &&
              status == SubscriptionStatus.trial)
            Container(
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    t.daysLeft.replaceAll('{count}', daysLeft!.toString()),
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusStrip extends StatelessWidget {
  final SubscriptionEntity? subscription;

  const _StatusStrip({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.subscription;

    final String planValue;
    if (subscription != null && subscription!.hasRecord) {
      final plan = subscription!.plan.toLowerCase();
      if (plan.contains('annual') || plan.contains('year')) {
        planValue = t.planAnnualShort;
      } else if (plan.contains('month')) {
        planValue = t.planMonthlyShort;
      } else {
        planValue = subscription!.plan;
      }
    } else {
      planValue = t.priceUnavailable;
    }

    final String statusValue;
    final Color statusColor;
    if (subscription != null && subscription!.hasRecord) {
      switch (subscription!.status) {
        case SubscriptionStatus.trial:
          statusValue = t.statusTrial;
          statusColor = AppColors.success;
        case SubscriptionStatus.active:
          statusValue = t.statusActive;
          statusColor = AppColors.success;
        case SubscriptionStatus.cancelled:
          statusValue = t.statusCancelled;
          statusColor = AppColors.textPrimary;
        case SubscriptionStatus.expired:
          statusValue = t.statusExpired;
          statusColor = AppColors.textPrimary;
        default:
          statusValue = t.statusUnknown;
          statusColor = AppColors.textPrimary;
      }
    } else {
      statusValue = t.priceUnavailable;
      statusColor = AppColors.textPrimary;
    }

    final String renewalValue;
    if (subscription != null && subscription!.currentPeriodEnd != null) {
      renewalValue = AppDateFormat.yearMonthDay(
        subscription!.currentPeriodEnd!,
      );
    } else {
      renewalValue = t.priceUnavailable;
    }

    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x12000000), width: 0.5),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatusItem(
                label: t.planLabel,
                value: planValue,
                valueColor: AppColors.textPrimary,
              ),
            ),
            Container(width: 0.5, color: const Color(0x14000000)),
            Expanded(
              child: _StatusItem(
                label: t.statusLabel,
                value: statusValue,
                valueColor: statusColor,
              ),
            ),
            Container(width: 0.5, color: const Color(0x14000000)),
            Expanded(
              child: _StatusItem(
                label: t.renewalLabel,
                value: renewalValue,
                valueColor: AppColors.textPrimary,
                compact: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool compact;

  const _StatusItem({
    required this.label,
    required this.value,
    required this.valueColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: compact ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.small.copyWith(
            fontSize: compact ? 14 : 16,
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 12,
            color: AppColors.textDisabled,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textDisabled,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final bool isYearly;
  final String planName;
  final String cycle;
  final String priceDisplay;
  final String vatNote;
  final String? savingLabel;
  final String? originalPrice;
  final String? badgeLabel;
  final List<(bool active, String text)> features;
  final bool isPurchasing;
  final bool purchasesEnabled;
  final String ctaLabel;
  final VoidCallback onBuy;

  const _PlanCard({
    required this.isYearly,
    required this.planName,
    required this.cycle,
    required this.priceDisplay,
    required this.vatNote,
    this.savingLabel,
    this.originalPrice,
    this.badgeLabel,
    required this.features,
    required this.isPurchasing,
    required this.purchasesEnabled,
    required this.ctaLabel,
    required this.onBuy,
  });

  bool get _canPurchase => purchasesEnabled && !isPurchasing;

  @override
  Widget build(BuildContext context) {
    const darkCard = Color(0xFF1A1A2E);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isYearly ? darkCard : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isYearly ? darkCard : const Color(0x14000000),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _canPurchase ? onBuy : null,
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: isYearly ? 8 : 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: !isYearly
                                          ? AppColors.dashboardBackground
                                          : const Color(0x1AFFFFFF),
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      !isYearly
                                          ? Icons.calendar_month_outlined
                                          : Icons.workspace_premium_outlined,
                                      color: !isYearly
                                          ? darkCard
                                          : const Color(0xCCFFFFFF),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          planName,
                                          style: AppTypography.body1.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: isYearly
                                                ? Colors.white
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          cycle,
                                          style: AppTypography.small.copyWith(
                                            color: isYearly
                                                ? const Color(0x99FFFFFF)
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  priceDisplay,
                                  style: AppTypography.h2.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: isYearly
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  vatNote,
                                  style: AppTypography.caption.copyWith(
                                    color: isYearly
                                        ? const Color(0x80FFFFFF)
                                        : AppColors.textDisabled,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isYearly && savingLabel != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(74, 222, 128, 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.bolt_rounded,
                                    size: 14,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    savingLabel!,
                                    style: AppTypography.caption.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (originalPrice != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                originalPrice!,
                                style: AppTypography.caption.copyWith(
                                  color: const Color(0x66FFFFFF),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          thickness: 0.5,
                          height: 0.5,
                          color: !isYearly
                              ? const Color(0x12000000)
                              : const Color(0x14FFFFFF),
                        ),
                      ),
                      ...features.map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _FeatureRow(
                            active: feature.$1,
                            text: feature.$2,
                            isYearly: isYearly,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: AppSizes.buttonHeightSecondary,
                        child: ElevatedButton(
                          onPressed: _canPurchase ? onBuy : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isYearly ? Colors.white : darkCard,
                            foregroundColor: isYearly ? darkCard : Colors.white,
                            disabledBackgroundColor: isYearly
                                ? Colors.white.withValues(alpha: 0.5)
                                : darkCard.withValues(alpha: 0.5),
                            disabledForegroundColor: isYearly
                                ? darkCard.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isPurchasing
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: isYearly ? darkCard : Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isYearly
                                          ? Icons.workspace_premium_outlined
                                          : Icons.credit_card_outlined,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        ctaLabel,
                                        style: AppTypography.button.copyWith(
                                          color: isYearly
                                              ? darkCard
                                              : Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isYearly && badgeLabel != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ADE80),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(18),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            size: 14,
                            color: Color(0xFF14532D),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            badgeLabel!,
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF14532D),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final bool active;
  final String text;
  final bool isYearly;

  const _FeatureRow({
    required this.active,
    required this.text,
    required this.isYearly,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = active
        ? (isYearly ? Color(0xB3FFFFFF) : AppColors.textPrimary)
        : (isYearly ? const Color(0x33FFFFFF) : const Color(0x33000000));
    final textColor = active
        ? (isYearly ? Color(0xC0FFFFFF) : AppColors.textPrimary)
        : (isYearly ? Color(0x66FFFFFF) : AppColors.textDisabled);

    return Row(
      children: [
        Icon(
          active ? Icons.check_rounded : Icons.close_rounded,
          size: 18,
          color: iconColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTypography.small.copyWith(color: textColor),
          ),
        ),
      ],
    );
  }
}

class _KdvNote extends StatelessWidget {
  final String text;

  const _KdvNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(color: AppColors.textDisabled),
        ),
      ),
    );
  }
}

String _resolveMessage(BuildContext context, String key) {
  final t = context.t;
  switch (key) {
    case 'purchase_success':
      return t.features.subscription.purchaseSuccess;
    case 'purchase_cancelled':
      return t.features.subscription.purchaseCancelled;
    case 'purchases_unavailable':
      return t.features.subscription.purchasesUnavailable;
    case 'subscription_load_failed':
      return t.features.subscription.loadFailed;
    case 'purchase_product_not_found':
      return t.features.subscription.purchaseProductNotFound;
    case 'purchase_store_error':
      return t.features.subscription.purchaseStoreError;
    case 'purchase_failed':
      return t.features.subscription.purchaseFailed;
    default:
      return key;
  }
}
