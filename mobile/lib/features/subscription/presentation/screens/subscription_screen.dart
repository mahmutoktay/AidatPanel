import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';


import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../../shared/widgets/user_profile_avatar.dart';
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
    // Sadece ACTIVE veya TRIAL aboneliği "gerçek abonelik" say
    final bool hasActiveSubscription = subscription != null &&
        (subscription.status == SubscriptionStatus.active ||
            subscription.status == SubscriptionStatus.trial);

    int? daysLeft;
    if (subscription != null && subscription.currentPeriodEnd != null) {
      final diff = subscription.currentPeriodEnd!
          .difference(DateTime.now())
          .inDays;
      daysLeft = diff > 0 ? diff : 0;
    }

    final monthlyPrice = prices.monthlyPriceString ?? '99 ₺';
    final annualPrice = prices.annualPriceString ?? '999 ₺';

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
                      // Profil satırı
                      _ProfileRow(
                        user: authUser,
                        daysLeft: daysLeft,
                        status: subscription?.status,
                      ),
                      // Bina kullanım progress barı
                      if (subscription?.usage != null)
                        _BuildingProgressBar(
                          used: subscription!.usage!.buildings,
                          limit: subscription.limits?.buildings ?? 1,
                          label: t.buildingProgress,
                        ),
                      // Durum satırı
                      _StatusStrip(
                        subscription: subscription,
                        basicLabel: t.planBasic,
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
                      // Abonelik yoksa Temel Paket bilgisi
                      if (!hasActiveSubscription) ...[
                        _PackageCard(
                          icon: Icons.person_outline,
                          title: t.planBasic,
                          isActive: true, // Temel Paket her zaman aktif görünür
                          isComingSoon: false,
                          isCurrentPlan: false,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FeatureRow(
                                  active: true,
                                  text: t.featureBasicBuildings,
                                  dark: false,
                                ),
                                const SizedBox(height: 6),
                                _FeatureRow(
                                  active: true,
                                  text: t.featureDuesTracking,
                                  dark: false,
                                ),
                                const SizedBox(height: 6),
                                _FeatureRow(
                                  active: true,
                                  text: t.featureBasicReports,
                                  dark: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // --- Aylık / Yıllık Toggle ---
                      _PlanToggle(
                        isMonthly: _isMonthlyTab,
                        monthlyLabel: t.toggleMonthly,
                        annualLabel: t.toggleAnnual,
                        onChanged: (isMonthly) {
                          setState(() => _isMonthlyTab = isMonthly);
                        },
                      ),
                      const SizedBox(height: 16),
                      // --- 1-5 Bina Paketi (aktif) ---
                      _PackageCard(
                        icon: Icons.home_outlined,
                        title: t.plan1To5,
                        isActive: true,
                        isComingSoon: false,
                        // Sadece ACTIVE veya TRIAL abonelik varsa "Mevcut Planınız" göster
                        isCurrentPlan: hasActiveSubscription,
                        child: _PlanOption(
                          isYearly: !_isMonthlyTab,
                          planName: _isMonthlyTab ? t.planMonthly : t.planAnnual,
                          cycle: _isMonthlyTab ? t.cycleMonthly : t.cycleAnnual,
                          priceDisplay: _isMonthlyTab ? monthlyPrice : annualPrice,
                          vatNote: _isMonthlyTab ? t.priceExclVatMonth : t.priceExclVatYear,
                          featureLabels: [
                            t.feature1To5,
                            t.featureDuesTracking,
                            t.featureAdvancedReports,
                            t.featurePrioritySupport,
                          ],
                          isPurchasing: subscriptionState.isPurchasing,
                          purchasesEnabled: purchasesEnabled,
                          ctaLabel: _isMonthlyTab
                              ? t.purchaseMonthlyCta
                              : t.purchaseAnnualCta,
                          onBuy: _isMonthlyTab
                              ? widget.onBuyMonthly
                              : widget.onBuyYearly,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // --- 5-20 Bina Paketi (coming soon) ---
                      _PackageCard(
                        icon: Icons.business_outlined,
                        title: t.plan5To20,
                        isActive: false,
                        isComingSoon: true,
                        isCurrentPlan: false,
                        child: _PlanFeaturesList(
                          features: [
                            t.feature5To20,
                            t.featureDuesTracking,
                            t.featureAdvancedReports,
                          ],
                          comingSoon: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // --- 20-50 Bina Paketi (coming soon) ---
                      _PackageCard(
                        icon: Icons.apartment_outlined,
                        title: t.plan20To50,
                        isActive: false,
                        isComingSoon: true,
                        isCurrentPlan: false,
                        child: _PlanFeaturesList(
                          features: [
                            t.feature20To50,
                            t.featureDuesTracking,
                            t.featureAdvancedReports,
                            t.featurePrioritySupport,
                          ],
                          comingSoon: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // --- 50+ Bina Paketi (özel fiyat) ---
                      _PackageCard(
                        icon: Icons.corporate_fare_outlined,
                        title: t.plan50Plus,
                        isActive: false,
                        isComingSoon: false,
                        isCurrentPlan: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FeatureRow(
                                active: true,
                                text: t.feature50Plus,
                                dark: false,
                              ),
                              const SizedBox(height: 8),
                              _FeatureRow(
                                active: true,
                                text: t.featureCustomSupport,
                                dark: false,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: AppSizes.buttonHeightSecondary,
                                child: ElevatedButton.icon(
                                  onPressed: _launchContactEmail,
                                  icon: const Icon(
                                    Icons.mail_outline_rounded,
                                    size: 20,
                                  ),
                                  label: Text(t.contactUs),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.actionButtonForeground,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Center(
                                child: Text(
                                  t.contactUsDesc,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textDisabled,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Future<void> _launchContactEmail() async {
    final uri = Uri.parse('https://www.vefayazilim.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ================== Widgets ==================

class _ProfileRow extends StatelessWidget {
  final UserEntity? user;
  final int? daysLeft;
  final SubscriptionStatus? status;

  const _ProfileRow({
    required this.user,
    required this.daysLeft,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.subscription;
    final displayName = user?.name ?? t.guestUser;

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
          UserProfileAvatar(
            userId: user?.id,
            userName: displayName,
            profilePicture: user?.profilePicture,
            size: 44.0,
            borderWidth: 0.0,
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

/// Bina kullanımını gösteren progress bar.
class _BuildingProgressBar extends StatelessWidget {
  final int used;
  final int? limit;
  final String label;

  const _BuildingProgressBar({
    required this.used,
    required this.limit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.subscription;

    final bool hasLimit = limit != null && limit! > 0;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x12000000), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                hasLimit
                    ? t.buildingUsageWithLimit
                        .replaceAll('{used}', '$used')
                        .replaceAll('{limit}', '$limit')
                    : t.buildingUsageSummary.replaceAll('{used}', '$used'),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
          if (hasLimit) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (used / limit!).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: const Color(0x1A1A1A2E),
                valueColor: AlwaysStoppedAnimation<Color>(
                  (used / limit!) > 0.85
                      ? AppColors.warning
                      : AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusStrip extends StatelessWidget {
  final SubscriptionEntity? subscription;
  final String basicLabel;

  const _StatusStrip({
    required this.subscription,
    required this.basicLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.subscription;

    // Sadece ACTIVE veya TRIAL durumundaki aboneliği "gerçek abonelik" say
    final bool hasRealSubscription = subscription != null &&
        (subscription!.status == SubscriptionStatus.active ||
            subscription!.status == SubscriptionStatus.trial);

    final String planValue;
    if (hasRealSubscription) {
      final plan = subscription!.plan.toLowerCase();
      if (plan.contains('annual') || plan.contains('year')) {
        planValue = t.planAnnualShort;
      } else if (plan.contains('month')) {
        planValue = t.planMonthlyShort;
      } else {
        planValue = subscription!.plan;
      }
    } else {
      planValue = basicLabel;
    }

    final String statusValue;
    final Color statusColor;
    if (hasRealSubscription) {
      switch (subscription!.status) {
        case SubscriptionStatus.trial:
          statusValue = t.statusTrial;
          statusColor = AppColors.success;
        case SubscriptionStatus.active:
          statusValue = t.statusActive;
          statusColor = AppColors.success;
        default:
          statusValue = t.statusUnknown;
          statusColor = AppColors.textPrimary;
      }
    } else {
      statusValue = t.statusActive;
      statusColor = AppColors.success;
    }

    final String renewalValue;
    if (hasRealSubscription &&
        subscription!.currentPeriodEnd != null) {
      renewalValue = AppDateFormat.yearMonthDay(
        subscription!.currentPeriodEnd!,
      );
    } else {
      renewalValue = t.statusUnlimited;
    }

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 16),
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

/// Aylık / Yıllık toggle butonları.
class _PlanToggle extends StatelessWidget {
  final bool isMonthly;
  final String monthlyLabel;
  final String annualLabel;
  final ValueChanged<bool> onChanged;

  const _PlanToggle({
    required this.isMonthly,
    required this.monthlyLabel,
    required this.annualLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isMonthly ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(
                    monthlyLabel,
                    style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isMonthly
                          ? AppColors.actionButtonForeground
                          : AppColors.textDisabled,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !isMonthly ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(
                    annualLabel,
                    style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: !isMonthly
                          ? AppColors.actionButtonForeground
                          : AppColors.textDisabled,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bir paket grubunu temsil eden kart (ör: 1-5 Bina, 5-20 Bina vb.)
class _PackageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final bool isComingSoon;
  final bool isCurrentPlan;
  final Widget child;

  const _PackageCard({
    required this.icon,
    required this.title,
    required this.isActive,
    required this.isComingSoon,
    required this.isCurrentPlan,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : AppColors.fill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border.withValues(alpha: 0.3),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık satırı
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.fill,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          icon,
                          color: isActive ? AppColors.primary : AppColors.textDisabled,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTypography.body1.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? AppColors.textPrimary
                                    : AppColors.textDisabled,
                              ),
                            ),
                            if (isCurrentPlan)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  context
                                      .t
                                      .features
                                      .subscription
                                      .currentPlanBadge,
                                  style: AppTypography.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isComingSoon)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.fill,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_outlined,
                                size: 14,
                                color: AppColors.textDisabled,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.t.features.subscription.comingSoon,
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDisabled,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (!isActive && !isComingSoon)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Text(
                            context.t.features.subscription.contactUs,
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(
                    thickness: 0.5,
                    height: 0.5,
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 14),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 1-5 Bina Paketi içindeki plan opsiyonu (aylık veya yıllık).
/// İkisi de aynı görünümde — koyu kart, beyaz yazı.
class _PlanOption extends StatelessWidget {
  final bool isYearly;
  final String planName;
  final String cycle;
  final String priceDisplay;
  final String vatNote;
  final List<String> featureLabels;
  final bool isPurchasing;
  final bool purchasesEnabled;
  final String ctaLabel;
  final VoidCallback onBuy;

  const _PlanOption({
    required this.isYearly,
    required this.planName,
    required this.cycle,
    required this.priceDisplay,
    required this.vatNote,
    required this.featureLabels,
    required this.isPurchasing,
    required this.purchasesEnabled,
    required this.ctaLabel,
    required this.onBuy,
  });

  bool get _canPurchase => purchasesEnabled && !isPurchasing;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.darkCard,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık + fiyat
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            planName,
                            style: AppTypography.body1.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cycle,
                            style: AppTypography.small.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
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
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vatNote,
                          style: AppTypography.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Özellik listesi
                ...List.generate(featureLabels.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _FeatureRow(
                      active: true,
                      text: featureLabels[i],
                      dark: true,
                    ),
                  );
                }),
                const SizedBox(height: 10),
                // Satın al butonu
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeightSecondary,
                  child: ElevatedButton(
                    onPressed: _canPurchase ? onBuy : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.darkCard,
                      disabledBackgroundColor:
                          Colors.white.withValues(alpha: 0.5),
                      disabledForegroundColor:
                          AppColors.darkCard.withValues(alpha: 0.5),
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
                              color: AppColors.darkCard,
                            ),
                          )
                        : Text(
                            ctaLabel,
                            style: AppTypography.button.copyWith(
                              color: AppColors.darkCard,
                            ),
                            textAlign: TextAlign.center,
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

/// Pasif paketlerin içinde gösterilen özellik listesi.
class _PlanFeaturesList extends StatelessWidget {
  final List<String> features;
  final bool comingSoon;

  const _PlanFeaturesList({
    required this.features,
    required this.comingSoon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...features.map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _FeatureRow(
              active: true,
              text: f,
              dark: false,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final bool active;
  final String text;
  final bool dark;

  const _FeatureRow({
    required this.active,
    required this.text,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = active
        ? (dark ? Colors.white.withValues(alpha: 0.8) : AppColors.textPrimary)
        : (dark ? Colors.white.withValues(alpha: 0.3) : AppColors.textPrimary.withValues(alpha: 0.3));
    final textColor = active
        ? (dark ? Colors.white.withValues(alpha: 0.9) : AppColors.textPrimary)
        : (dark ? Colors.white.withValues(alpha: 0.6) : AppColors.textDisabled);

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
