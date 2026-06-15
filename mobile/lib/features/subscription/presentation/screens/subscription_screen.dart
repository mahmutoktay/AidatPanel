import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../profile/presentation/theme/profile_settings_ui.dart';
import '../../domain/entities/subscription_entity.dart';
import '../providers/subscription_provider.dart';

/// Yönetici abonelik durumu — okuma; satın alma webhook sonrası.
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

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
    final t = context.t;
    final state = ref.watch(subscriptionNotifierProvider);

    return DashboardSecondaryScaffold(
      title: t.features.subscription.title,
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(subscriptionNotifierProvider.notifier).load(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSizes.screenBodyScrollPadding.copyWith(
            bottom: AppSizes.spacingXL + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null)
              _InfoCard(
                icon: Icons.error_outline,
                iconBg: AppColors.errorBg,
                iconColor: AppColors.chartRed,
                message: state.error!,
                child: SizedBox(
                  height: AppSizes.minTouchTarget,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        ref.read(subscriptionNotifierProvider.notifier).load(),
                    style: ProfileSettingsUi.primaryButton,
                    child: Text(t.common.tryAgain),
                  ),
                ),
              )
            else if (state.subscription != null && state.subscription!.hasRecord)
              _ActiveSubscriptionCard(subscription: state.subscription!)
            else
              _InfoCard(
                icon: Icons.info_outline,
                iconBg: AppColors.infoBg,
                iconColor: AppColors.chartBlue,
                message: state.backendUnavailable
                    ? t.features.subscription.backendPending
                    : t.features.subscription.noSubscription,
              ),
            const SizedBox(height: AppSizes.spacingL),
            SizedBox(
              height: AppSizes.minTouchTarget,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null,
                style: ProfileSettingsUi.primaryButton.copyWith(
                  backgroundColor: WidgetStateProperty.all(
                    ProfileSettingsUi.muted,
                  ),
                ),
                child: Text(t.features.subscription.purchaseComingSoon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveSubscriptionCard extends StatelessWidget {
  const _ActiveSubscriptionCard({required this.subscription});

  final SubscriptionEntity subscription;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final statusLabel = _statusLabel(t, subscription.status);
    final planLabel = _planLabel(t, subscription.plan);
    final end = subscription.currentPeriodEnd;
    final dateStr =
        end != null ? DateFormat.yMMMMd().format(end.toLocal()) : null;
    final statusColors = _statusColors(subscription.status);

    final metrics = <_SubscriptionMetric>[
      _SubscriptionMetric(
        icon: Icons.workspace_premium_outlined,
        iconBg: AppColors.infoBg,
        iconColor: AppColors.chartBlue,
        value: planLabel,
        label: t.features.subscription.planUnknown,
      ),
      _SubscriptionMetric(
        icon: Icons.verified_outlined,
        iconBg: statusColors.bg,
        iconColor: statusColors.fg,
        value: statusLabel,
        label: t.common.status,
        valueColor: statusColors.fg,
      ),
      if (dateStr != null)
        _SubscriptionMetric(
          icon: Icons.event_outlined,
          iconBg: AppColors.successBg,
          iconColor: AppColors.chartGreen,
          value: dateStr,
          label: t.features.subscription.renewsOn
              .replaceAll('{date}', '')
              .replaceAll(RegExp(r'[:\s]+$'), ''),
        ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: DashboardScreenStyle.whiteCard(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < metrics.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSizes.spacingS),
              Expanded(child: _SubscriptionMetricTile(metric: metrics[i])),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel(Translations t, SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return t.features.subscription.statusActive;
      case SubscriptionStatus.expired:
        return t.features.subscription.statusExpired;
      case SubscriptionStatus.cancelled:
        return t.features.subscription.statusCancelled;
      case SubscriptionStatus.trial:
        return t.features.subscription.statusTrial;
      case SubscriptionStatus.unknown:
        return t.features.subscription.statusUnknown;
    }
  }

  String _planLabel(Translations t, String plan) {
    final p = plan.toLowerCase();
    if (p.contains('month')) return t.features.subscription.planMonthly;
    if (p.contains('annual') || p.contains('year')) {
      return t.features.subscription.planAnnual;
    }
    if (plan.isEmpty) return t.features.subscription.planUnknown;
    return plan;
  }

  ({Color bg, Color fg}) _statusColors(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
      case SubscriptionStatus.trial:
        return (bg: AppColors.successBg, fg: AppColors.chartGreen);
      case SubscriptionStatus.expired:
      case SubscriptionStatus.cancelled:
        return (bg: AppColors.errorBg, fg: AppColors.chartRed);
      case SubscriptionStatus.unknown:
        return (bg: AppColors.warningBg, fg: AppColors.chartOrange);
    }
  }
}

class _SubscriptionMetric {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final Color? valueColor;

  const _SubscriptionMetric({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    this.valueColor,
  });
}

class _SubscriptionMetricTile extends StatelessWidget {
  const _SubscriptionMetricTile({required this.metric});

  final _SubscriptionMetric metric;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: metric.iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(metric.icon, color: metric.iconColor, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          metric.value,
          style: ProfileSettingsUi.fieldValue.copyWith(
            color: metric.valueColor ?? ProfileSettingsUi.ink,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            height: 1.1,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          metric.label.trim(),
          style: ProfileSettingsUi.fieldLabel.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.message,
    this.child,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String message;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(message, style: ProfileSettingsUi.fieldValue),
          if (child != null) ...[
            const SizedBox(height: AppSizes.spacingM),
            child!,
          ],
        ],
      ),
    );
  }
}
