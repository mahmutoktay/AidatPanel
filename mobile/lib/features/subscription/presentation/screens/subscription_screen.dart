import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_sizes.dart';
import '../../../../l10n/strings.g.dart';
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

    return Scaffold(
      backgroundColor: ProfileSettingsUi.background,
      appBar: AppBar(
        backgroundColor: ProfileSettingsUi.background,
        elevation: 0,
        centerTitle: true,
        title: Text(t.features.subscription.title, style: ProfileSettingsUi.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ProfileSettingsUi.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(subscriptionNotifierProvider.notifier).load(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: ProfileSettingsUi.screenPadding,
          children: [
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null)
              _InfoCard(
                icon: Icons.error_outline,
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
                message: state.backendUnavailable
                    ? t.features.subscription.backendPending
                    : t.features.subscription.noSubscription,
              ),
            const SizedBox(height: 24),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProfileSettingsUi.background,
        borderRadius: BorderRadius.circular(ProfileSettingsUi.radiusLg),
        border: ProfileSettingsUi.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(planLabel, style: ProfileSettingsUi.title),
          const SizedBox(height: 8),
          Text(statusLabel, style: ProfileSettingsUi.fieldValue),
          if (dateStr != null) ...[
            const SizedBox(height: 8),
            Text(
              t.features.subscription.renewsOn.replaceAll('{date}', dateStr),
              style: ProfileSettingsUi.fieldLabel,
            ),
          ],
        ],
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
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.message,
    this.child,
  });

  final IconData icon;
  final String message;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProfileSettingsUi.background,
        borderRadius: BorderRadius.circular(ProfileSettingsUi.radiusLg),
        border: ProfileSettingsUi.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: ProfileSettingsUi.muted),
          const SizedBox(height: 12),
          Text(message, style: ProfileSettingsUi.fieldValue),
          if (child != null) ...[
            const SizedBox(height: 16),
            child!,
          ],
        ],
      ),
    );
  }
}
