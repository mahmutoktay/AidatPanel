import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/subscription_entity.dart';
import '../providers/subscription_provider.dart';

// ═══════════════════════════════════════
// RENK SABİTLERİ (dosya başında const)
// ═══════════════════════════════════════
const kDark = Color(0xFF1A1A2E);
const kBg = Color(0xFFF5F4F0);
const kWhite = Colors.white;
const kGreen = Color(0xFF4ADE80);
const kGreen2 = Color(0xFF16A34A);
const kAmber = Color(0xFF92400E);
const kAmberBg = Color(0xFFFEF3C7);

// ═══════════════════════════════════════
// GENEL YAPI
// ═══════════════════════════════════════
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
    final authUser = ref.watch(authStateProvider).user;

    // Listen to success and error states for Toast feedback
    ref.listen<SubscriptionState>(subscriptionNotifierProvider, (previous, next) {
      if (next.successMessage != null && next.successMessage != previous?.successMessage) {
        final msg = _resolveMessage(context, next.successMessage!);
        ref.read(toastProvider.notifier).show(msg, type: ToastType.success);
      }
      if (next.purchaseError != null && next.purchaseError != previous?.purchaseError) {
        final msg = _resolveMessage(context, next.purchaseError!);
        ref.read(toastProvider.notifier).show(msg, type: ToastType.error);
      }
      if (next.error != null && next.error != previous?.error) {
        final msg = _resolveMessage(context, next.error!);
        ref.read(toastProvider.notifier).show(msg, type: ToastType.error);
      }
    });

    if (authUser == null && subscriptionState.isLoading) {
      return const Scaffold(
        backgroundColor: kBg,
        body: Center(
          child: CircularProgressIndicator(color: kDark),
        ),
      );
    }

    final user = authUser;
    final subscription = subscriptionState.subscription;

    // Calculate trial days left
    int? daysLeft;
    if (subscription != null && subscription.currentPeriodEnd != null) {
      final diff = subscription.currentPeriodEnd!.difference(DateTime.now()).inDays;
      // If negative or 0 but status is trial/active, we can show 0 or hide. 
      daysLeft = diff > 0 ? diff : 0;
    }

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: RefreshIndicator(
                color: kDark,
                onRefresh: () => ref.read(subscriptionNotifierProvider.notifier).load(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileRow(
                        user: user,
                        daysLeft: daysLeft,
                        status: subscription?.status,
                      ),
                      _StatusStrip(subscription: subscription),
                      const _SectionLabel("Plan seç ve satın al"),
                      _PlanCard(
                        isYearly: false,
                        planName: "Aylık plan",
                        cycle: "Her ay yenilenir",
                        price: "99",
                        features: const [
                          (true, "Sınırsız daire"),
                          (true, "Aidat takibi"),
                          (false, "Gelişmiş raporlar"),
                          (false, "Öncelikli destek"),
                        ],
                        isPurchasing: subscriptionState.isPurchasing,
                        onBuy: widget.onBuyMonthly,
                      ),
                      const SizedBox(height: 10),
                      _PlanCard(
                        isYearly: true,
                        planName: "Yıllık plan",
                        cycle: "Tek seferlik ödeme",
                        price: "999",
                        savingLabel: "2 ay ücretsiz · ₺189 tasarruf",
                        originalPrice: "₺1.188",
                        badgeLabel: "En avantajlı",
                        features: const [
                          (true, "Sınırsız daire"),
                          (true, "Aidat takibi"),
                          (true, "Gelişmiş raporlar"),
                          (true, "Öncelikli destek"),
                        ],
                        isPurchasing: subscriptionState.isPurchasing,
                        onBuy: widget.onBuyYearly,
                      ),
                      const _KdvNote(),
                    ],
                  ),
                ),
              ),
            ),
            const _BottomNav(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
// 1. ÜST BAR
// ═══════════════════════════════════════
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 18, right: 18, bottom: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: kWhite,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0x14000000), // siyah %8 (0.08)
                  width: 0.5,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF333333),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            "Abonelik",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
// 2. PROFİL SATIRI
// ═══════════════════════════════════════
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
    final parts = userName.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : 'F';
  }

  Widget _buildInitialsText(String userName) {
    final initials = _getInitials(userName);
    return Text(
      initials,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: kWhite,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = user?.profilePicture != null && user!.profilePicture!.isNotEmpty
        ? '${ApiConstants.baseUrl}/uploads/avatars/${user!.profilePicture}'
        : null;

    final String userStatus;
    if (status == SubscriptionStatus.trial) {
      userStatus = "Deneme süresi aktif";
    } else if (status == SubscriptionStatus.active) {
      userStatus = "Abonelik aktif";
    } else if (status == SubscriptionStatus.cancelled) {
      userStatus = "Abonelik iptal edildi";
    } else if (status == SubscriptionStatus.expired) {
      userStatus = "Abonelik süresi doldu";
    } else {
      userStatus = "Aktif abonelik yok";
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: kDark,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildInitialsText(user?.name ?? "Kullanıcı"),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: kWhite),
                        ),
                      );
                    },
                  )
                : _buildInitialsText(user?.name ?? "Kullanıcı"),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.name ?? "Furkan Yönetici",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                userStatus,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF888888),
                ),
              ),
            ],
          ),
          if (daysLeft != null && daysLeft! > 0 && status == SubscriptionStatus.trial) ...[
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: kAmberBg,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 11,
                    color: kAmber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "$daysLeft gün kaldı",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: kAmber,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
// 3. DURUM STRIP
// ═══════════════════════════════════════
class _StatusStrip extends StatelessWidget {
  final SubscriptionEntity? subscription;

  const _StatusStrip({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final String planValue;
    if (subscription != null && subscription!.hasRecord) {
      if (subscription!.plan.toLowerCase().contains('annual') || subscription!.plan.toLowerCase().contains('year')) {
        planValue = "Yıllık";
      } else if (subscription!.plan.toLowerCase().contains('month')) {
        planValue = "Aylık";
      } else {
        planValue = subscription!.plan;
      }
    } else {
      planValue = "-";
    }

    final String statusValue;
    final Color statusColor;
    if (subscription != null && subscription!.hasRecord) {
      if (subscription!.status == SubscriptionStatus.trial) {
        statusValue = "Deneme";
        statusColor = kGreen2;
      } else if (subscription!.status == SubscriptionStatus.active) {
        statusValue = "Aktif";
        statusColor = kGreen2;
      } else if (subscription!.status == SubscriptionStatus.cancelled) {
        statusValue = "İptal";
        statusColor = const Color(0xFF1A1A1A);
      } else if (subscription!.status == SubscriptionStatus.expired) {
        statusValue = "Doldu";
        statusColor = const Color(0xFF1A1A1A);
      } else {
        statusValue = "Bilinmiyor";
        statusColor = const Color(0xFF1A1A1A);
      }
    } else {
      statusValue = "-";
      statusColor = const Color(0xFF1A1A1A);
    }

    final String renewalValue;
    if (subscription != null && subscription!.currentPeriodEnd != null) {
      renewalValue = AppDateFormat.yearMonthDay(subscription!.currentPeriodEnd!);
    } else {
      renewalValue = "-";
    }

    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0x12000000), // siyah %7 (0.07)
          width: 0.5,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatusItem(
                label: "PLAN",
                value: planValue,
                valueColor: const Color(0xFF1A1A1A),
              ),
            ),
            Container(
              width: 0.5,
              color: const Color(0x14000000), // siyah %8 (0.08)
            ),
            Expanded(
              child: _StatusItem(
                label: "DURUM",
                value: statusValue,
                valueColor: statusColor,
              ),
            ),
            Container(
              width: 0.5,
              color: const Color(0x14000000), // siyah %8 (0.08)
            ),
            Expanded(
              child: _StatusItem(
                label: "YENİLEME",
                value: renewalValue,
                valueColor: const Color(0xFF1A1A1A),
                smallFont: true,
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
  final bool smallFont;

  const _StatusItem({
    required this.label,
    required this.value,
    required this.valueColor,
    this.smallFont = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: smallFont ? 11 : 13,
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFFAAAAAA),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════
// 4. BÖLÜM ETİKETİ
// ═══════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFFAAAAAA),
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
// 5. PLAN KARTLARI
// ═══════════════════════════════════════
class _PlanCard extends StatelessWidget {
  final bool isYearly;
  final String planName;
  final String cycle;
  final String price;
  final String? savingLabel;
  final String? originalPrice;
  final String? badgeLabel;
  final List<(bool active, String text)> features;
  final bool isPurchasing;
  final VoidCallback onBuy;

  const _PlanCard({
    required this.isYearly,
    required this.planName,
    required this.cycle,
    required this.price,
    this.savingLabel,
    this.originalPrice,
    this.badgeLabel,
    required this.features,
    required this.isPurchasing,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isYearly ? kDark : kWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isYearly ? kDark : const Color(0x14000000), // siyah %8
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isPurchasing ? null : onBuy,
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // a) Üst Row
                      Padding(
                        padding: EdgeInsets.only(top: isYearly ? 8.0 : 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: !isYearly
                                        ? const Color(0xFFF5F4F0)
                                        : const Color(0x1AFFFFFF), // beyaz %10 (0.10)
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    !isYearly
                                        ? Icons.calendar_month_outlined
                                        : Icons.workspace_premium_outlined,
                                    color: !isYearly
                                        ? kDark
                                        : const Color(0xCCFFFFFF), // beyaz %80 (0.80)
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      planName,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: isYearly ? kWhite : const Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      cycle,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isYearly
                                            ? const Color(0x66FFFFFF) // beyaz %40 (0.40)
                                            : const Color(0xFFAAAAAA),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w500,
                                      color: isYearly ? kWhite : const Color(0xFF1A1A1A),
                                    ),
                                    children: [
                                      TextSpan(text: price),
                                      const TextSpan(
                                        text: ' TL',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "KDV hariç / ${isYearly ? 'yıl' : 'ay'}",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isYearly
                                        ? const Color(0x4DFFFFFF) // beyaz %30 (0.30)
                                        : const Color(0xFFBBBBBB),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // b) Sadece isYearly ise tasarruf satırı
                      if (isYearly && savingLabel != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(74, 222, 128, 0.15), // kGreen %15
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.bolt_rounded,
                                    size: 10,
                                    color: kGreen2,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    savingLabel!,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: kGreen2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (originalPrice != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                originalPrice!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0x40FFFFFF), // beyaz %25 (0.25)
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                      // c) Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          thickness: 0.5,
                          height: 0.5,
                          color: !isYearly
                              ? const Color(0x12000000) // siyah %7 (0.07)
                              : const Color(0x14FFFFFF), // beyaz %8 (0.08)
                        ),
                      ),
                      // d) Özellik listesi
                      Column(
                        children: features.map((feature) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: _FeatureRow(
                              active: feature.$1,
                              text: feature.$2,
                              isYearly: isYearly,
                            ),
                          );
                        }).toList(),
                      ),
                      // e) SizedBox
                      const SizedBox(height: 14),
                      // f) CTA butonu
                      ElevatedButton(
                        onPressed: isPurchasing ? null : onBuy,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isYearly ? kWhite : kDark,
                          foregroundColor: isYearly ? kDark : kWhite,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          minimumSize: const Size(double.infinity, 0),
                        ),
                        child: isPurchasing
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isYearly ? kDark : kWhite,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isYearly ? Icons.workspace_premium_outlined : Icons.credit_card_outlined,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isYearly ? "Yıllık aboneliği satın al" : "Aylık aboneliği satın al",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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
                        color: kGreen,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(18),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            size: 10,
                            color: Color(0xFF14532D),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            badgeLabel!,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
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
    final Color iconColor;
    if (active) {
      iconColor = isYearly ? const Color(0xB3FFFFFF) : kDark; // beyaz %70 (0.70)
    } else {
      iconColor = isYearly ? const Color(0x33FFFFFF) : const Color(0x33000000); // beyaz %20 / siyah %20 (0.20)
    }

    final Color textColor;
    if (active) {
      textColor = isYearly ? const Color(0xC0FFFFFF) : const Color(0xFF444444); // beyaz %75 (0.75) / #444
    } else {
      textColor = isYearly ? const Color(0x40FFFFFF) : const Color(0xFFCCCCCC); // beyaz %25 (0.25) / #ccc
    }

    return Row(
      children: [
        Icon(
          active ? Icons.check_rounded : Icons.close_rounded,
          size: 13,
          color: iconColor,
        ),
        const SizedBox(width: 7),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════
// 6. KDV NOTU
// ═══════════════════════════════════════
class _KdvNote extends StatelessWidget {
  const _KdvNote();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Text(
          "Fiyatlara KDV dahil değildir · İstediğin zaman iptal edebilirsin",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9,
            color: Color(0xFFBBBBBB),
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: MediaQuery.paddingOf(context).bottom);
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
