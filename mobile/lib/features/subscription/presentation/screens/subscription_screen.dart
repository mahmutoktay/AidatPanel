import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/subscription_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../domain/entities/subscription_entity.dart';
import '../providers/subscription_provider.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  final VoidCallback onBuyBasicMonthly;
  final VoidCallback onBuyBasicAnnual;
  final VoidCallback onBuyBusinessMonthly;
  final VoidCallback onBuyBusinessAnnual;

  const SubscriptionScreen({
    super.key,
    required this.onBuyBasicMonthly,
    required this.onBuyBasicAnnual,
    required this.onBuyBusinessMonthly,
    required this.onBuyBusinessAnnual,
  });

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  /// Varsayılan her zaman Aylık.
  bool _isMonthlyTab = true;

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
    final t = context.t.features.subscription;

    ref.listen<SubscriptionState>(subscriptionNotifierProvider, (
      previous,
      next,
    ) {
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        ref.read(toastProvider.notifier).show(
              _resolveMessage(context, next.successMessage!),
              type: ToastType.success,
            );
      }
      if (next.purchaseError != null &&
          next.purchaseError != previous?.purchaseError) {
        ref.read(toastProvider.notifier).show(
              _resolveMessage(context, next.purchaseError!),
              type: ToastType.error,
            );
      }
      if (next.error != null && next.error != previous?.error) {
        ref.read(toastProvider.notifier).show(
              _resolveMessage(context, next.error!),
              type: ToastType.error,
            );
      }
    });

    if (subscriptionState.isLoading && subscriptionState.subscription == null) {
      return DashboardSecondaryScaffold(
        title: t.title,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.brand),
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
    final hasActive = subscription?.isEntitled == true;
    final isBusiness = subscription?.isBusinessPlan == true;
    final isBasic = hasActive && !isBusiness;
    final usedBuildings = subscription?.usage?.buildings ?? 0;
    final buildingLimit = subscription?.limits?.buildings;
    final atBasicQuota = isBasic &&
        buildingLimit != null &&
        usedBuildings >= buildingLimit;
    final nearBasicQuota = isBasic &&
        buildingLimit != null &&
        buildingLimit > 0 &&
        usedBuildings >= (buildingLimit * 0.85).floor() &&
        !atBasicQuota;

    int? daysLeft;
    if (subscription?.currentPeriodEnd != null) {
      final diff =
          subscription!.currentPeriodEnd!.difference(DateTime.now()).inDays;
      daysLeft = diff > 0 ? diff : 0;
    }

    final basicPrice = _isMonthlyTab
        ? _displayPrice(
            amount: prices.monthlyPrice,
            storeString: prices.monthlyPriceString,
            fallback: t.priceFallbackBasicMonthly,
          )
        : _displayPrice(
            amount: prices.annualPrice,
            storeString: prices.annualPriceString,
            fallback: t.priceFallbackBasicAnnual,
          );
    final businessPrice = _isMonthlyTab
        ? _displayPrice(
            amount: prices.businessMonthlyPrice,
            storeString: prices.businessMonthlyPriceString,
            fallback: t.priceFallbackBusinessMonthly,
          )
        : _displayPrice(
            amount: prices.businessAnnualPrice,
            storeString: prices.businessAnnualPriceString,
            fallback: t.priceFallbackBusinessAnnual,
          );

    final currentMatchesBasic = hasActive &&
        !isBusiness &&
        ((_isMonthlyTab && !subscription!.isAnnualPlan) ||
            (!_isMonthlyTab && subscription!.isAnnualPlan));
    final currentMatchesBusiness = hasActive &&
        isBusiness &&
        ((_isMonthlyTab && !subscription!.isAnnualPlan) ||
            (!_isMonthlyTab && subscription!.isAnnualPlan));

    final planTitle = !hasActive
        ? t.noActiveSubscription
        : '${isBusiness ? t.planBusiness : t.planBasic} · '
            '${subscription!.isAnnualPlan ? t.planAnnualShort : t.planMonthlyShort}';

    String statusCaption;
    if (subscription == null || !subscription.isEntitled) {
      statusCaption = t.noActiveSubscription;
    } else if (subscription.isAdminGrant) {
      statusCaption = t.giftBannerTitle;
    } else if (subscription.status == SubscriptionStatus.trial) {
      statusCaption = t.trialActive;
    } else {
      statusCaption = t.subscriptionActive;
    }

    return DashboardSecondaryScaffold(
      title: t.title,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.brand,
          onRefresh: () =>
              ref.read(subscriptionNotifierProvider.notifier).load(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              _PlanHeader(
                planTitle: planTitle,
                statusLabel: statusCaption,
                daysLeft: daysLeft,
                showDays: hasActive && daysLeft != null && daysLeft > 0,
              ),
              if (subscription?.isAdminGrant == true && hasActive)
                _GiftBanner(
                  endDate: subscription!.currentPeriodEnd,
                ),
              _BuildingProgressBar(
                used: usedBuildings,
                limit: buildingLimit ??
                    (hasActive
                        ? (isBusiness
                            ? null
                            : SubscriptionConstants.basicBuildingLimit)
                        : 0),
                label: t.buildingProgress,
                unlimitedLabel: t.buildingUsageUnlimitedShort,
                needSubLabel: t.buildingUsageNeedSubscription,
              ),
              _StatusStrip(subscription: subscription),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  t.compareIntro,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),
              if (!purchasesEnabled && !subscriptionState.isPurchasing)
                _InfoCallout(
                  text: t.purchasesDisabledHint,
                  tone: _CalloutTone.neutral,
                ),
              if (!hasActive)
                _InfoCallout(
                  text: t.noSubCannotAddBuilding,
                  tone: _CalloutTone.neutral,
                ),
              if (atBasicQuota)
                _InfoCallout(
                  text: t.upgradeToBusinessHint,
                  tone: _CalloutTone.warning,
                )
              else if (nearBasicQuota)
                _InfoCallout(
                  text: t.quotaNearHint,
                  tone: _CalloutTone.warning,
                ),
              _PlanToggle(
                isMonthly: _isMonthlyTab,
                monthlyLabel: t.toggleMonthly,
                annualLabel: t.toggleAnnual,
                annualHint: t.annualSaveHint,
                onChanged: (isMonthly) {
                  setState(() => _isMonthlyTab = isMonthly);
                },
              ),
              const SizedBox(height: 16),
              _ComparePlanCard(
                accentBusiness: false,
                icon: Icons.apartment_outlined,
                title: t.planBasic,
                subtitle: t.planBasicSubtitle,
                priceDisplay: basicPrice,
                cycleLabel: _isMonthlyTab ? t.cycleMonthly : t.cycleAnnual,
                vatNote:
                    _isMonthlyTab ? t.priceExclVatMonth : t.priceExclVatYear,
                isCurrentPlan: currentMatchesBasic,
                isRecommended: false,
                featureLabels: [
                  t.featureBasicUpTo20,
                  t.featureDuesTracking,
                  t.featureDekontOcr,
                  t.featurePdfReports,
                ],
                ctaLabel: currentMatchesBasic
                    ? t.ctaCurrentPlan
                    : (isBusiness ? t.ctaAlreadyBusiness : t.ctaSubscribe),
                ctaEnabled: purchasesEnabled &&
                    !subscriptionState.isPurchasing &&
                    !currentMatchesBasic &&
                    !isBusiness,
                isPurchasing: subscriptionState.isPurchasing,
                onBuy: _isMonthlyTab
                    ? widget.onBuyBasicMonthly
                    : widget.onBuyBasicAnnual,
              ),
              const SizedBox(height: 12),
              _ComparePlanCard(
                accentBusiness: true,
                icon: Icons.business_outlined,
                title: t.planBusiness,
                subtitle: t.planBusinessSubtitle,
                priceDisplay: businessPrice,
                cycleLabel: _isMonthlyTab ? t.cycleMonthly : t.cycleAnnual,
                vatNote:
                    _isMonthlyTab ? t.priceExclVatMonth : t.priceExclVatYear,
                isCurrentPlan: currentMatchesBusiness,
                isRecommended: atBasicQuota || nearBasicQuota || !hasActive,
                featureLabels: [
                  t.featureBusinessUnlimited,
                  t.featureDuesTracking,
                  t.featureDekontOcr,
                  t.featurePrioritySupport,
                ],
                ctaLabel: currentMatchesBusiness
                    ? t.ctaCurrentPlan
                    : (isBasic ? t.ctaUpgrade : t.ctaSubscribe),
                ctaEnabled: purchasesEnabled &&
                    !subscriptionState.isPurchasing &&
                    !currentMatchesBusiness,
                isPurchasing: subscriptionState.isPurchasing,
                onBuy: _isMonthlyTab
                    ? widget.onBuyBusinessMonthly
                    : widget.onBuyBusinessAnnual,
              ),
              _KdvNote(text: t.kdvNote),
              SizedBox(height: MediaQuery.paddingOf(context).bottom),
            ],
          ),
        ),
      ),
    );
  }
}

enum _CalloutTone { neutral, warning }

class _InfoCallout extends StatelessWidget {
  final String text;
  final _CalloutTone tone;

  const _InfoCallout({required this.text, required this.tone});

  @override
  Widget build(BuildContext context) {
    final isWarning = tone == _CalloutTone.warning;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isWarning ? AppColors.warningBg : AppColors.fill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isWarning
                ? AppColors.warning.withValues(alpha: 0.35)
                : AppColors.border.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          text,
          style: AppTypography.body1.copyWith(
            color: isWarning ? AppColors.warning : AppColors.textSecondary,
            fontWeight: isWarning ? FontWeight.w600 : FontWeight.w400,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _GiftBanner extends StatelessWidget {
  final DateTime? endDate;

  const _GiftBanner({required this.endDate});

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.subscription;
    final dateText = endDate != null
        ? AppDateFormat.yearMonthDay(endDate!)
        : t.statusUnlimited;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.card_giftcard_rounded, color: AppColors.success, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.giftBannerTitle,
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.giftBannerBody.replaceAll('{date}', dateText),
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
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

class _PlanHeader extends StatelessWidget {
  final String planTitle;
  final String statusLabel;
  final int? daysLeft;
  final bool showDays;

  const _PlanHeader({
    required this.planTitle,
    required this.statusLabel,
    required this.daysLeft,
    required this.showDays,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.subscription;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planTitle,
                  style: AppTypography.h2.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusLabel,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (showDays)
            Container(
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 18,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    t.daysLeft.replaceAll('{count}', daysLeft!.toString()),
                    style: AppTypography.caption.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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

class _BuildingProgressBar extends StatelessWidget {
  final int used;
  final int? limit;
  final String label;
  final String unlimitedLabel;
  final String needSubLabel;

  const _BuildingProgressBar({
    required this.used,
    required this.limit,
    required this.label,
    required this.unlimitedLabel,
    required this.needSubLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.subscription;
    final hasFiniteLimit = limit != null && limit! > 0;
    final isUnlimited = limit == null;
    final needsSubscription = limit == 0;

    final String usageText;
    if (needsSubscription) {
      usageText = needSubLabel.replaceAll('{used}', '$used');
    } else if (isUnlimited) {
      usageText = unlimitedLabel.replaceAll('{used}', '$used');
    } else {
      usageText = t.buildingUsageWithLimit
          .replaceAll('{used}', '$used')
          .replaceAll('{limit}', '$limit');
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (isUnlimited)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    '∞',
                    style: AppTypography.h2.copyWith(
                      fontSize: 28,
                      height: 1,
                      fontWeight: FontWeight.w300,
                      color: AppColors.brand,
                    ),
                  ),
                ),
              Text(
                usageText,
                style: AppTypography.body1.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (hasFiniteLimit)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (used / limit!).clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: AppColors.border.withValues(alpha: 0.35),
                valueColor: AlwaysStoppedAnimation<Color>(
                  (used / limit!) >= 1.0
                      ? AppColors.error
                      : (used / limit!) > 0.85
                          ? AppColors.warning
                          : AppColors.brand,
                ),
              ),
            )
          else if (isUnlimited)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  LinearProgressIndicator(
                    value: 1,
                    minHeight: 10,
                    backgroundColor: AppColors.border.withValues(alpha: 0.35),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.brand.withValues(alpha: 0.35),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          '∞',
                          style: AppTypography.caption.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brand,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0,
                minHeight: 10,
                backgroundColor: AppColors.border.withValues(alpha: 0.35),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.warning,
                ),
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
    final hasReal = subscription?.isEntitled == true;

    final String planValue;
    if (hasReal) {
      final tier =
          subscription!.isBusinessPlan ? t.planBusiness : t.planBasic;
      final cycle =
          subscription!.isAnnualPlan ? t.planAnnualShort : t.planMonthlyShort;
      planValue = '$tier · $cycle';
    } else {
      planValue = t.noActiveSubscription;
    }

    final String statusValue;
    final Color statusColor;
    if (hasReal) {
      switch (subscription!.status) {
        case SubscriptionStatus.trial:
          statusValue = t.statusTrial;
          statusColor = AppColors.success;
        case SubscriptionStatus.active:
          statusValue = subscription!.isAdminGrant
              ? t.sourceGift
              : t.statusActive;
          statusColor = AppColors.success;
        default:
          statusValue = t.statusUnknown;
          statusColor = AppColors.textPrimary;
      }
    } else {
      statusValue = t.noActiveSubscription;
      statusColor = AppColors.textSecondary;
    }

    final String renewalValue;
    if (hasReal && subscription!.currentPeriodEnd != null) {
      renewalValue = AppDateFormat.yearMonthDay(
        subscription!.currentPeriodEnd!,
      );
    } else {
      renewalValue = '—';
    }

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
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
            Container(width: 0.5, color: AppColors.border),
            Expanded(
              child: _StatusItem(
                label: t.statusLabel,
                value: statusValue,
                valueColor: statusColor,
              ),
            ),
            Container(width: 0.5, color: AppColors.border),
            Expanded(
              child: _StatusItem(
                label: hasReal && subscription!.isAdminGrant
                    ? t.validUntilLabel.toUpperCase()
                    : t.renewalLabel,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: compact ? 2 : 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body1.copyWith(
              fontSize: compact ? 14 : 15,
              fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

class _PlanToggle extends StatelessWidget {
  final bool isMonthly;
  final String monthlyLabel;
  final String annualLabel;
  final String annualHint;
  final ValueChanged<bool> onChanged;

  const _PlanToggle({
    required this.isMonthly,
    required this.monthlyLabel,
    required this.annualLabel,
    required this.annualHint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.fill,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: _ToggleChip(
                  label: monthlyLabel,
                  selected: isMonthly,
                  onTap: () => onChanged(true),
                ),
              ),
              Expanded(
                child: _ToggleChip(
                  label: annualLabel,
                  selected: !isMonthly,
                  onTap: () => onChanged(false),
                ),
              ),
            ],
          ),
        ),
        if (!isMonthly)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              annualHint,
              textAlign: TextAlign.center,
              style: AppTypography.body1.copyWith(
                color: AppColors.brand,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.action : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.body1.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.onAction : AppColors.textDisabled,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ComparePlanCard extends StatelessWidget {
  final bool accentBusiness;
  final IconData icon;
  final String title;
  final String subtitle;
  final String priceDisplay;
  final String cycleLabel;
  final String vatNote;
  final bool isCurrentPlan;
  final bool isRecommended;
  final List<String> featureLabels;
  final String ctaLabel;
  final bool ctaEnabled;
  final bool isPurchasing;
  final VoidCallback onBuy;

  const _ComparePlanCard({
    required this.accentBusiness,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.priceDisplay,
    required this.cycleLabel,
    required this.vatNote,
    required this.isCurrentPlan,
    required this.isRecommended,
    required this.featureLabels,
    required this.ctaLabel,
    required this.ctaEnabled,
    required this.isPurchasing,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.subscription;
    final borderColor = accentBusiness
        ? AppColors.accent.withValues(alpha: 0.85)
        : (isCurrentPlan ? AppColors.brand : AppColors.border);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
          width: accentBusiness || isCurrentPlan ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (accentBusiness ? AppColors.accent : AppColors.brand)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color:
                        accentBusiness ? AppColors.accent : AppColors.brand,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: AppTypography.h2.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                t.recommendedBadge,
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.body1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (isCurrentPlan)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            t.currentPlanBadge,
                            style: AppTypography.body1.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.brand,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceDisplay,
                  style: AppTypography.h2.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      vatNote,
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              cycleLabel,
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            ...List.generate(featureLabels.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 22,
                      color: accentBusiness
                          ? AppColors.accent
                          : AppColors.brand,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        featureLabels[i],
                        style: AppTypography.body1.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeightPrimary,
              child: ElevatedButton(
                onPressed: ctaEnabled ? onBuy : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentBusiness
                      ? AppColors.accent
                      : AppColors.action,
                  foregroundColor: AppColors.onAction,
                  disabledBackgroundColor:
                      AppColors.fill,
                  disabledForegroundColor: AppColors.textDisabled,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isPurchasing && ctaEnabled
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.onAction,
                        ),
                      )
                    : Text(
                        ctaLabel,
                        style: AppTypography.button.copyWith(
                          fontSize: 16,
                          color: ctaEnabled
                              ? AppColors.onAction
                              : AppColors.textDisabled,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KdvNote extends StatelessWidget {
  final String text;

  const _KdvNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTypography.body1.copyWith(
          color: AppColors.textDisabled,
          fontSize: 14,
        ),
      ),
    );
  }
}

String _displayPrice({
  required double? amount,
  required String? storeString,
  required String fallback,
}) {
  if (amount != null) {
    return _formatTryPrice(amount);
  }
  if (storeString != null && storeString.trim().isNotEmpty) {
    return _normalizeStorePriceString(storeString.trim());
  }
  return fallback;
}

/// 1999.5 → 1.999,50₺
String _formatTryPrice(double amount) {
  final negative = amount < 0;
  final abs = amount.abs();
  final parts = abs.toStringAsFixed(2).split('.');
  final whole = parts[0];
  final frac = parts[1];
  final withDots = _groupThousands(whole);
  final formatted = '$withDots,$frac₺';
  return negative ? '-$formatted' : formatted;
}

String _groupThousands(String digits) {
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final fromEnd = digits.length - i;
    if (i > 0 && fromEnd % 3 == 0) {
      buf.write('.');
    }
    buf.write(digits[i]);
  }
  return buf.toString();
}

String _normalizeStorePriceString(String raw) {
  var s = raw.trim();
  final cleaned = s
      .replaceAll('TRY', '')
      .replaceAll('TL', '')
      .replaceAll('₺', '')
      .replaceAll('\u00A0', ' ')
      .trim();
  final normalized = cleaned.replaceAll(' ', '');
  double? value;
  if (RegExp(r'^\d+[.,]\d{1,2}$').hasMatch(normalized) ||
      RegExp(r'^\d+$').hasMatch(normalized)) {
    value = double.tryParse(normalized.replaceAll(',', '.'));
  } else if (RegExp(r'^\d{1,3}(\.\d{3})+(,\d{1,2})?$').hasMatch(normalized)) {
    value = double.tryParse(
      normalized.replaceAll('.', '').replaceAll(',', '.'),
    );
  } else if (RegExp(r'^\d{1,3}(,\d{3})+(\.\d{1,2})?$').hasMatch(normalized)) {
    value = double.tryParse(normalized.replaceAll(',', ''));
  }
  if (value != null) {
    return _formatTryPrice(value);
  }
  if (!s.contains('₺') && !s.toUpperCase().contains('TL')) {
    return '$s₺';
  }
  return s;
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
